// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VenueModel {

 String get id; String get businessId; String get name; String get address; String get city;@GeoPointConverter() GeoPoint get location; String? get phone; String? get description; String? get imageUrl; List<String> get sports; List<String> get amenities; bool get active;@TimestampConverter() DateTime get createdAt;
/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueModelCopyWith<VenueModel> get copyWith => _$VenueModelCopyWithImpl<VenueModel>(this as VenueModel, _$identity);

  /// Serializes this VenueModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueModel&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.location, location) || other.location == location)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.sports, sports)&&const DeepCollectionEquality().equals(other.amenities, amenities)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,name,address,city,location,phone,description,imageUrl,const DeepCollectionEquality().hash(sports),const DeepCollectionEquality().hash(amenities),active,createdAt);

@override
String toString() {
  return 'VenueModel(id: $id, businessId: $businessId, name: $name, address: $address, city: $city, location: $location, phone: $phone, description: $description, imageUrl: $imageUrl, sports: $sports, amenities: $amenities, active: $active, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $VenueModelCopyWith<$Res>  {
  factory $VenueModelCopyWith(VenueModel value, $Res Function(VenueModel) _then) = _$VenueModelCopyWithImpl;
@useResult
$Res call({
 String id, String businessId, String name, String address, String city,@GeoPointConverter() GeoPoint location, String? phone, String? description, String? imageUrl, List<String> sports, List<String> amenities, bool active,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$VenueModelCopyWithImpl<$Res>
    implements $VenueModelCopyWith<$Res> {
  _$VenueModelCopyWithImpl(this._self, this._then);

  final VenueModel _self;
  final $Res Function(VenueModel) _then;

/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? address = null,Object? city = null,Object? location = null,Object? phone = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? sports = null,Object? amenities = null,Object? active = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,sports: null == sports ? _self.sports : sports // ignore: cast_nullable_to_non_nullable
as List<String>,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueModel].
extension VenueModelPatterns on VenueModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueModel value)  $default,){
final _that = this;
switch (_that) {
case _VenueModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueModel value)?  $default,){
final _that = this;
switch (_that) {
case _VenueModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String businessId,  String name,  String address,  String city, @GeoPointConverter()  GeoPoint location,  String? phone,  String? description,  String? imageUrl,  List<String> sports,  List<String> amenities,  bool active, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueModel() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.address,_that.city,_that.location,_that.phone,_that.description,_that.imageUrl,_that.sports,_that.amenities,_that.active,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String businessId,  String name,  String address,  String city, @GeoPointConverter()  GeoPoint location,  String? phone,  String? description,  String? imageUrl,  List<String> sports,  List<String> amenities,  bool active, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _VenueModel():
return $default(_that.id,_that.businessId,_that.name,_that.address,_that.city,_that.location,_that.phone,_that.description,_that.imageUrl,_that.sports,_that.amenities,_that.active,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String businessId,  String name,  String address,  String city, @GeoPointConverter()  GeoPoint location,  String? phone,  String? description,  String? imageUrl,  List<String> sports,  List<String> amenities,  bool active, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _VenueModel() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.address,_that.city,_that.location,_that.phone,_that.description,_that.imageUrl,_that.sports,_that.amenities,_that.active,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VenueModel implements VenueModel {
  const _VenueModel({required this.id, required this.businessId, required this.name, required this.address, required this.city, @GeoPointConverter() required this.location, this.phone, this.description, this.imageUrl, final  List<String> sports = const [], final  List<String> amenities = const [], this.active = true, @TimestampConverter() required this.createdAt}): _sports = sports,_amenities = amenities;
  factory _VenueModel.fromJson(Map<String, dynamic> json) => _$VenueModelFromJson(json);

@override final  String id;
@override final  String businessId;
@override final  String name;
@override final  String address;
@override final  String city;
@override@GeoPointConverter() final  GeoPoint location;
@override final  String? phone;
@override final  String? description;
@override final  String? imageUrl;
 final  List<String> _sports;
@override@JsonKey() List<String> get sports {
  if (_sports is EqualUnmodifiableListView) return _sports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sports);
}

 final  List<String> _amenities;
@override@JsonKey() List<String> get amenities {
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amenities);
}

@override@JsonKey() final  bool active;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueModelCopyWith<_VenueModel> get copyWith => __$VenueModelCopyWithImpl<_VenueModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VenueModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueModel&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.location, location) || other.location == location)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._sports, _sports)&&const DeepCollectionEquality().equals(other._amenities, _amenities)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,name,address,city,location,phone,description,imageUrl,const DeepCollectionEquality().hash(_sports),const DeepCollectionEquality().hash(_amenities),active,createdAt);

@override
String toString() {
  return 'VenueModel(id: $id, businessId: $businessId, name: $name, address: $address, city: $city, location: $location, phone: $phone, description: $description, imageUrl: $imageUrl, sports: $sports, amenities: $amenities, active: $active, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$VenueModelCopyWith<$Res> implements $VenueModelCopyWith<$Res> {
  factory _$VenueModelCopyWith(_VenueModel value, $Res Function(_VenueModel) _then) = __$VenueModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String businessId, String name, String address, String city,@GeoPointConverter() GeoPoint location, String? phone, String? description, String? imageUrl, List<String> sports, List<String> amenities, bool active,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$VenueModelCopyWithImpl<$Res>
    implements _$VenueModelCopyWith<$Res> {
  __$VenueModelCopyWithImpl(this._self, this._then);

  final _VenueModel _self;
  final $Res Function(_VenueModel) _then;

/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? address = null,Object? city = null,Object? location = null,Object? phone = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? sports = null,Object? amenities = null,Object? active = null,Object? createdAt = null,}) {
  return _then(_VenueModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,sports: null == sports ? _self._sports : sports // ignore: cast_nullable_to_non_nullable
as List<String>,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
