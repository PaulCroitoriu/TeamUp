import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/payment_method.dart';
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

    /// How the customer is paying. Cash bookings auto-confirm; card
    /// bookings stay pending until the payment lands.
    @Default(PaymentMethod.card) PaymentMethod paymentMethod,

    /// Captured when the booking was placed for someone else (ad-hoc /
    /// phone caller). Stored on the booking so it's self-contained even
    /// if the matched user record is later removed.
    String? customerName,
    String? customerPhone,
    String? customerEmail,

    /// Set when the customer matched an existing user account in the
    /// phone lookup. Useful for linking back later (sending receipts,
    /// loyalty, etc).
    String? customerUserId,

    /// Identifier shared by every booking in a recurring series. Lets
    /// us delete or modify the series as a unit later.
    String? recurrenceId,

    /// True for bookings that are part of a weekly repeat. A future job
    /// uses this to roll the series forward and collect payment.
    @Default(false) bool recurring,

    String? notes,

    /// Set when the booking flips to confirmed (either by payment or by
    /// the venue owner manually accepting).
    @NullableTimestampConverter() DateTime? confirmedAt,

    /// Set when payment lands. May be null even on confirmed bookings if
    /// the owner accepted without payment.
    @NullableTimestampConverter() DateTime? paidAt,

    /// Set when the booking is cancelled.
    @NullableTimestampConverter() DateTime? cancelledAt,

    @TimestampConverter() required DateTime createdAt,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return BookingModel.fromJson({'id': doc.id, ...data});
  }
}
