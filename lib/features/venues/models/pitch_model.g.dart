// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pitch_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PitchModel _$PitchModelFromJson(Map<String, dynamic> json) => _PitchModel(
  id: json['id'] as String,
  venueId: json['venueId'] as String,
  name: json['name'] as String,
  sport: json['sport'] as String,
  maxPlayers: (json['maxPlayers'] as num).toInt(),
  pricePerHour: (json['pricePerHour'] as num).toInt(),
  currency: json['currency'] as String? ?? 'RON',
  surface: json['surface'] as String?,
  indoor: json['indoor'] as bool? ?? false,
  imageUrl: json['imageUrl'] as String?,
  active: json['active'] as bool? ?? true,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$PitchModelToJson(_PitchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'venueId': instance.venueId,
      'name': instance.name,
      'sport': instance.sport,
      'maxPlayers': instance.maxPlayers,
      'pricePerHour': instance.pricePerHour,
      'currency': instance.currency,
      'surface': instance.surface,
      'indoor': instance.indoor,
      'imageUrl': instance.imageUrl,
      'active': instance.active,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
