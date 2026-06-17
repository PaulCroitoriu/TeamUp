// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    _ConversationModel(
      id: json['id'] as String,
      kind: $enumDecode(_$ConversationKindEnumMap, json['kind']),
      bookingId: json['bookingId'] as String?,
      gameId: json['gameId'] as String?,
      participantIds:
          (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastMessageText: json['lastMessageText'] as String?,
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      lastMessageAt: const NullableTimestampConverter().fromJson(
        json['lastMessageAt'],
      ),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$ConversationModelToJson(_ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$ConversationKindEnumMap[instance.kind]!,
      'bookingId': instance.bookingId,
      'gameId': instance.gameId,
      'participantIds': instance.participantIds,
      'lastMessageText': instance.lastMessageText,
      'lastMessageSenderId': instance.lastMessageSenderId,
      'lastMessageAt': const NullableTimestampConverter().toJson(
        instance.lastMessageAt,
      ),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$ConversationKindEnumMap = {
  ConversationKind.booking: 'booking',
  ConversationKind.direct: 'direct',
  ConversationKind.game: 'game',
};
