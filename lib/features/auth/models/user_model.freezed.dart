// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get uid; String get firstName; String get lastName; String get email; UserRole get role; String? get businessId; String? get photoUrl;/// Optional phone. Used to look up existing players when an owner is
/// booking on their behalf over the phone.
 String? get phone;// ── Player profile (helps teammates vet a join request) ──
 Gender? get gender;@NullableTimestampConverter() DateTime? get birthDate;/// Short free-text intro shown on the profile.
 String? get bio;/// Self-declared ability per sport the player plays. The keys double as the
/// player's "sports I play" list.
 Map<Sport, SkillLevel> get levels;/// Aggregate teammate rating (0–5) and how many ratings it averages.
/// Display-only for now — the post-game rating flow comes later.
 double? get rating; int get ratingCount;/// FCM device tokens for sending push notifications. Each device adds
/// its own token on sign-in and is responsible for cleaning up its own
/// token on sign-out / when the token rotates.
 List<String> get fcmTokens;@TimestampConverter() DateTime get createdAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.levels, levels)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&const DeepCollectionEquality().equals(other.fcmTokens, fcmTokens)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstName,lastName,email,role,businessId,photoUrl,phone,gender,birthDate,bio,const DeepCollectionEquality().hash(levels),rating,ratingCount,const DeepCollectionEquality().hash(fcmTokens),createdAt);

@override
String toString() {
  return 'UserModel(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, role: $role, businessId: $businessId, photoUrl: $photoUrl, phone: $phone, gender: $gender, birthDate: $birthDate, bio: $bio, levels: $levels, rating: $rating, ratingCount: $ratingCount, fcmTokens: $fcmTokens, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String uid, String firstName, String lastName, String email, UserRole role, String? businessId, String? photoUrl, String? phone, Gender? gender,@NullableTimestampConverter() DateTime? birthDate, String? bio, Map<Sport, SkillLevel> levels, double? rating, int ratingCount, List<String> fcmTokens,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? role = null,Object? businessId = freezed,Object? photoUrl = freezed,Object? phone = freezed,Object? gender = freezed,Object? birthDate = freezed,Object? bio = freezed,Object? levels = null,Object? rating = freezed,Object? ratingCount = null,Object? fcmTokens = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,businessId: freezed == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as Map<Sport, SkillLevel>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,fcmTokens: null == fcmTokens ? _self.fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String firstName,  String lastName,  String email,  UserRole role,  String? businessId,  String? photoUrl,  String? phone,  Gender? gender, @NullableTimestampConverter()  DateTime? birthDate,  String? bio,  Map<Sport, SkillLevel> levels,  double? rating,  int ratingCount,  List<String> fcmTokens, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.firstName,_that.lastName,_that.email,_that.role,_that.businessId,_that.photoUrl,_that.phone,_that.gender,_that.birthDate,_that.bio,_that.levels,_that.rating,_that.ratingCount,_that.fcmTokens,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String firstName,  String lastName,  String email,  UserRole role,  String? businessId,  String? photoUrl,  String? phone,  Gender? gender, @NullableTimestampConverter()  DateTime? birthDate,  String? bio,  Map<Sport, SkillLevel> levels,  double? rating,  int ratingCount,  List<String> fcmTokens, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.uid,_that.firstName,_that.lastName,_that.email,_that.role,_that.businessId,_that.photoUrl,_that.phone,_that.gender,_that.birthDate,_that.bio,_that.levels,_that.rating,_that.ratingCount,_that.fcmTokens,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String firstName,  String lastName,  String email,  UserRole role,  String? businessId,  String? photoUrl,  String? phone,  Gender? gender, @NullableTimestampConverter()  DateTime? birthDate,  String? bio,  Map<Sport, SkillLevel> levels,  double? rating,  int ratingCount,  List<String> fcmTokens, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.firstName,_that.lastName,_that.email,_that.role,_that.businessId,_that.photoUrl,_that.phone,_that.gender,_that.birthDate,_that.bio,_that.levels,_that.rating,_that.ratingCount,_that.fcmTokens,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({required this.uid, required this.firstName, required this.lastName, required this.email, required this.role, this.businessId, this.photoUrl, this.phone, this.gender, @NullableTimestampConverter() this.birthDate, this.bio, final  Map<Sport, SkillLevel> levels = const <Sport, SkillLevel>{}, this.rating, this.ratingCount = 0, final  List<String> fcmTokens = const <String>[], @TimestampConverter() required this.createdAt}): _levels = levels,_fcmTokens = fcmTokens,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String uid;
@override final  String firstName;
@override final  String lastName;
@override final  String email;
@override final  UserRole role;
@override final  String? businessId;
@override final  String? photoUrl;
/// Optional phone. Used to look up existing players when an owner is
/// booking on their behalf over the phone.
@override final  String? phone;
// ── Player profile (helps teammates vet a join request) ──
@override final  Gender? gender;
@override@NullableTimestampConverter() final  DateTime? birthDate;
/// Short free-text intro shown on the profile.
@override final  String? bio;
/// Self-declared ability per sport the player plays. The keys double as the
/// player's "sports I play" list.
 final  Map<Sport, SkillLevel> _levels;
/// Self-declared ability per sport the player plays. The keys double as the
/// player's "sports I play" list.
@override@JsonKey() Map<Sport, SkillLevel> get levels {
  if (_levels is EqualUnmodifiableMapView) return _levels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_levels);
}

/// Aggregate teammate rating (0–5) and how many ratings it averages.
/// Display-only for now — the post-game rating flow comes later.
@override final  double? rating;
@override@JsonKey() final  int ratingCount;
/// FCM device tokens for sending push notifications. Each device adds
/// its own token on sign-in and is responsible for cleaning up its own
/// token on sign-out / when the token rotates.
 final  List<String> _fcmTokens;
/// FCM device tokens for sending push notifications. Each device adds
/// its own token on sign-in and is responsible for cleaning up its own
/// token on sign-out / when the token rotates.
@override@JsonKey() List<String> get fcmTokens {
  if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fcmTokens);
}

@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other._levels, _levels)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&const DeepCollectionEquality().equals(other._fcmTokens, _fcmTokens)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstName,lastName,email,role,businessId,photoUrl,phone,gender,birthDate,bio,const DeepCollectionEquality().hash(_levels),rating,ratingCount,const DeepCollectionEquality().hash(_fcmTokens),createdAt);

@override
String toString() {
  return 'UserModel(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, role: $role, businessId: $businessId, photoUrl: $photoUrl, phone: $phone, gender: $gender, birthDate: $birthDate, bio: $bio, levels: $levels, rating: $rating, ratingCount: $ratingCount, fcmTokens: $fcmTokens, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String firstName, String lastName, String email, UserRole role, String? businessId, String? photoUrl, String? phone, Gender? gender,@NullableTimestampConverter() DateTime? birthDate, String? bio, Map<Sport, SkillLevel> levels, double? rating, int ratingCount, List<String> fcmTokens,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? role = null,Object? businessId = freezed,Object? photoUrl = freezed,Object? phone = freezed,Object? gender = freezed,Object? birthDate = freezed,Object? bio = freezed,Object? levels = null,Object? rating = freezed,Object? ratingCount = null,Object? fcmTokens = null,Object? createdAt = null,}) {
  return _then(_UserModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,businessId: freezed == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,levels: null == levels ? _self._levels : levels // ignore: cast_nullable_to_non_nullable
as Map<Sport, SkillLevel>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,fcmTokens: null == fcmTokens ? _self._fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
