// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pitch_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PitchModel {

 String get id; String get venueId; String get name; Sport get sport; int get maxPlayers;/// Price per hour in the smallest currency unit (e.g. cents / bani).
 int get pricePerHour;/// Currency code, e.g. "RON", "EUR".
 String get currency;/// Surface type: grass, artificial, indoor, clay, etc.
 String? get surface;/// Whether the pitch is covered / indoor.
 bool get indoor; List<String> get imageUrls; bool get active;@TimestampConverter() DateTime get createdAt;
/// Create a copy of PitchModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PitchModelCopyWith<PitchModel> get copyWith => _$PitchModelCopyWithImpl<PitchModel>(this as PitchModel, _$identity);

  /// Serializes this PitchModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PitchModel&&(identical(other.id, id) || other.id == id)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.pricePerHour, pricePerHour) || other.pricePerHour == pricePerHour)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.indoor, indoor) || other.indoor == indoor)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,venueId,name,sport,maxPlayers,pricePerHour,currency,surface,indoor,const DeepCollectionEquality().hash(imageUrls),active,createdAt);

@override
String toString() {
  return 'PitchModel(id: $id, venueId: $venueId, name: $name, sport: $sport, maxPlayers: $maxPlayers, pricePerHour: $pricePerHour, currency: $currency, surface: $surface, indoor: $indoor, imageUrls: $imageUrls, active: $active, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PitchModelCopyWith<$Res>  {
  factory $PitchModelCopyWith(PitchModel value, $Res Function(PitchModel) _then) = _$PitchModelCopyWithImpl;
@useResult
$Res call({
 String id, String venueId, String name, Sport sport, int maxPlayers, int pricePerHour, String currency, String? surface, bool indoor, List<String> imageUrls, bool active,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$PitchModelCopyWithImpl<$Res>
    implements $PitchModelCopyWith<$Res> {
  _$PitchModelCopyWithImpl(this._self, this._then);

  final PitchModel _self;
  final $Res Function(PitchModel) _then;

/// Create a copy of PitchModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? venueId = null,Object? name = null,Object? sport = null,Object? maxPlayers = null,Object? pricePerHour = null,Object? currency = null,Object? surface = freezed,Object? indoor = null,Object? imageUrls = null,Object? active = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as Sport,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,pricePerHour: null == pricePerHour ? _self.pricePerHour : pricePerHour // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as String?,indoor: null == indoor ? _self.indoor : indoor // ignore: cast_nullable_to_non_nullable
as bool,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PitchModel].
extension PitchModelPatterns on PitchModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PitchModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PitchModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PitchModel value)  $default,){
final _that = this;
switch (_that) {
case _PitchModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PitchModel value)?  $default,){
final _that = this;
switch (_that) {
case _PitchModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String venueId,  String name,  Sport sport,  int maxPlayers,  int pricePerHour,  String currency,  String? surface,  bool indoor,  List<String> imageUrls,  bool active, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PitchModel() when $default != null:
return $default(_that.id,_that.venueId,_that.name,_that.sport,_that.maxPlayers,_that.pricePerHour,_that.currency,_that.surface,_that.indoor,_that.imageUrls,_that.active,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String venueId,  String name,  Sport sport,  int maxPlayers,  int pricePerHour,  String currency,  String? surface,  bool indoor,  List<String> imageUrls,  bool active, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PitchModel():
return $default(_that.id,_that.venueId,_that.name,_that.sport,_that.maxPlayers,_that.pricePerHour,_that.currency,_that.surface,_that.indoor,_that.imageUrls,_that.active,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String venueId,  String name,  Sport sport,  int maxPlayers,  int pricePerHour,  String currency,  String? surface,  bool indoor,  List<String> imageUrls,  bool active, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PitchModel() when $default != null:
return $default(_that.id,_that.venueId,_that.name,_that.sport,_that.maxPlayers,_that.pricePerHour,_that.currency,_that.surface,_that.indoor,_that.imageUrls,_that.active,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PitchModel implements PitchModel {
  const _PitchModel({required this.id, required this.venueId, required this.name, required this.sport, required this.maxPlayers, required this.pricePerHour, this.currency = 'RON', this.surface, this.indoor = false, final  List<String> imageUrls = const [], this.active = true, @TimestampConverter() required this.createdAt}): _imageUrls = imageUrls;
  factory _PitchModel.fromJson(Map<String, dynamic> json) => _$PitchModelFromJson(json);

@override final  String id;
@override final  String venueId;
@override final  String name;
@override final  Sport sport;
@override final  int maxPlayers;
/// Price per hour in the smallest currency unit (e.g. cents / bani).
@override final  int pricePerHour;
/// Currency code, e.g. "RON", "EUR".
@override@JsonKey() final  String currency;
/// Surface type: grass, artificial, indoor, clay, etc.
@override final  String? surface;
/// Whether the pitch is covered / indoor.
@override@JsonKey() final  bool indoor;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey() final  bool active;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of PitchModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PitchModelCopyWith<_PitchModel> get copyWith => __$PitchModelCopyWithImpl<_PitchModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PitchModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PitchModel&&(identical(other.id, id) || other.id == id)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.pricePerHour, pricePerHour) || other.pricePerHour == pricePerHour)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.indoor, indoor) || other.indoor == indoor)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,venueId,name,sport,maxPlayers,pricePerHour,currency,surface,indoor,const DeepCollectionEquality().hash(_imageUrls),active,createdAt);

@override
String toString() {
  return 'PitchModel(id: $id, venueId: $venueId, name: $name, sport: $sport, maxPlayers: $maxPlayers, pricePerHour: $pricePerHour, currency: $currency, surface: $surface, indoor: $indoor, imageUrls: $imageUrls, active: $active, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PitchModelCopyWith<$Res> implements $PitchModelCopyWith<$Res> {
  factory _$PitchModelCopyWith(_PitchModel value, $Res Function(_PitchModel) _then) = __$PitchModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String venueId, String name, Sport sport, int maxPlayers, int pricePerHour, String currency, String? surface, bool indoor, List<String> imageUrls, bool active,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$PitchModelCopyWithImpl<$Res>
    implements _$PitchModelCopyWith<$Res> {
  __$PitchModelCopyWithImpl(this._self, this._then);

  final _PitchModel _self;
  final $Res Function(_PitchModel) _then;

/// Create a copy of PitchModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? venueId = null,Object? name = null,Object? sport = null,Object? maxPlayers = null,Object? pricePerHour = null,Object? currency = null,Object? surface = freezed,Object? indoor = null,Object? imageUrls = null,Object? active = null,Object? createdAt = null,}) {
  return _then(_PitchModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as Sport,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,pricePerHour: null == pricePerHour ? _self.pricePerHour : pricePerHour // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as String?,indoor: null == indoor ? _self.indoor : indoor // ignore: cast_nullable_to_non_nullable
as bool,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
