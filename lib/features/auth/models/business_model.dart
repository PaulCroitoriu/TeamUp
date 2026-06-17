import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'business_model.freezed.dart';
part 'business_model.g.dart';

@freezed
abstract class BusinessModel with _$BusinessModel {
  const factory BusinessModel({
    required String id,
    required String name,
    required String ownerUid,
    String? phone,
    String? email,
    String? address,
    String? website,
    String? logoUrl,

    /// Legal / fiscal identifiers shown on the business profile (and, later,
    /// on invoices). Optional — null until the owner fills them in.
    String? vatNumber,
    String? registrationNumber,

    /// When true (default), player bookings are confirmed on creation; when
    /// false, they land as `pending` for the owner to review and confirm.
    @Default(true) bool autoConfirmBookings,

    /// Minimum notice, in hours, a player must give to cancel a booking
    /// themselves. Inside this window online cancellation is blocked (the
    /// owner can still cancel). 0 = players may cancel any time before start.
    @Default(24) int cancellationNoticeHours,
    @TimestampConverter() required DateTime createdAt,
  }) = _BusinessModel;

  factory BusinessModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessModelFromJson(json);

  factory BusinessModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return BusinessModel.fromJson({'id': doc.id, ...data});
  }
}
