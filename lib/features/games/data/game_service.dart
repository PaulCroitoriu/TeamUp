import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/game_status.dart';
import 'package:teamup/core/enums/join_request_status.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/core/enums/payment_method.dart';
import 'package:teamup/core/firebase/firestore.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/games/models/game_model.dart';
import 'package:teamup/features/games/models/join_request_model.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';

class GameJoinException implements Exception {
  const GameJoinException(this.message);
  final String message;

  @override
  String toString() => 'GameJoinException: $message';
}

class GameService {
  GameService({FirebaseFirestore? firestore}) : _firestore = firestore ?? db;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _games =>
      _firestore.collection('games');
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _requestsCol =>
      _firestore.collection('joinRequests');
  // Top-level so a single-field query (no composite/collection-group index)
  // can list a user's requests across all games. Doc id ties game + user.
  DocumentReference<Map<String, dynamic>> _reqDoc(String gameId, String userId) =>
      _requestsCol.doc('${gameId}_$userId');

  // ── Join requests (approval-required games) ──

  /// Stream all join requests for a game (host view), oldest first.
  Stream<List<JoinRequestModel>> streamGameRequests(String gameId) {
    return _requestsCol.where('gameId', isEqualTo: gameId).snapshots().map((snap) {
      final list = snap.docs.map(JoinRequestModel.fromFirestore).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// Stream the current user's request for a game (null if none).
  Stream<JoinRequestModel?> streamMyRequest(String gameId, String userId) {
    return _reqDoc(gameId, userId).snapshots().map((doc) => doc.exists ? JoinRequestModel.fromFirestore(doc) : null);
  }

  /// Stream all of the current user's join requests across games (for the slot
  /// grid and My Games). Single-field query — no index needed.
  Stream<List<JoinRequestModel>> streamMyRequests(String userId) {
    return _requestsCol.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map(JoinRequestModel.fromFirestore).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// Player requests to join an approval-required game. No payment yet — the
  /// share is charged after the host approves. Notifies the host.
  Future<void> requestToJoin({required String gameId, required String userId}) async {
    final gameRef = _games.doc(gameId);
    final reqRef = _reqDoc(gameId, userId);
    await _firestore.runTransaction((txn) async {
      final gameSnap = await txn.get(gameRef);
      final reqSnap = await txn.get(reqRef);
      if (!gameSnap.exists) throw const GameJoinException('This game no longer exists.');

      final game = GameModel.fromFirestore(gameSnap);
      if (game.status != GameStatus.open || game.spotsOpen <= 0) {
        throw const GameJoinException('This game is already full.');
      }
      if (game.playerIds.contains(userId)) {
        throw const GameJoinException('You already joined this game.');
      }
      if (reqSnap.exists) {
        final st = JoinRequestModel.fromFirestore(reqSnap).status;
        if (st == JoinRequestStatus.pending) throw const GameJoinException('You already requested to join this game.');
        if (st == JoinRequestStatus.approved) throw const GameJoinException('Your request was approved — pay to confirm your spot.');
      }

      txn.set(
        reqRef,
        JoinRequestModel(id: userId, userId: userId, gameId: gameId, status: JoinRequestStatus.pending, createdAt: DateTime.now()).toJson(),
      );

      final notifRef = _notifications.doc();
      txn.set(
        notifRef,
        NotificationModel(
          id: notifRef.id,
          recipientId: game.hostId,
          type: NotificationType.joinRequest,
          title: 'New join request',
          body: 'A player wants to join your game — review it',
          gameId: gameId,
          createdAt: DateTime.now(),
        ).toJson(),
      );
    });
  }

  /// Host approves a request. The player is NOT added yet — they must pay to
  /// confirm. Marks the request approved and notifies the requester to pay.
  Future<void> approveRequest({required String gameId, required String userId}) async {
    final reqRef = _reqDoc(gameId, userId);
    await _firestore.runTransaction((txn) async {
      final reqSnap = await txn.get(reqRef);
      if (!reqSnap.exists) throw const GameJoinException('This request no longer exists.');

      txn.update(reqRef, {'status': JoinRequestStatus.approved.name, 'decidedAt': Timestamp.fromDate(DateTime.now())});

      final notifRef = _notifications.doc();
      txn.set(
        notifRef,
        NotificationModel(
          id: notifRef.id,
          recipientId: userId,
          type: NotificationType.joinApproved,
          title: 'Request approved',
          body: 'The host approved you — pay to confirm your spot',
          gameId: gameId,
          createdAt: DateTime.now(),
        ).toJson(),
      );
    });
  }

  /// Requester pays after approval: adds the player, bumps `spotsFilled`,
  /// records the payment method, and marks the request confirmed.
  Future<void> confirmJoin({required String gameId, required String userId, required PaymentMethod method}) async {
    final gameRef = _games.doc(gameId);
    final reqRef = _reqDoc(gameId, userId);
    await _firestore.runTransaction((txn) async {
      final gameSnap = await txn.get(gameRef);
      final reqSnap = await txn.get(reqRef);
      if (!gameSnap.exists || !reqSnap.exists) throw const GameJoinException('This request no longer exists.');

      final game = GameModel.fromFirestore(gameSnap);
      final req = JoinRequestModel.fromFirestore(reqSnap);
      if (req.status != JoinRequestStatus.approved) throw const GameJoinException('This request is not approved yet.');
      if (!game.playerIds.contains(userId) && game.spotsOpen <= 0) throw const GameJoinException('The game filled up before you paid.');

      final alreadyIn = game.playerIds.contains(userId);
      final filled = alreadyIn ? game.spotsFilled : game.spotsFilled + 1;
      txn.update(gameRef, {
        if (!alreadyIn) 'playerIds': FieldValue.arrayUnion([userId]),
        'spotsFilled': filled,
        if (filled >= game.capacity) 'status': GameStatus.full.name,
      });
      txn.update(reqRef, {'status': JoinRequestStatus.confirmed.name, 'paymentMethod': method.name});

      // Let the host know the player paid and is in.
      final notifRef = _notifications.doc();
      txn.set(
        notifRef,
        NotificationModel(
          id: notifRef.id,
          recipientId: game.hostId,
          type: NotificationType.joinApproved,
          title: 'A player joined',
          body: 'An approved player paid and joined your game',
          gameId: gameId,
          createdAt: DateTime.now(),
        ).toJson(),
      );
    });
  }

  /// A joined player leaves the game: removes them, frees a spot, reopens the
  /// game if it was full, drops their request record, and notifies the host.
  Future<void> leaveGame({required String gameId, required String userId}) async {
    final gameRef = _games.doc(gameId);
    final reqRef = _reqDoc(gameId, userId);
    await _firestore.runTransaction((txn) async {
      final gameSnap = await txn.get(gameRef);
      if (!gameSnap.exists) throw const GameJoinException('This game no longer exists.');

      final game = GameModel.fromFirestore(gameSnap);
      if (game.hostId == userId) throw const GameJoinException("The host can't leave \u2014 cancel the booking instead.");
      if (!game.playerIds.contains(userId)) throw const GameJoinException('You are not in this game.');

      final filled = (game.spotsFilled - 1).clamp(1, game.capacity);
      txn.update(gameRef, {
        'playerIds': FieldValue.arrayRemove([userId]),
        'spotsFilled': filled,
        if (game.status == GameStatus.full) 'status': GameStatus.open.name,
      });
      txn.delete(reqRef);

      final notifRef = _notifications.doc();
      txn.set(
        notifRef,
        NotificationModel(
          id: notifRef.id,
          recipientId: game.hostId,
          type: NotificationType.joinDeclined,
          title: 'A player left',
          body: 'A player left your game \u2014 a spot reopened',
          gameId: gameId,
          createdAt: DateTime.now(),
        ).toJson(),
      );
    });
  }

  /// Host declines a request and notifies the requester.
  Future<void> declineRequest({required String gameId, required String userId}) async {
    await _reqDoc(gameId, userId).update({
      'status': JoinRequestStatus.declined.name,
      'decidedAt': Timestamp.fromDate(DateTime.now()),
    });
    final notifRef = _notifications.doc();
    await notifRef.set(
      NotificationModel(
        id: notifRef.id,
        recipientId: userId,
        type: NotificationType.joinDeclined,
        title: 'Request declined',
        body: 'The host declined your request to join',
        gameId: gameId,
        createdAt: DateTime.now(),
      ).toJson(),
    );
  }

  /// Stream non-cancelled games for a single pitch on a given local day — used
  /// to surface open-game slots in the booking grid. Filters to a single
  /// equality so no composite index is required; the day window is applied
  /// client-side.
  Stream<List<GameModel>> streamPitchGamesForDay(String pitchId, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _games
        .where('pitchId', isEqualTo: pitchId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(GameModel.fromFirestore)
              .where(
                (g) =>
                    g.status != GameStatus.cancelled &&
                    !g.startTime.isBefore(dayStart) &&
                    g.startTime.isBefore(dayEnd),
              )
              .toList(),
        );
  }

  /// Join an open game: append the player and bump `spotsFilled`, flipping the
  /// game to `full` once the team is complete. Runs in a transaction so two
  /// players can't claim the last spot.
  Future<void> joinGame(String gameId, String userId) async {
    await _firestore.runTransaction((txn) async {
      final ref = _games.doc(gameId);
      final snap = await txn.get(ref);
      if (!snap.exists) {
        throw const GameJoinException('This game no longer exists.');
      }

      final game = GameModel.fromFirestore(snap);
      if (game.status != GameStatus.open) {
        throw const GameJoinException('This game is no longer open.');
      }
      if (game.playerIds.contains(userId)) {
        throw const GameJoinException('You already joined this game.');
      }
      if (game.spotsOpen <= 0) {
        throw const GameJoinException('This game is already full.');
      }

      final filled = game.spotsFilled + 1;
      txn.update(ref, {
        'playerIds': FieldValue.arrayUnion([userId]),
        'spotsFilled': filled,
        if (filled >= game.capacity) 'status': GameStatus.full.name,
      });
    });
  }

  /// Stream open games still needing players, soonest first. Sorted client-side
  /// so a single-field query suffices (no composite index needed).
  Stream<List<GameModel>> streamOpenGames() {
    return _games
        .where('status', isEqualTo: GameStatus.open.name)
        .snapshots()
        .map((snap) {
          final games = snap.docs
              .map(GameModel.fromFirestore)
              .where((g) => g.spotsOpen > 0)
              .toList();
          games.sort((a, b) => a.startTime.compareTo(b.startTime));
          return games;
        });
  }

  /// Stream games the user is part of (hosting or joined), soonest first.
  Stream<List<GameModel>> streamUserGames(String userId) {
    return _games.where('playerIds', arrayContains: userId).snapshots().map((
      snap,
    ) {
      final games = snap.docs.map(GameModel.fromFirestore).toList();
      games.sort((a, b) => a.startTime.compareTo(b.startTime));
      return games;
    });
  }

  Stream<GameModel> streamGame(String id) {
    return _games.doc(id).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Game not found: $id');
      return GameModel.fromFirestore(doc);
    });
  }

  /// Stream a set of games by id (used to show games the user has requested but
  /// not yet joined). `whereIn` supports up to 30 ids — fine for My Games.
  Stream<List<GameModel>> streamGamesByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value(const <GameModel>[]);
    return _games
        .where(FieldPath.documentId, whereIn: ids.take(30).toList())
        .snapshots()
        .map((snap) => snap.docs.map(GameModel.fromFirestore).toList());
  }

  /// Create an open game and the booking that reserves its court **atomically**.
  /// The booking and game cross-reference each other (`gameId` / `bookingId`),
  /// and the same overlap guard as a normal booking runs inside the transaction
  /// so an open game can't double-book a slot.
  Future<(GameModel, BookingModel)> createOpenGame({
    required GameModel game,
    required BookingModel booking,
  }) async {
    if (!booking.endTime.isAfter(booking.startTime)) {
      throw ArgumentError('endTime must be after startTime');
    }

    final gameRef = _games.doc();
    final bookingRef = _bookings.doc();
    final createdGame = game.copyWith(id: gameRef.id, bookingId: bookingRef.id);
    final createdBooking = booking.copyWith(
      id: bookingRef.id,
      gameId: gameRef.id,
    );

    await _firestore.runTransaction((txn) async {
      final candidates = await _bookings
          .where('pitchId', isEqualTo: createdBooking.pitchId)
          .where(
            'startTime',
            isLessThan: Timestamp.fromDate(createdBooking.endTime),
          )
          .get();

      final conflict = candidates.docs
          .map(BookingModel.fromFirestore)
          .where((b) => b.status != BookingStatus.cancelled)
          .any((b) => b.endTime.isAfter(createdBooking.startTime));

      if (conflict) {
        throw const BookingConflictException(
          'This slot overlaps an existing booking.',
        );
      }

      txn.set(bookingRef, createdBooking.toJson());
      txn.set(gameRef, createdGame.toJson());
    });

    return (createdGame, createdBooking);
  }
}
