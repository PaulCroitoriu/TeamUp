// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VenueEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VenueEvent()';
}


}

/// @nodoc
class $VenueEventCopyWith<$Res>  {
$VenueEventCopyWith(VenueEvent _, $Res Function(VenueEvent) __);
}


/// Adds pattern-matching-related methods to [VenueEvent].
extension VenueEventPatterns on VenueEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadBusinessVenues value)?  loadBusinessVenues,TResult Function( _CreateVenue value)?  createVenue,TResult Function( _UpdateVenue value)?  updateVenue,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadBusinessVenues() when loadBusinessVenues != null:
return loadBusinessVenues(_that);case _CreateVenue() when createVenue != null:
return createVenue(_that);case _UpdateVenue() when updateVenue != null:
return updateVenue(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadBusinessVenues value)  loadBusinessVenues,required TResult Function( _CreateVenue value)  createVenue,required TResult Function( _UpdateVenue value)  updateVenue,}){
final _that = this;
switch (_that) {
case _LoadBusinessVenues():
return loadBusinessVenues(_that);case _CreateVenue():
return createVenue(_that);case _UpdateVenue():
return updateVenue(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadBusinessVenues value)?  loadBusinessVenues,TResult? Function( _CreateVenue value)?  createVenue,TResult? Function( _UpdateVenue value)?  updateVenue,}){
final _that = this;
switch (_that) {
case _LoadBusinessVenues() when loadBusinessVenues != null:
return loadBusinessVenues(_that);case _CreateVenue() when createVenue != null:
return createVenue(_that);case _UpdateVenue() when updateVenue != null:
return updateVenue(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String businessId)?  loadBusinessVenues,TResult Function( VenueModel venue)?  createVenue,TResult Function( VenueModel venue)?  updateVenue,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadBusinessVenues() when loadBusinessVenues != null:
return loadBusinessVenues(_that.businessId);case _CreateVenue() when createVenue != null:
return createVenue(_that.venue);case _UpdateVenue() when updateVenue != null:
return updateVenue(_that.venue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String businessId)  loadBusinessVenues,required TResult Function( VenueModel venue)  createVenue,required TResult Function( VenueModel venue)  updateVenue,}) {final _that = this;
switch (_that) {
case _LoadBusinessVenues():
return loadBusinessVenues(_that.businessId);case _CreateVenue():
return createVenue(_that.venue);case _UpdateVenue():
return updateVenue(_that.venue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String businessId)?  loadBusinessVenues,TResult? Function( VenueModel venue)?  createVenue,TResult? Function( VenueModel venue)?  updateVenue,}) {final _that = this;
switch (_that) {
case _LoadBusinessVenues() when loadBusinessVenues != null:
return loadBusinessVenues(_that.businessId);case _CreateVenue() when createVenue != null:
return createVenue(_that.venue);case _UpdateVenue() when updateVenue != null:
return updateVenue(_that.venue);case _:
  return null;

}
}

}

/// @nodoc


class _LoadBusinessVenues implements VenueEvent {
  const _LoadBusinessVenues(this.businessId);
  

 final  String businessId;

/// Create a copy of VenueEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadBusinessVenuesCopyWith<_LoadBusinessVenues> get copyWith => __$LoadBusinessVenuesCopyWithImpl<_LoadBusinessVenues>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadBusinessVenues&&(identical(other.businessId, businessId) || other.businessId == businessId));
}


@override
int get hashCode => Object.hash(runtimeType,businessId);

@override
String toString() {
  return 'VenueEvent.loadBusinessVenues(businessId: $businessId)';
}


}

/// @nodoc
abstract mixin class _$LoadBusinessVenuesCopyWith<$Res> implements $VenueEventCopyWith<$Res> {
  factory _$LoadBusinessVenuesCopyWith(_LoadBusinessVenues value, $Res Function(_LoadBusinessVenues) _then) = __$LoadBusinessVenuesCopyWithImpl;
@useResult
$Res call({
 String businessId
});




}
/// @nodoc
class __$LoadBusinessVenuesCopyWithImpl<$Res>
    implements _$LoadBusinessVenuesCopyWith<$Res> {
  __$LoadBusinessVenuesCopyWithImpl(this._self, this._then);

  final _LoadBusinessVenues _self;
  final $Res Function(_LoadBusinessVenues) _then;

/// Create a copy of VenueEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? businessId = null,}) {
  return _then(_LoadBusinessVenues(
null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _CreateVenue implements VenueEvent {
  const _CreateVenue(this.venue);
  

 final  VenueModel venue;

/// Create a copy of VenueEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateVenueCopyWith<_CreateVenue> get copyWith => __$CreateVenueCopyWithImpl<_CreateVenue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateVenue&&(identical(other.venue, venue) || other.venue == venue));
}


@override
int get hashCode => Object.hash(runtimeType,venue);

@override
String toString() {
  return 'VenueEvent.createVenue(venue: $venue)';
}


}

/// @nodoc
abstract mixin class _$CreateVenueCopyWith<$Res> implements $VenueEventCopyWith<$Res> {
  factory _$CreateVenueCopyWith(_CreateVenue value, $Res Function(_CreateVenue) _then) = __$CreateVenueCopyWithImpl;
@useResult
$Res call({
 VenueModel venue
});


$VenueModelCopyWith<$Res> get venue;

}
/// @nodoc
class __$CreateVenueCopyWithImpl<$Res>
    implements _$CreateVenueCopyWith<$Res> {
  __$CreateVenueCopyWithImpl(this._self, this._then);

  final _CreateVenue _self;
  final $Res Function(_CreateVenue) _then;

/// Create a copy of VenueEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? venue = null,}) {
  return _then(_CreateVenue(
null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as VenueModel,
  ));
}

/// Create a copy of VenueEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueModelCopyWith<$Res> get venue {
  
  return $VenueModelCopyWith<$Res>(_self.venue, (value) {
    return _then(_self.copyWith(venue: value));
  });
}
}

/// @nodoc


class _UpdateVenue implements VenueEvent {
  const _UpdateVenue(this.venue);
  

 final  VenueModel venue;

/// Create a copy of VenueEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateVenueCopyWith<_UpdateVenue> get copyWith => __$UpdateVenueCopyWithImpl<_UpdateVenue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateVenue&&(identical(other.venue, venue) || other.venue == venue));
}


@override
int get hashCode => Object.hash(runtimeType,venue);

@override
String toString() {
  return 'VenueEvent.updateVenue(venue: $venue)';
}


}

/// @nodoc
abstract mixin class _$UpdateVenueCopyWith<$Res> implements $VenueEventCopyWith<$Res> {
  factory _$UpdateVenueCopyWith(_UpdateVenue value, $Res Function(_UpdateVenue) _then) = __$UpdateVenueCopyWithImpl;
@useResult
$Res call({
 VenueModel venue
});


$VenueModelCopyWith<$Res> get venue;

}
/// @nodoc
class __$UpdateVenueCopyWithImpl<$Res>
    implements _$UpdateVenueCopyWith<$Res> {
  __$UpdateVenueCopyWithImpl(this._self, this._then);

  final _UpdateVenue _self;
  final $Res Function(_UpdateVenue) _then;

/// Create a copy of VenueEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? venue = null,}) {
  return _then(_UpdateVenue(
null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as VenueModel,
  ));
}

/// Create a copy of VenueEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueModelCopyWith<$Res> get venue {
  
  return $VenueModelCopyWith<$Res>(_self.venue, (value) {
    return _then(_self.copyWith(venue: value));
  });
}
}

/// @nodoc
mixin _$VenueState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VenueState()';
}


}

/// @nodoc
class $VenueStateCopyWith<$Res>  {
$VenueStateCopyWith(VenueState _, $Res Function(VenueState) __);
}


/// Adds pattern-matching-related methods to [VenueState].
extension VenueStatePatterns on VenueState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<VenueModel> venues)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.venues);case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<VenueModel> venues)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.venues);case _Error():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<VenueModel> venues)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.venues);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements VenueState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VenueState.initial()';
}


}




/// @nodoc


class _Loading implements VenueState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VenueState.loading()';
}


}




/// @nodoc


class _Loaded implements VenueState {
  const _Loaded(final  List<VenueModel> venues): _venues = venues;
  

 final  List<VenueModel> _venues;
 List<VenueModel> get venues {
  if (_venues is EqualUnmodifiableListView) return _venues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_venues);
}


/// Create a copy of VenueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._venues, _venues));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_venues));

@override
String toString() {
  return 'VenueState.loaded(venues: $venues)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $VenueStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<VenueModel> venues
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of VenueState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? venues = null,}) {
  return _then(_Loaded(
null == venues ? _self._venues : venues // ignore: cast_nullable_to_non_nullable
as List<VenueModel>,
  ));
}


}

/// @nodoc


class _Error implements VenueState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of VenueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VenueState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $VenueStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of VenueState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
