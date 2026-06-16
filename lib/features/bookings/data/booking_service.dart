import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/game_status.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/core/firebase/firestore.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';

class BookingConflictException implements Exception {
  const BookingConflictException(this.message);
  final String message;

  @override
  String toString() => 'BookingConflictException: $message';
}

class BookingService {
  BookingService({FirebaseFirestore? firestore}) : _firestore = firestore ?? db;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref => _firestore.collection('bookings');

  /// Stream the current user's bookings, most recent first.
  Stream<List<BookingModel>> streamUserBookings(String userId) {
    return _ref
        .where('bookerId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Stream all bookings for a business (across its venues), upcoming first.
  Stream<List<BookingModel>> streamBusinessBookings(String businessId) {
    return _ref
        .where('businessId', isEqualTo: businessId)
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Stream bookings for a single pitch on a given local day — used for
  /// availability checks in the booking UI.
  Stream<List<BookingModel>> streamPitchBookingsForDay(String pitchId, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _ref
        .where('pitchId', isEqualTo: pitchId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('startTime', isLessThan: Timestamp.fromDate(dayEnd))
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  Future<BookingModel> getBooking(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) throw Exception('Booking not found: $id');
    return BookingModel.fromFirestore(doc);
  }

  Stream<BookingModel> streamBooking(String id) {
    return _ref.doc(id).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Booking not found: $id');
      return BookingModel.fromFirestore(doc);
    });
  }

  /// Create a booking, refusing if a non-cancelled booking already overlaps
  /// the requested slot on the same pitch. Bookings are the source of truth
  /// for slot occupancy, so the overlap check runs inside a transaction.
  ///
  /// Pass `force: true` to bypass the overlap check entirely — used by the
  /// owner-side recurring flow where the operator has explicitly opted in
  /// to overwrite/double-book.
  Future<BookingModel> createBooking(BookingModel booking, {bool force = false}) async {
    if (!booking.endTime.isAfter(booking.startTime)) {
      throw ArgumentError('endTime must be after startTime');
    }

    final docRef = _ref.doc();
    final created = booking.copyWith(id: docRef.id);

    if (force) {
      await docRef.set(created.toJson());
      return created;
    }

    await _firestore.runTransaction((txn) async {
      // Firestore range queries are limited to one field, so we fetch any
      // booking on this pitch that *starts* before our slot ends, then
      // filter overlaps client-side inside the transaction.
      final candidates = await _ref
          .where('pitchId', isEqualTo: created.pitchId)
          .where('startTime', isLessThan: Timestamp.fromDate(created.endTime))
          .get();

      final conflict = candidates.docs
          .map(BookingModel.fromFirestore)
          .where((b) => b.status != BookingStatus.cancelled)
          .any((b) => b.endTime.isAfter(created.startTime));

      if (conflict) {
        throw const BookingConflictException('This slot overlaps an existing booking.');
      }

      txn.set(docRef, created.toJson());
    });

    return created;
  }

  /// Create a recurring weekly series. Bookings are written in a single
  /// batch and share the same `recurrenceId`. The overlap check is
  /// skipped — recurring is an explicit owner action with a force-create
  /// policy decided at the product level.
  Future<List<BookingModel>> createRecurringBookings(List<BookingModel> bookings, {required String recurrenceId}) async {
    if (bookings.isEmpty) return const [];
    final batch = _firestore.batch();
    final created = <BookingModel>[];
    for (final b in bookings) {
      if (!b.endTime.isAfter(b.startTime)) {
        throw ArgumentError('endTime must be after startTime');
      }
      final docRef = _ref.doc();
      final withId = b.copyWith(id: docRef.id, recurrenceId: recurrenceId);
      batch.set(docRef, withId.toJson());
      created.add(withId);
    }
    await batch.commit();
    return created;
  }

  /// Cancel a booking, freeing the slot. If the booking is tied to an open
  /// game, the game is cancelled in the same batch so its slot is released too
  /// (the booking grid treats any non-cancelled game as occupying the slot).
  Future<void> cancelBooking(String id) async {
    final snap = await _ref.doc(id).get();
    final now = Timestamp.fromDate(DateTime.now());
    final gameId = snap.exists ? (snap.data()?['gameId'] as String?) : null;

    // Read the game up front (for player notifications) before the batch.
    final gameDoc = gameId != null ? await _firestore.collection('games').doc(gameId).get() : null;

    final batch = _firestore.batch();
    batch.update(_ref.doc(id), {'status': BookingStatus.cancelled.name, 'cancelledAt': now});

    if (gameId != null) {
      batch.update(_firestore.collection('games').doc(gameId), {'status': GameStatus.cancelled.name});

      // Notify everyone who joined (other than the host) that it's off.
      final data = gameDoc?.data();
      if (data != null) {
        final hostId = data['hostId'] as String?;
        final players = (data['playerIds'] as List?)?.cast<String>() ?? const <String>[];
        for (final pid in players) {
          if (pid == hostId) continue;
          final nref = _firestore.collection('notifications').doc();
          batch.set(
            nref,
            NotificationModel(
              id: nref.id,
              recipientId: pid,
              type: NotificationType.bookingCancelled,
              title: 'Game cancelled',
              body: 'A game you joined was cancelled by the host',
              gameId: gameId,
              createdAt: DateTime.now(),
            ).toJson(),
          );
        }
      }
    }

    await batch.commit();
  }

  /// Owner-accepts a booking without payment. Sets `confirmedAt` so we
  /// can render a timeline; `paidAt` stays null since no money changed
  /// hands. The player-side payment flow will set both fields.
  Future<void> confirmBooking(String id) {
    return _ref.doc(id).update({'status': BookingStatus.confirmed.name, 'confirmedAt': Timestamp.fromDate(DateTime.now())});
  }
}
