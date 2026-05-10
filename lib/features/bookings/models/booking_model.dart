import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
abstract class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String id,
    required String pitchId,
    required String venueId,
    required String businessId,
    required String bookerId,

    /// Set when the booking is tied to an open game; null for private bookings.
    String? gameId,

    @TimestampConverter() required DateTime startTime,
    @TimestampConverter() required DateTime endTime,

    /// Total price in the smallest currency unit (e.g. cents / bani).
    required int pricePaid,
    @Default('RON') String currency,
    @Default(BookingStatus.pending) BookingStatus status,
    String? notes,
    @TimestampConverter() required DateTime createdAt,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return BookingModel.fromJson({'id': doc.id, ...data});
  }
}
