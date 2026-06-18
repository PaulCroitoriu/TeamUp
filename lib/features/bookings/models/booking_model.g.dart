// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingModel _$BookingModelFromJson(
  Map<String, dynamic> json,
) => _BookingModel(
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
  recurring: json['recurring'] as bool? ?? false,
  notes: json['notes'] as String?,
  confirmedAt: const NullableTimestampConverter().fromJson(json['confirmedAt']),
  paidAt: const NullableTimestampConverter().fromJson(json['paidAt']),
  cancelledAt: const NullableTimestampConverter().fromJson(json['cancelledAt']),
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
      'recurring': instance.recurring,
      'notes': instance.notes,
      'confirmedAt': const NullableTimestampConverter().toJson(
        instance.confirmedAt,
      ),
      'paidAt': const NullableTimestampConverter().toJson(instance.paidAt),
      'cancelledAt': const NullableTimestampConverter().toJson(
        instance.cancelledAt,
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
  PaymentMethod.transfer: 'transfer',
};
