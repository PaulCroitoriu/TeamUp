// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String,
      bookingId: json['bookingId'] as String?,
      conversationId: json['conversationId'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'bookingId': instance.bookingId,
      'conversationId': instance.conversationId,
      'read': instance.read,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.newBooking: 'newBooking',
  NotificationType.bookingConfirmed: 'bookingConfirmed',
  NotificationType.bookingCancelled: 'bookingCancelled',
  NotificationType.newMessage: 'newMessage',
};
