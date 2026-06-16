// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameModel _$GameModelFromJson(Map<String, dynamic> json) => _GameModel(
  id: json['id'] as String,
  pitchId: json['pitchId'] as String,
  venueId: json['venueId'] as String,
  businessId: json['businessId'] as String,
  sport: $enumDecode(_$SportEnumMap, json['sport']),
  hostId: json['hostId'] as String,
  bookingId: json['bookingId'] as String?,
  startTime: const TimestampConverter().fromJson(json['startTime']),
  endTime: const TimestampConverter().fromJson(json['endTime']),
  capacity: (json['capacity'] as num).toInt(),
  spotsFilled: (json['spotsFilled'] as num?)?.toInt() ?? 1,
  playerIds:
      (json['playerIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  status:
      $enumDecodeNullable(_$GameStatusEnumMap, json['status']) ??
      GameStatus.open,
  requiresApproval: json['requiresApproval'] as bool? ?? false,
  pricePerHour: (json['pricePerHour'] as num).toInt(),
  currency: json['currency'] as String? ?? 'RON',
  notes: json['notes'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$GameModelToJson(_GameModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pitchId': instance.pitchId,
      'venueId': instance.venueId,
      'businessId': instance.businessId,
      'sport': _$SportEnumMap[instance.sport]!,
      'hostId': instance.hostId,
      'bookingId': instance.bookingId,
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'endTime': const TimestampConverter().toJson(instance.endTime),
      'capacity': instance.capacity,
      'spotsFilled': instance.spotsFilled,
      'playerIds': instance.playerIds,
      'status': _$GameStatusEnumMap[instance.status]!,
      'requiresApproval': instance.requiresApproval,
      'pricePerHour': instance.pricePerHour,
      'currency': instance.currency,
      'notes': instance.notes,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$SportEnumMap = {
  Sport.football: 'football',
  Sport.padel: 'padel',
  Sport.tennis: 'tennis',
  Sport.squash: 'squash',
  Sport.tableTennis: 'tableTennis',
  Sport.basketball: 'basketball',
  Sport.volleyball: 'volleyball',
  Sport.badminton: 'badminton',
  Sport.handball: 'handball',
};

const _$GameStatusEnumMap = {
  GameStatus.open: 'open',
  GameStatus.full: 'full',
  GameStatus.cancelled: 'cancelled',
  GameStatus.completed: 'completed',
};
