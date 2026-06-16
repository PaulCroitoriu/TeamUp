// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'join_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JoinRequestModel {

 String get id; String get userId; String get gameId; JoinRequestStatus get status; PaymentMethod get paymentMethod; String? get message;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime? get decidedAt;
/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinRequestModelCopyWith<JoinRequestModel> get copyWith => _$JoinRequestModelCopyWithImpl<JoinRequestModel>(this as JoinRequestModel, _$identity);

  /// Serializes this JoinRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,gameId,status,paymentMethod,message,createdAt,decidedAt);

@override
String toString() {
  return 'JoinRequestModel(id: $id, userId: $userId, gameId: $gameId, status: $status, paymentMethod: $paymentMethod, message: $message, createdAt: $createdAt, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class $JoinRequestModelCopyWith<$Res>  {
  factory $JoinRequestModelCopyWith(JoinRequestModel value, $Res Function(JoinRequestModel) _then) = _$JoinRequestModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String gameId, JoinRequestStatus status, PaymentMethod paymentMethod, String? message,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime? decidedAt
});




}
/// @nodoc
class _$JoinRequestModelCopyWithImpl<$Res>
    implements $JoinRequestModelCopyWith<$Res> {
  _$JoinRequestModelCopyWithImpl(this._self, this._then);

  final JoinRequestModel _self;
  final $Res Function(JoinRequestModel) _then;

/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? gameId = null,Object? status = null,Object? paymentMethod = null,Object? message = freezed,Object? createdAt = null,Object? decidedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JoinRequestStatus,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [JoinRequestModel].
extension JoinRequestModelPatterns on JoinRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _JoinRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _JoinRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String gameId,  JoinRequestStatus status,  PaymentMethod paymentMethod,  String? message, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime? decidedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinRequestModel() when $default != null:
return $default(_that.id,_that.userId,_that.gameId,_that.status,_that.paymentMethod,_that.message,_that.createdAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String gameId,  JoinRequestStatus status,  PaymentMethod paymentMethod,  String? message, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime? decidedAt)  $default,) {final _that = this;
switch (_that) {
case _JoinRequestModel():
return $default(_that.id,_that.userId,_that.gameId,_that.status,_that.paymentMethod,_that.message,_that.createdAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String gameId,  JoinRequestStatus status,  PaymentMethod paymentMethod,  String? message, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime? decidedAt)?  $default,) {final _that = this;
switch (_that) {
case _JoinRequestModel() when $default != null:
return $default(_that.id,_that.userId,_that.gameId,_that.status,_that.paymentMethod,_that.message,_that.createdAt,_that.decidedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JoinRequestModel implements JoinRequestModel {
  const _JoinRequestModel({required this.id, required this.userId, required this.gameId, this.status = JoinRequestStatus.pending, this.paymentMethod = PaymentMethod.card, this.message, @TimestampConverter() required this.createdAt, @TimestampConverter() this.decidedAt});
  factory _JoinRequestModel.fromJson(Map<String, dynamic> json) => _$JoinRequestModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String gameId;
@override@JsonKey() final  JoinRequestStatus status;
@override@JsonKey() final  PaymentMethod paymentMethod;
@override final  String? message;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime? decidedAt;

/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinRequestModelCopyWith<_JoinRequestModel> get copyWith => __$JoinRequestModelCopyWithImpl<_JoinRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,gameId,status,paymentMethod,message,createdAt,decidedAt);

@override
String toString() {
  return 'JoinRequestModel(id: $id, userId: $userId, gameId: $gameId, status: $status, paymentMethod: $paymentMethod, message: $message, createdAt: $createdAt, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class _$JoinRequestModelCopyWith<$Res> implements $JoinRequestModelCopyWith<$Res> {
  factory _$JoinRequestModelCopyWith(_JoinRequestModel value, $Res Function(_JoinRequestModel) _then) = __$JoinRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String gameId, JoinRequestStatus status, PaymentMethod paymentMethod, String? message,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime? decidedAt
});




}
/// @nodoc
class __$JoinRequestModelCopyWithImpl<$Res>
    implements _$JoinRequestModelCopyWith<$Res> {
  __$JoinRequestModelCopyWithImpl(this._self, this._then);

  final _JoinRequestModel _self;
  final $Res Function(_JoinRequestModel) _then;

/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? gameId = null,Object? status = null,Object? paymentMethod = null,Object? message = freezed,Object? createdAt = null,Object? decidedAt = freezed,}) {
  return _then(_JoinRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JoinRequestStatus,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
