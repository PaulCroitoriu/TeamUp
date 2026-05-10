import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,

    /// User UID this notification is delivered to.
    required String recipientId,
    required NotificationType type,
    required String title,
    required String body,

    /// Optional deep-link target IDs.
    String? bookingId,
    String? conversationId,

    @Default(false) bool read,
    @TimestampConverter() required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return NotificationModel.fromJson({'id': doc.id, ...data});
  }
}
