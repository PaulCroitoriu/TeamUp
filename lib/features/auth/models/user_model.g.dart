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
  phone: json['phone'] as String?,
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  birthDate: const NullableTimestampConverter().fromJson(json['birthDate']),
  bio: json['bio'] as String?,
  levels:
      (json['levels'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$SportEnumMap, k),
          $enumDecode(_$SkillLevelEnumMap, e),
        ),
      ) ??
      const <Sport, SkillLevel>{},
  rating: (json['rating'] as num?)?.toDouble(),
  ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$UserModelToJson(
  _UserModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'role': _$UserRoleEnumMap[instance.role]!,
  'businessId': instance.businessId,
  'photoUrl': instance.photoUrl,
  'phone': instance.phone,
  'gender': _$GenderEnumMap[instance.gender],
  'birthDate': const NullableTimestampConverter().toJson(instance.birthDate),
  'bio': instance.bio,
  'levels': instance.levels.map(
    (k, e) => MapEntry(_$SportEnumMap[k]!, _$SkillLevelEnumMap[e]!),
  ),
  'rating': instance.rating,
  'ratingCount': instance.ratingCount,
  'fcmTokens': instance.fcmTokens,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};

const _$UserRoleEnumMap = {
  UserRole.player: 'player',
  UserRole.business: 'business',
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
  Gender.preferNotToSay: 'preferNotToSay',
};

const _$SkillLevelEnumMap = {
  SkillLevel.beginner: 'beginner',
  SkillLevel.intermediate: 'intermediate',
  SkillLevel.advanced: 'advanced',
  SkillLevel.pro: 'pro',
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
