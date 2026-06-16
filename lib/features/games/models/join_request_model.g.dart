// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JoinRequestModel _$JoinRequestModelFromJson(Map<String, dynamic> json) =>
    _JoinRequestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      gameId: json['gameId'] as String,
      status:
          $enumDecodeNullable(_$JoinRequestStatusEnumMap, json['status']) ??
          JoinRequestStatus.pending,
      paymentMethod:
          $enumDecodeNullable(_$PaymentMethodEnumMap, json['paymentMethod']) ??
          PaymentMethod.card,
      message: json['message'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      decidedAt: const TimestampConverter().fromJson(json['decidedAt']),
    );

Map<String, dynamic> _$JoinRequestModelToJson(_JoinRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'gameId': instance.gameId,
      'status': _$JoinRequestStatusEnumMap[instance.status]!,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'message': instance.message,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'decidedAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.decidedAt,
        const TimestampConverter().toJson,
      ),
    };

const _$JoinRequestStatusEnumMap = {
  JoinRequestStatus.pending: 'pending',
  JoinRequestStatus.approved: 'approved',
  JoinRequestStatus.declined: 'declined',
  JoinRequestStatus.confirmed: 'confirmed',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.transfer: 'transfer',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
