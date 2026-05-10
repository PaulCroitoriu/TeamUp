// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  businessId: json['businessId'] as String?,
  photoUrl: json['photoUrl'] as String?,
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'businessId': instance.businessId,
      'photoUrl': instance.photoUrl,
      'fcmTokens': instance.fcmTokens,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$UserRoleEnumMap = {
  UserRole.player: 'player',
  UserRole.business: 'business',
};
