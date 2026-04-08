// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VenueModel _$VenueModelFromJson(Map<String, dynamic> json) => _VenueModel(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  city: json['city'] as String,
  location: const GeoPointConverter().fromJson(json['location']),
  phone: json['phone'] as String?,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  sports:
      (json['sports'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SportEnumMap, e))
          .toList() ??
      const [],
  amenities:
      (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  active: json['active'] as bool? ?? true,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$VenueModelToJson(_VenueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'location': const GeoPointConverter().toJson(instance.location),
      'phone': instance.phone,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'sports': instance.sports.map((e) => _$SportEnumMap[e]!).toList(),
      'amenities': instance.amenities,
      'active': instance.active,
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
