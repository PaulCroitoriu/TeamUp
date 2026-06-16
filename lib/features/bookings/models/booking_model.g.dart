// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingModel _$BookingModelFromJson(Map<String, dynamic> json) =>
    _BookingModel(
      id: json['id'] as String,
      pitchId: json['pitchId'] as String,
      venueId: json['venueId'] as String,
      businessId: json['businessId'] as String,
      bookerId: json['bookerId'] as String,
      gameId: json['gameId'] as String?,
      startTime: const TimestampConverter().fromJson(json['startTime']),
      endTime: const TimestampConverter().fromJson(json['endTime']),
      pricePaid: (json['pricePaid'] as num).toInt(),
      currency: json['currency'] as String? ?? 'RON',
      status:
          $enumDecodeNullable(_$BookingStatusEnumMap, json['status']) ??
          BookingStatus.pending,
      paymentMethod:
          $enumDecodeNullable(_$PaymentMethodEnumMap, json['paymentMethod']) ??
          PaymentMethod.card,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerUserId: json['customerUserId'] as String?,
      recurrenceId: json['recurrenceId'] as String?,
      notes: json['notes'] as String?,
      confirmedAt: const TimestampConverter().fromJson(json['confirmedAt']),
      paidAt: const TimestampConverter().fromJson(json['paidAt']),
      cancelledAt: const TimestampConverter().fromJson(json['cancelledAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$BookingModelToJson(_BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pitchId': instance.pitchId,
      'venueId': instance.venueId,
      'businessId': instance.businessId,
      'bookerId': instance.bookerId,
      'gameId': instance.gameId,
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'endTime': const TimestampConverter().toJson(instance.endTime),
      'pricePaid': instance.pricePaid,
      'currency': instance.currency,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'customerEmail': instance.customerEmail,
      'customerUserId': instance.customerUserId,
      'recurrenceId': instance.recurrenceId,
      'notes': instance.notes,
      'confirmedAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.confirmedAt,
        const TimestampConverter().toJson,
      ),
      'paidAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.paidAt,
        const TimestampConverter().toJson,
      ),
      'cancelledAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.cancelledAt,
        const TimestampConverter().toJson,
      ),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
