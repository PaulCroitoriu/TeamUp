import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/enums/game_status.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'game_model.freezed.dart';
part 'game_model.g.dart';

/// An open game: a booked slot the host has opened so other players can join
/// to fill the team. `spotsFilled` is stored explicitly (incl. the host) so the
/// "needs N more" state is queryable without reading the player list.
@freezed
abstract class GameModel with _$GameModel {
  const factory GameModel({
    required String id,
    required String pitchId,
    required String venueId,
    required String businessId,
    required Sport sport,

    /// The player who created the game (also the booker of the slot).
    required String hostId,

    /// The booking that reserves the court for this game.
    String? bookingId,

    @TimestampConverter() required DateTime startTime,
    @TimestampConverter() required DateTime endTime,

    /// Total spots on the court (the pitch's max players).
    required int capacity,

    /// Confirmed players, including the host.
    @Default(1) int spotsFilled,

    /// Player ids that have joined, including the host.
    @Default([]) List<String> playerIds,

    @Default(GameStatus.open) GameStatus status,

    /// When true, players must request to join and the host approves; when
    /// false, anyone can join instantly.
    @Default(false) bool requiresApproval,

    /// Total court price in the smallest currency unit (split across capacity).
    required int pricePerHour,
    @Default('RON') String currency,

    String? notes,
    @TimestampConverter() required DateTime createdAt,
  }) = _GameModel;

  const GameModel._();

  factory GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);

  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return GameModel.fromJson({'id': doc.id, ...data});
  }

  /// Open spots remaining to fill the team.
  int get spotsOpen => (capacity - spotsFilled).clamp(0, capacity);
}
