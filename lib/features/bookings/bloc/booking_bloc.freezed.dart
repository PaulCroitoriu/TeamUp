// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookingEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BookingEvent()';
}


}

/// @nodoc
class $BookingEventCopyWith<$Res>  {
$BookingEventCopyWith(BookingEvent _, $Res Function(BookingEvent) __);
}


/// Adds pattern-matching-related methods to [BookingEvent].
extension BookingEventPatterns on BookingEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadBusinessBookings value)?  loadBusinessBookings,TResult Function( _LoadUserBookings value)?  loadUserBookings,TResult Function( _CreateBooking value)?  createBooking,TResult Function( _CancelBooking value)?  cancelBooking,TResult Function( _ConfirmBooking value)?  confirmBooking,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadBusinessBookings() when loadBusinessBookings != null:
return loadBusinessBookings(_that);case _LoadUserBookings() when loadUserBookings != null:
return loadUserBookings(_that);case _CreateBooking() when createBooking != null:
return createBooking(_that);case _CancelBooking() when cancelBooking != null:
return cancelBooking(_that);case _ConfirmBooking() when confirmBooking != null:
return confirmBooking(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadBusinessBookings value)  loadBusinessBookings,required TResult Function( _LoadUserBookings value)  loadUserBookings,required TResult Function( _CreateBooking value)  createBooking,required TResult Function( _CancelBooking value)  cancelBooking,required TResult Function( _ConfirmBooking value)  confirmBooking,}){
final _that = this;
switch (_that) {
case _LoadBusinessBookings():
return loadBusinessBookings(_that);case _LoadUserBookings():
return loadUserBookings(_that);case _CreateBooking():
return createBooking(_that);case _CancelBooking():
return cancelBooking(_that);case _ConfirmBooking():
return confirmBooking(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadBusinessBookings value)?  loadBusinessBookings,TResult? Function( _LoadUserBookings value)?  loadUserBookings,TResult? Function( _CreateBooking value)?  createBooking,TResult? Function( _CancelBooking value)?  cancelBooking,TResult? Function( _ConfirmBooking value)?  confirmBooking,}){
final _that = this;
switch (_that) {
case _LoadBusinessBookings() when loadBusinessBookings != null:
return loadBusinessBookings(_that);case _LoadUserBookings() when loadUserBookings != null:
return loadUserBookings(_that);case _CreateBooking() when createBooking != null:
return createBooking(_that);case _CancelBooking() when cancelBooking != null:
return cancelBooking(_that);case _ConfirmBooking() when confirmBooking != null:
return confirmBooking(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String businessId)?  loadBusinessBookings,TResult Function( String userId)?  loadUserBookings,TResult Function( BookingModel booking)?  createBooking,TResult Function( String bookingId)?  cancelBooking,TResult Function( String bookingId)?  confirmBooking,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadBusinessBookings() when loadBusinessBookings != null:
return loadBusinessBookings(_that.businessId);case _LoadUserBookings() when loadUserBookings != null:
return loadUserBookings(_that.userId);case _CreateBooking() when createBooking != null:
return createBooking(_that.booking);case _CancelBooking() when cancelBooking != null:
return cancelBooking(_that.bookingId);case _ConfirmBooking() when confirmBooking != null:
return confirmBooking(_that.bookingId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String businessId)  loadBusinessBookings,required TResult Function( String userId)  loadUserBookings,required TResult Function( BookingModel booking)  createBooking,required TResult Function( String bookingId)  cancelBooking,required TResult Function( String bookingId)  confirmBooking,}) {final _that = this;
switch (_that) {
case _LoadBusinessBookings():
return loadBusinessBookings(_that.businessId);case _LoadUserBookings():
return loadUserBookings(_that.userId);case _CreateBooking():
return createBooking(_that.booking);case _CancelBooking():
return cancelBooking(_that.bookingId);case _ConfirmBooking():
return confirmBooking(_that.bookingId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String businessId)?  loadBusinessBookings,TResult? Function( String userId)?  loadUserBookings,TResult? Function( BookingModel booking)?  createBooking,TResult? Function( String bookingId)?  cancelBooking,TResult? Function( String bookingId)?  confirmBooking,}) {final _that = this;
switch (_that) {
case _LoadBusinessBookings() when loadBusinessBookings != null:
return loadBusinessBookings(_that.businessId);case _LoadUserBookings() when loadUserBookings != null:
return loadUserBookings(_that.userId);case _CreateBooking() when createBooking != null:
return createBooking(_that.booking);case _CancelBooking() when cancelBooking != null:
return cancelBooking(_that.bookingId);case _ConfirmBooking() when confirmBooking != null:
return confirmBooking(_that.bookingId);case _:
  return null;

}
}

}

/// @nodoc


class _LoadBusinessBookings implements BookingEvent {
  const _LoadBusinessBookings(this.businessId);
  

 final  String businessId;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadBusinessBookingsCopyWith<_LoadBusinessBookings> get copyWith => __$LoadBusinessBookingsCopyWithImpl<_LoadBusinessBookings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadBusinessBookings&&(identical(other.businessId, businessId) || other.businessId == businessId));
}


@override
int get hashCode => Object.hash(runtimeType,businessId);

@override
String toString() {
  return 'BookingEvent.loadBusinessBookings(businessId: $businessId)';
}


}

/// @nodoc
abstract mixin class _$LoadBusinessBookingsCopyWith<$Res> implements $BookingEventCopyWith<$Res> {
  factory _$LoadBusinessBookingsCopyWith(_LoadBusinessBookings value, $Res Function(_LoadBusinessBookings) _then) = __$LoadBusinessBookingsCopyWithImpl;
@useResult
$Res call({
 String businessId
});




}
/// @nodoc
class __$LoadBusinessBookingsCopyWithImpl<$Res>
    implements _$LoadBusinessBookingsCopyWith<$Res> {
  __$LoadBusinessBookingsCopyWithImpl(this._self, this._then);

  final _LoadBusinessBookings _self;
  final $Res Function(_LoadBusinessBookings) _then;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? businessId = null,}) {
  return _then(_LoadBusinessBookings(
null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _LoadUserBookings implements BookingEvent {
  const _LoadUserBookings(this.userId);
  

 final  String userId;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadUserBookingsCopyWith<_LoadUserBookings> get copyWith => __$LoadUserBookingsCopyWithImpl<_LoadUserBookings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadUserBookings&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'BookingEvent.loadUserBookings(userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$LoadUserBookingsCopyWith<$Res> implements $BookingEventCopyWith<$Res> {
  factory _$LoadUserBookingsCopyWith(_LoadUserBookings value, $Res Function(_LoadUserBookings) _then) = __$LoadUserBookingsCopyWithImpl;
@useResult
$Res call({
 String userId
});




}
/// @nodoc
class __$LoadUserBookingsCopyWithImpl<$Res>
    implements _$LoadUserBookingsCopyWith<$Res> {
  __$LoadUserBookingsCopyWithImpl(this._self, this._then);

  final _LoadUserBookings _self;
  final $Res Function(_LoadUserBookings) _then;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(_LoadUserBookings(
null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _CreateBooking implements BookingEvent {
  const _CreateBooking(this.booking);
  

 final  BookingModel booking;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateBookingCopyWith<_CreateBooking> get copyWith => __$CreateBookingCopyWithImpl<_CreateBooking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateBooking&&(identical(other.booking, booking) || other.booking == booking));
}


@override
int get hashCode => Object.hash(runtimeType,booking);

@override
String toString() {
  return 'BookingEvent.createBooking(booking: $booking)';
}


}

/// @nodoc
abstract mixin class _$CreateBookingCopyWith<$Res> implements $BookingEventCopyWith<$Res> {
  factory _$CreateBookingCopyWith(_CreateBooking value, $Res Function(_CreateBooking) _then) = __$CreateBookingCopyWithImpl;
@useResult
$Res call({
 BookingModel booking
});


$BookingModelCopyWith<$Res> get booking;

}
/// @nodoc
class __$CreateBookingCopyWithImpl<$Res>
    implements _$CreateBookingCopyWith<$Res> {
  __$CreateBookingCopyWithImpl(this._self, this._then);

  final _CreateBooking _self;
  final $Res Function(_CreateBooking) _then;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? booking = null,}) {
  return _then(_CreateBooking(
null == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as BookingModel,
  ));
}

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingModelCopyWith<$Res> get booking {
  
  return $BookingModelCopyWith<$Res>(_self.booking, (value) {
    return _then(_self.copyWith(booking: value));
  });
}
}

/// @nodoc


class _CancelBooking implements BookingEvent {
  const _CancelBooking(this.bookingId);
  

 final  String bookingId;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelBookingCopyWith<_CancelBooking> get copyWith => __$CancelBookingCopyWithImpl<_CancelBooking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelBooking&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId));
}


@override
int get hashCode => Object.hash(runtimeType,bookingId);

@override
String toString() {
  return 'BookingEvent.cancelBooking(bookingId: $bookingId)';
}


}

/// @nodoc
abstract mixin class _$CancelBookingCopyWith<$Res> implements $BookingEventCopyWith<$Res> {
  factory _$CancelBookingCopyWith(_CancelBooking value, $Res Function(_CancelBooking) _then) = __$CancelBookingCopyWithImpl;
@useResult
$Res call({
 String bookingId
});




}
/// @nodoc
class __$CancelBookingCopyWithImpl<$Res>
    implements _$CancelBookingCopyWith<$Res> {
  __$CancelBookingCopyWithImpl(this._self, this._then);

  final _CancelBooking _self;
  final $Res Function(_CancelBooking) _then;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bookingId = null,}) {
  return _then(_CancelBooking(
null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ConfirmBooking implements BookingEvent {
  const _ConfirmBooking(this.bookingId);
  

 final  String bookingId;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmBookingCopyWith<_ConfirmBooking> get copyWith => __$ConfirmBookingCopyWithImpl<_ConfirmBooking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmBooking&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId));
}


@override
int get hashCode => Object.hash(runtimeType,bookingId);

@override
String toString() {
  return 'BookingEvent.confirmBooking(bookingId: $bookingId)';
}


}

/// @nodoc
abstract mixin class _$ConfirmBookingCopyWith<$Res> implements $BookingEventCopyWith<$Res> {
  factory _$ConfirmBookingCopyWith(_ConfirmBooking value, $Res Function(_ConfirmBooking) _then) = __$ConfirmBookingCopyWithImpl;
@useResult
$Res call({
 String bookingId
});




}
/// @nodoc
class __$ConfirmBookingCopyWithImpl<$Res>
    implements _$ConfirmBookingCopyWith<$Res> {
  __$ConfirmBookingCopyWithImpl(this._self, this._then);

  final _ConfirmBooking _self;
  final $Res Function(_ConfirmBooking) _then;

/// Create a copy of BookingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bookingId = null,}) {
  return _then(_ConfirmBooking(
null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$BookingState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BookingState()';
}


}

/// @nodoc
class $BookingStateCopyWith<$Res>  {
$BookingStateCopyWith(BookingState _, $Res Function(BookingState) __);
}


/// Adds pattern-matching-related methods to [BookingState].
extension BookingStatePatterns on BookingState {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<BookingModel> bookings)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.bookings);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<BookingModel> bookings)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.bookings);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<BookingModel> bookings)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.bookings);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements BookingState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BookingState.initial()';
}


}




/// @nodoc


class _Loading implements BookingState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BookingState.loading()';
}


}




/// @nodoc


class _Loaded implements BookingState {
  const _Loaded(final  List<BookingModel> bookings): _bookings = bookings;
  

 final  List<BookingModel> _bookings;
 List<BookingModel> get bookings {
  if (_bookings is EqualUnmodifiableListView) return _bookings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookings);
}


/// Create a copy of BookingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._bookings, _bookings));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bookings));

@override
String toString() {
  return 'BookingState.loaded(bookings: $bookings)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $BookingStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<BookingModel> bookings
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of BookingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bookings = null,}) {
  return _then(_Loaded(
null == bookings ? _self._bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<BookingModel>,
  ));
}


}

/// @nodoc


class _Error implements BookingState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of BookingState
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
  return 'BookingState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $BookingStateCopyWith<$Res> {
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

/// Create a copy of BookingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
