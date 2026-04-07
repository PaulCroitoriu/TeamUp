// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BusinessModel _$BusinessModelFromJson(Map<String, dynamic> json) =>
    _BusinessModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerUid: json['ownerUid'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logoUrl'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$BusinessModelToJson(_BusinessModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerUid': instance.ownerUid,
      'phone': instance.phone,
      'address': instance.address,
      'logoUrl': instance.logoUrl,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
