// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BusinessModel {

 String get id; String get name; String get ownerUid; String? get phone; String? get email; String? get address; String? get website; String? get logoUrl;/// Legal / fiscal identifiers shown on the business profile (and, later,
/// on invoices). Optional — null until the owner fills them in.
 String? get vatNumber; String? get registrationNumber;/// When true (default), player bookings are confirmed on creation; when
/// false, they land as `pending` for the owner to review and confirm.
 bool get autoConfirmBookings;/// Minimum notice, in hours, a player must give to cancel a booking
/// themselves. Inside this window online cancellation is blocked (the
/// owner can still cancel). 0 = players may cancel any time before start.
 int get cancellationNoticeHours;@TimestampConverter() DateTime get createdAt;
/// Create a copy of BusinessModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessModelCopyWith<BusinessModel> get copyWith => _$BusinessModelCopyWithImpl<BusinessModel>(this as BusinessModel, _$identity);

  /// Serializes this BusinessModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.website, website) || other.website == website)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.autoConfirmBookings, autoConfirmBookings) || other.autoConfirmBookings == autoConfirmBookings)&&(identical(other.cancellationNoticeHours, cancellationNoticeHours) || other.cancellationNoticeHours == cancellationNoticeHours)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerUid,phone,email,address,website,logoUrl,vatNumber,registrationNumber,autoConfirmBookings,cancellationNoticeHours,createdAt);

@override
String toString() {
  return 'BusinessModel(id: $id, name: $name, ownerUid: $ownerUid, phone: $phone, email: $email, address: $address, website: $website, logoUrl: $logoUrl, vatNumber: $vatNumber, registrationNumber: $registrationNumber, autoConfirmBookings: $autoConfirmBookings, cancellationNoticeHours: $cancellationNoticeHours, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BusinessModelCopyWith<$Res>  {
  factory $BusinessModelCopyWith(BusinessModel value, $Res Function(BusinessModel) _then) = _$BusinessModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ownerUid, String? phone, String? email, String? address, String? website, String? logoUrl, String? vatNumber, String? registrationNumber, bool autoConfirmBookings, int cancellationNoticeHours,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$BusinessModelCopyWithImpl<$Res>
    implements $BusinessModelCopyWith<$Res> {
  _$BusinessModelCopyWithImpl(this._self, this._then);

  final BusinessModel _self;
  final $Res Function(BusinessModel) _then;

/// Create a copy of BusinessModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerUid = null,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? website = freezed,Object? logoUrl = freezed,Object? vatNumber = freezed,Object? registrationNumber = freezed,Object? autoConfirmBookings = null,Object? cancellationNoticeHours = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,autoConfirmBookings: null == autoConfirmBookings ? _self.autoConfirmBookings : autoConfirmBookings // ignore: cast_nullable_to_non_nullable
as bool,cancellationNoticeHours: null == cancellationNoticeHours ? _self.cancellationNoticeHours : cancellationNoticeHours // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessModel].
extension BusinessModelPatterns on BusinessModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessModel value)  $default,){
final _that = this;
switch (_that) {
case _BusinessModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessModel value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerUid,  String? phone,  String? email,  String? address,  String? website,  String? logoUrl,  String? vatNumber,  String? registrationNumber,  bool autoConfirmBookings,  int cancellationNoticeHours, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessModel() when $default != null:
return $default(_that.id,_that.name,_that.ownerUid,_that.phone,_that.email,_that.address,_that.website,_that.logoUrl,_that.vatNumber,_that.registrationNumber,_that.autoConfirmBookings,_that.cancellationNoticeHours,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerUid,  String? phone,  String? email,  String? address,  String? website,  String? logoUrl,  String? vatNumber,  String? registrationNumber,  bool autoConfirmBookings,  int cancellationNoticeHours, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BusinessModel():
return $default(_that.id,_that.name,_that.ownerUid,_that.phone,_that.email,_that.address,_that.website,_that.logoUrl,_that.vatNumber,_that.registrationNumber,_that.autoConfirmBookings,_that.cancellationNoticeHours,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerUid,  String? phone,  String? email,  String? address,  String? website,  String? logoUrl,  String? vatNumber,  String? registrationNumber,  bool autoConfirmBookings,  int cancellationNoticeHours, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BusinessModel() when $default != null:
return $default(_that.id,_that.name,_that.ownerUid,_that.phone,_that.email,_that.address,_that.website,_that.logoUrl,_that.vatNumber,_that.registrationNumber,_that.autoConfirmBookings,_that.cancellationNoticeHours,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessModel implements BusinessModel {
  const _BusinessModel({required this.id, required this.name, required this.ownerUid, this.phone, this.email, this.address, this.website, this.logoUrl, this.vatNumber, this.registrationNumber, this.autoConfirmBookings = true, this.cancellationNoticeHours = 24, @TimestampConverter() required this.createdAt});
  factory _BusinessModel.fromJson(Map<String, dynamic> json) => _$BusinessModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String ownerUid;
@override final  String? phone;
@override final  String? email;
@override final  String? address;
@override final  String? website;
@override final  String? logoUrl;
/// Legal / fiscal identifiers shown on the business profile (and, later,
/// on invoices). Optional — null until the owner fills them in.
@override final  String? vatNumber;
@override final  String? registrationNumber;
/// When true (default), player bookings are confirmed on creation; when
/// false, they land as `pending` for the owner to review and confirm.
@override@JsonKey() final  bool autoConfirmBookings;
/// Minimum notice, in hours, a player must give to cancel a booking
/// themselves. Inside this window online cancellation is blocked (the
/// owner can still cancel). 0 = players may cancel any time before start.
@override@JsonKey() final  int cancellationNoticeHours;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of BusinessModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessModelCopyWith<_BusinessModel> get copyWith => __$BusinessModelCopyWithImpl<_BusinessModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.website, website) || other.website == website)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.autoConfirmBookings, autoConfirmBookings) || other.autoConfirmBookings == autoConfirmBookings)&&(identical(other.cancellationNoticeHours, cancellationNoticeHours) || other.cancellationNoticeHours == cancellationNoticeHours)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerUid,phone,email,address,website,logoUrl,vatNumber,registrationNumber,autoConfirmBookings,cancellationNoticeHours,createdAt);

@override
String toString() {
  return 'BusinessModel(id: $id, name: $name, ownerUid: $ownerUid, phone: $phone, email: $email, address: $address, website: $website, logoUrl: $logoUrl, vatNumber: $vatNumber, registrationNumber: $registrationNumber, autoConfirmBookings: $autoConfirmBookings, cancellationNoticeHours: $cancellationNoticeHours, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BusinessModelCopyWith<$Res> implements $BusinessModelCopyWith<$Res> {
  factory _$BusinessModelCopyWith(_BusinessModel value, $Res Function(_BusinessModel) _then) = __$BusinessModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ownerUid, String? phone, String? email, String? address, String? website, String? logoUrl, String? vatNumber, String? registrationNumber, bool autoConfirmBookings, int cancellationNoticeHours,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$BusinessModelCopyWithImpl<$Res>
    implements _$BusinessModelCopyWith<$Res> {
  __$BusinessModelCopyWithImpl(this._self, this._then);

  final _BusinessModel _self;
  final $Res Function(_BusinessModel) _then;

/// Create a copy of BusinessModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerUid = null,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? website = freezed,Object? logoUrl = freezed,Object? vatNumber = freezed,Object? registrationNumber = freezed,Object? autoConfirmBookings = null,Object? cancellationNoticeHours = null,Object? createdAt = null,}) {
  return _then(_BusinessModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,autoConfirmBookings: null == autoConfirmBookings ? _self.autoConfirmBookings : autoConfirmBookings // ignore: cast_nullable_to_non_nullable
as bool,cancellationNoticeHours: null == cancellationNoticeHours ? _self.cancellationNoticeHours : cancellationNoticeHours // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
