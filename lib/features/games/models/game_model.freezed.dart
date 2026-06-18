// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameModel {

 String get id; String get pitchId; String get venueId; String get businessId; Sport get sport;/// The player who created the game (also the booker of the slot).
 String get hostId;/// The booking that reserves the court for this game.
 String? get bookingId;@TimestampConverter() DateTime get startTime;@TimestampConverter() DateTime get endTime;/// Total spots on the court (the pitch's max players).
 int get capacity;/// Confirmed players, including the host.
 int get spotsFilled;/// Player ids that have joined, including the host.
 List<String> get playerIds; GameStatus get status;/// When true, players must request to join and the host approves; when
/// false, anyone can join instantly.
 bool get requiresApproval;/// Total court price in the smallest currency unit (split across capacity).
 int get pricePerHour; String get currency; String? get notes;@TimestampConverter() DateTime get createdAt;
/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameModelCopyWith<GameModel> get copyWith => _$GameModelCopyWithImpl<GameModel>(this as GameModel, _$identity);

  /// Serializes this GameModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameModel&&(identical(other.id, id) || other.id == id)&&(identical(other.pitchId, pitchId) || other.pitchId == pitchId)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.spotsFilled, spotsFilled) || other.spotsFilled == spotsFilled)&&const DeepCollectionEquality().equals(other.playerIds, playerIds)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.pricePerHour, pricePerHour) || other.pricePerHour == pricePerHour)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pitchId,venueId,businessId,sport,hostId,bookingId,startTime,endTime,capacity,spotsFilled,const DeepCollectionEquality().hash(playerIds),status,requiresApproval,pricePerHour,currency,notes,createdAt);

@override
String toString() {
  return 'GameModel(id: $id, pitchId: $pitchId, venueId: $venueId, businessId: $businessId, sport: $sport, hostId: $hostId, bookingId: $bookingId, startTime: $startTime, endTime: $endTime, capacity: $capacity, spotsFilled: $spotsFilled, playerIds: $playerIds, status: $status, requiresApproval: $requiresApproval, pricePerHour: $pricePerHour, currency: $currency, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GameModelCopyWith<$Res>  {
  factory $GameModelCopyWith(GameModel value, $Res Function(GameModel) _then) = _$GameModelCopyWithImpl;
@useResult
$Res call({
 String id, String pitchId, String venueId, String businessId, Sport sport, String hostId, String? bookingId,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, int capacity, int spotsFilled, List<String> playerIds, GameStatus status, bool requiresApproval, int pricePerHour, String currency, String? notes,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$GameModelCopyWithImpl<$Res>
    implements $GameModelCopyWith<$Res> {
  _$GameModelCopyWithImpl(this._self, this._then);

  final GameModel _self;
  final $Res Function(GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pitchId = null,Object? venueId = null,Object? businessId = null,Object? sport = null,Object? hostId = null,Object? bookingId = freezed,Object? startTime = null,Object? endTime = null,Object? capacity = null,Object? spotsFilled = null,Object? playerIds = null,Object? status = null,Object? requiresApproval = null,Object? pricePerHour = null,Object? currency = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pitchId: null == pitchId ? _self.pitchId : pitchId // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as Sport,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,spotsFilled: null == spotsFilled ? _self.spotsFilled : spotsFilled // ignore: cast_nullable_to_non_nullable
as int,playerIds: null == playerIds ? _self.playerIds : playerIds // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,pricePerHour: null == pricePerHour ? _self.pricePerHour : pricePerHour // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GameModel].
extension GameModelPatterns on GameModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameModel value)  $default,){
final _that = this;
switch (_that) {
case _GameModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameModel value)?  $default,){
final _that = this;
switch (_that) {
case _GameModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String pitchId,  String venueId,  String businessId,  Sport sport,  String hostId,  String? bookingId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  int capacity,  int spotsFilled,  List<String> playerIds,  GameStatus status,  bool requiresApproval,  int pricePerHour,  String currency,  String? notes, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.id,_that.pitchId,_that.venueId,_that.businessId,_that.sport,_that.hostId,_that.bookingId,_that.startTime,_that.endTime,_that.capacity,_that.spotsFilled,_that.playerIds,_that.status,_that.requiresApproval,_that.pricePerHour,_that.currency,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String pitchId,  String venueId,  String businessId,  Sport sport,  String hostId,  String? bookingId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  int capacity,  int spotsFilled,  List<String> playerIds,  GameStatus status,  bool requiresApproval,  int pricePerHour,  String currency,  String? notes, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _GameModel():
return $default(_that.id,_that.pitchId,_that.venueId,_that.businessId,_that.sport,_that.hostId,_that.bookingId,_that.startTime,_that.endTime,_that.capacity,_that.spotsFilled,_that.playerIds,_that.status,_that.requiresApproval,_that.pricePerHour,_that.currency,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String pitchId,  String venueId,  String businessId,  Sport sport,  String hostId,  String? bookingId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  int capacity,  int spotsFilled,  List<String> playerIds,  GameStatus status,  bool requiresApproval,  int pricePerHour,  String currency,  String? notes, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.id,_that.pitchId,_that.venueId,_that.businessId,_that.sport,_that.hostId,_that.bookingId,_that.startTime,_that.endTime,_that.capacity,_that.spotsFilled,_that.playerIds,_that.status,_that.requiresApproval,_that.pricePerHour,_that.currency,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameModel extends GameModel {
  const _GameModel({required this.id, required this.pitchId, required this.venueId, required this.businessId, required this.sport, required this.hostId, this.bookingId, @TimestampConverter() required this.startTime, @TimestampConverter() required this.endTime, required this.capacity, this.spotsFilled = 1, final  List<String> playerIds = const [], this.status = GameStatus.open, this.requiresApproval = false, required this.pricePerHour, this.currency = 'RON', this.notes, @TimestampConverter() required this.createdAt}): _playerIds = playerIds,super._();
  factory _GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);

@override final  String id;
@override final  String pitchId;
@override final  String venueId;
@override final  String businessId;
@override final  Sport sport;
/// The player who created the game (also the booker of the slot).
@override final  String hostId;
/// The booking that reserves the court for this game.
@override final  String? bookingId;
@override@TimestampConverter() final  DateTime startTime;
@override@TimestampConverter() final  DateTime endTime;
/// Total spots on the court (the pitch's max players).
@override final  int capacity;
/// Confirmed players, including the host.
@override@JsonKey() final  int spotsFilled;
/// Player ids that have joined, including the host.
 final  List<String> _playerIds;
/// Player ids that have joined, including the host.
@override@JsonKey() List<String> get playerIds {
  if (_playerIds is EqualUnmodifiableListView) return _playerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playerIds);
}

@override@JsonKey() final  GameStatus status;
/// When true, players must request to join and the host approves; when
/// false, anyone can join instantly.
@override@JsonKey() final  bool requiresApproval;
/// Total court price in the smallest currency unit (split across capacity).
@override final  int pricePerHour;
@override@JsonKey() final  String currency;
@override final  String? notes;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameModelCopyWith<_GameModel> get copyWith => __$GameModelCopyWithImpl<_GameModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameModel&&(identical(other.id, id) || other.id == id)&&(identical(other.pitchId, pitchId) || other.pitchId == pitchId)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.spotsFilled, spotsFilled) || other.spotsFilled == spotsFilled)&&const DeepCollectionEquality().equals(other._playerIds, _playerIds)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.pricePerHour, pricePerHour) || other.pricePerHour == pricePerHour)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pitchId,venueId,businessId,sport,hostId,bookingId,startTime,endTime,capacity,spotsFilled,const DeepCollectionEquality().hash(_playerIds),status,requiresApproval,pricePerHour,currency,notes,createdAt);

@override
String toString() {
  return 'GameModel(id: $id, pitchId: $pitchId, venueId: $venueId, businessId: $businessId, sport: $sport, hostId: $hostId, bookingId: $bookingId, startTime: $startTime, endTime: $endTime, capacity: $capacity, spotsFilled: $spotsFilled, playerIds: $playerIds, status: $status, requiresApproval: $requiresApproval, pricePerHour: $pricePerHour, currency: $currency, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GameModelCopyWith<$Res> implements $GameModelCopyWith<$Res> {
  factory _$GameModelCopyWith(_GameModel value, $Res Function(_GameModel) _then) = __$GameModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String pitchId, String venueId, String businessId, Sport sport, String hostId, String? bookingId,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, int capacity, int spotsFilled, List<String> playerIds, GameStatus status, bool requiresApproval, int pricePerHour, String currency, String? notes,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$GameModelCopyWithImpl<$Res>
    implements _$GameModelCopyWith<$Res> {
  __$GameModelCopyWithImpl(this._self, this._then);

  final _GameModel _self;
  final $Res Function(_GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pitchId = null,Object? venueId = null,Object? businessId = null,Object? sport = null,Object? hostId = null,Object? bookingId = freezed,Object? startTime = null,Object? endTime = null,Object? capacity = null,Object? spotsFilled = null,Object? playerIds = null,Object? status = null,Object? requiresApproval = null,Object? pricePerHour = null,Object? currency = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_GameModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pitchId: null == pitchId ? _self.pitchId : pitchId // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as Sport,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,spotsFilled: null == spotsFilled ? _self.spotsFilled : spotsFilled // ignore: cast_nullable_to_non_nullable
as int,playerIds: null == playerIds ? _self._playerIds : playerIds // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,pricePerHour: null == pricePerHour ? _self.pricePerHour : pricePerHour // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
