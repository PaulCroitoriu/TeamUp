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
      email: json['email'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      vatNumber: json['vatNumber'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      autoConfirmBookings: json['autoConfirmBookings'] as bool? ?? true,
      cancellationNoticeHours:
          (json['cancellationNoticeHours'] as num?)?.toInt() ?? 24,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$BusinessModelToJson(_BusinessModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerUid': instance.ownerUid,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'website': instance.website,
      'logoUrl': instance.logoUrl,
      'vatNumber': instance.vatNumber,
      'registrationNumber': instance.registrationNumber,
      'autoConfirmBookings': instance.autoConfirmBookings,
      'cancellationNoticeHours': instance.cancellationNoticeHours,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
