// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationModel {

 String get id; ConversationKind get kind;/// Set when [kind] is `booking`.
 String? get bookingId;/// Set when [kind] is `game`.
 String? get gameId; List<String> get participantIds; String? get lastMessageText; String? get lastMessageSenderId;@TimestampConverter() DateTime? get lastMessageAt;@TimestampConverter() DateTime get createdAt;
/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationModelCopyWith<ConversationModel> get copyWith => _$ConversationModelCopyWithImpl<ConversationModel>(this as ConversationModel, _$identity);

  /// Serializes this ConversationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,bookingId,gameId,const DeepCollectionEquality().hash(participantIds),lastMessageText,lastMessageSenderId,lastMessageAt,createdAt);

@override
String toString() {
  return 'ConversationModel(id: $id, kind: $kind, bookingId: $bookingId, gameId: $gameId, participantIds: $participantIds, lastMessageText: $lastMessageText, lastMessageSenderId: $lastMessageSenderId, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ConversationModelCopyWith<$Res>  {
  factory $ConversationModelCopyWith(ConversationModel value, $Res Function(ConversationModel) _then) = _$ConversationModelCopyWithImpl;
@useResult
$Res call({
 String id, ConversationKind kind, String? bookingId, String? gameId, List<String> participantIds, String? lastMessageText, String? lastMessageSenderId,@TimestampConverter() DateTime? lastMessageAt,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$ConversationModelCopyWithImpl<$Res>
    implements $ConversationModelCopyWith<$Res> {
  _$ConversationModelCopyWithImpl(this._self, this._then);

  final ConversationModel _self;
  final $Res Function(ConversationModel) _then;

/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? bookingId = freezed,Object? gameId = freezed,Object? participantIds = null,Object? lastMessageText = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConversationKind,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationModel].
extension ConversationModelPatterns on ConversationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationModel value)  $default,){
final _that = this;
switch (_that) {
case _ConversationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationModel value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ConversationKind kind,  String? bookingId,  String? gameId,  List<String> participantIds,  String? lastMessageText,  String? lastMessageSenderId, @TimestampConverter()  DateTime? lastMessageAt, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationModel() when $default != null:
return $default(_that.id,_that.kind,_that.bookingId,_that.gameId,_that.participantIds,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ConversationKind kind,  String? bookingId,  String? gameId,  List<String> participantIds,  String? lastMessageText,  String? lastMessageSenderId, @TimestampConverter()  DateTime? lastMessageAt, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ConversationModel():
return $default(_that.id,_that.kind,_that.bookingId,_that.gameId,_that.participantIds,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ConversationKind kind,  String? bookingId,  String? gameId,  List<String> participantIds,  String? lastMessageText,  String? lastMessageSenderId, @TimestampConverter()  DateTime? lastMessageAt, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ConversationModel() when $default != null:
return $default(_that.id,_that.kind,_that.bookingId,_that.gameId,_that.participantIds,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationModel implements ConversationModel {
  const _ConversationModel({required this.id, required this.kind, this.bookingId, this.gameId, final  List<String> participantIds = const [], this.lastMessageText, this.lastMessageSenderId, @TimestampConverter() this.lastMessageAt, @TimestampConverter() required this.createdAt}): _participantIds = participantIds;
  factory _ConversationModel.fromJson(Map<String, dynamic> json) => _$ConversationModelFromJson(json);

@override final  String id;
@override final  ConversationKind kind;
/// Set when [kind] is `booking`.
@override final  String? bookingId;
/// Set when [kind] is `game`.
@override final  String? gameId;
 final  List<String> _participantIds;
@override@JsonKey() List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

@override final  String? lastMessageText;
@override final  String? lastMessageSenderId;
@override@TimestampConverter() final  DateTime? lastMessageAt;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationModelCopyWith<_ConversationModel> get copyWith => __$ConversationModelCopyWithImpl<_ConversationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,bookingId,gameId,const DeepCollectionEquality().hash(_participantIds),lastMessageText,lastMessageSenderId,lastMessageAt,createdAt);

@override
String toString() {
  return 'ConversationModel(id: $id, kind: $kind, bookingId: $bookingId, gameId: $gameId, participantIds: $participantIds, lastMessageText: $lastMessageText, lastMessageSenderId: $lastMessageSenderId, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ConversationModelCopyWith<$Res> implements $ConversationModelCopyWith<$Res> {
  factory _$ConversationModelCopyWith(_ConversationModel value, $Res Function(_ConversationModel) _then) = __$ConversationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, ConversationKind kind, String? bookingId, String? gameId, List<String> participantIds, String? lastMessageText, String? lastMessageSenderId,@TimestampConverter() DateTime? lastMessageAt,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$ConversationModelCopyWithImpl<$Res>
    implements _$ConversationModelCopyWith<$Res> {
  __$ConversationModelCopyWithImpl(this._self, this._then);

  final _ConversationModel _self;
  final $Res Function(_ConversationModel) _then;

/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? bookingId = freezed,Object? gameId = freezed,Object? participantIds = null,Object? lastMessageText = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageAt = freezed,Object? createdAt = null,}) {
  return _then(_ConversationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConversationKind,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
