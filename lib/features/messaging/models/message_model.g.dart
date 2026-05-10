// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map<String, dynamic> json) =>
    _MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      participantIds:
          (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      sentAt: const TimestampConverter().fromJson(json['sentAt']),
    );

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'text': instance.text,
      'participantIds': instance.participantIds,
      'sentAt': const TimestampConverter().toJson(instance.sentAt),
    };
