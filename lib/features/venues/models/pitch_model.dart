import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'pitch_model.freezed.dart';
part 'pitch_model.g.dart';

@freezed
abstract class PitchModel with _$PitchModel {
  const factory PitchModel({
    required String id,
    required String venueId,
    required String name,
    required Sport sport,
    required int maxPlayers,

    /// Price per hour in the smallest currency unit (e.g. cents / bani).
    required int pricePerHour,

    /// Currency code, e.g. "RON", "EUR".
    @Default('RON') String currency,

    /// Surface type: grass, artificial, indoor, clay, etc.
    String? surface,

    /// Whether the pitch is covered / indoor.
    @Default(false) bool indoor,
    String? imageUrl,
    @Default(true) bool active,
    @TimestampConverter() required DateTime createdAt,
  }) = _PitchModel;

  factory PitchModel.fromJson(Map<String, dynamic> json) =>
      _$PitchModelFromJson(json);

  factory PitchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return PitchModel.fromJson({'id': doc.id, ...data});
  }
}
