// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingModel {

 String get id; String get pitchId; String get venueId; String get businessId; String get bookerId;/// Set when the booking is tied to an open game; null for private bookings.
 String? get gameId;@TimestampConverter() DateTime get startTime;@TimestampConverter() DateTime get endTime;/// Total price in the smallest currency unit (e.g. cents / bani).
 int get pricePaid; String get currency; BookingStatus get status;/// How the customer is paying. Cash bookings auto-confirm; card
/// bookings stay pending until the payment lands.
 PaymentMethod get paymentMethod;/// Captured when the booking was placed for someone else (ad-hoc /
/// phone caller). Stored on the booking so it's self-contained even
/// if the matched user record is later removed.
 String? get customerName; String? get customerPhone; String? get customerEmail;/// Set when the customer matched an existing user account in the
/// phone lookup. Useful for linking back later (sending receipts,
/// loyalty, etc).
 String? get customerUserId;/// Identifier shared by every booking in a recurring series. Lets
/// us delete or modify the series as a unit later.
 String? get recurrenceId;/// True for bookings that are part of a weekly repeat. A future job
/// uses this to roll the series forward and collect payment.
 bool get recurring; String? get notes;/// Set when the booking flips to confirmed (either by payment or by
/// the venue owner manually accepting).
@NullableTimestampConverter() DateTime? get confirmedAt;/// Set when payment lands. May be null even on confirmed bookings if
/// the owner accepted without payment.
@NullableTimestampConverter() DateTime? get paidAt;/// Set when the booking is cancelled.
@NullableTimestampConverter() DateTime? get cancelledAt;@TimestampConverter() DateTime get createdAt;
/// Create a copy of BookingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingModelCopyWith<BookingModel> get copyWith => _$BookingModelCopyWithImpl<BookingModel>(this as BookingModel, _$identity);

  /// Serializes this BookingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.pitchId, pitchId) || other.pitchId == pitchId)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.bookerId, bookerId) || other.bookerId == bookerId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.pricePaid, pricePaid) || other.pricePaid == pricePaid)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerUserId, customerUserId) || other.customerUserId == customerUserId)&&(identical(other.recurrenceId, recurrenceId) || other.recurrenceId == recurrenceId)&&(identical(other.recurring, recurring) || other.recurring == recurring)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,pitchId,venueId,businessId,bookerId,gameId,startTime,endTime,pricePaid,currency,status,paymentMethod,customerName,customerPhone,customerEmail,customerUserId,recurrenceId,recurring,notes,confirmedAt,paidAt,cancelledAt,createdAt]);

@override
String toString() {
  return 'BookingModel(id: $id, pitchId: $pitchId, venueId: $venueId, businessId: $businessId, bookerId: $bookerId, gameId: $gameId, startTime: $startTime, endTime: $endTime, pricePaid: $pricePaid, currency: $currency, status: $status, paymentMethod: $paymentMethod, customerName: $customerName, customerPhone: $customerPhone, customerEmail: $customerEmail, customerUserId: $customerUserId, recurrenceId: $recurrenceId, recurring: $recurring, notes: $notes, confirmedAt: $confirmedAt, paidAt: $paidAt, cancelledAt: $cancelledAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BookingModelCopyWith<$Res>  {
  factory $BookingModelCopyWith(BookingModel value, $Res Function(BookingModel) _then) = _$BookingModelCopyWithImpl;
@useResult
$Res call({
 String id, String pitchId, String venueId, String businessId, String bookerId, String? gameId,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, int pricePaid, String currency, BookingStatus status, PaymentMethod paymentMethod, String? customerName, String? customerPhone, String? customerEmail, String? customerUserId, String? recurrenceId, bool recurring, String? notes,@NullableTimestampConverter() DateTime? confirmedAt,@NullableTimestampConverter() DateTime? paidAt,@NullableTimestampConverter() DateTime? cancelledAt,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$BookingModelCopyWithImpl<$Res>
    implements $BookingModelCopyWith<$Res> {
  _$BookingModelCopyWithImpl(this._self, this._then);

  final BookingModel _self;
  final $Res Function(BookingModel) _then;

/// Create a copy of BookingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pitchId = null,Object? venueId = null,Object? businessId = null,Object? bookerId = null,Object? gameId = freezed,Object? startTime = null,Object? endTime = null,Object? pricePaid = null,Object? currency = null,Object? status = null,Object? paymentMethod = null,Object? customerName = freezed,Object? customerPhone = freezed,Object? customerEmail = freezed,Object? customerUserId = freezed,Object? recurrenceId = freezed,Object? recurring = null,Object? notes = freezed,Object? confirmedAt = freezed,Object? paidAt = freezed,Object? cancelledAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pitchId: null == pitchId ? _self.pitchId : pitchId // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,bookerId: null == bookerId ? _self.bookerId : bookerId // ignore: cast_nullable_to_non_nullable
as String,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,pricePaid: null == pricePaid ? _self.pricePaid : pricePaid // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerUserId: freezed == customerUserId ? _self.customerUserId : customerUserId // ignore: cast_nullable_to_non_nullable
as String?,recurrenceId: freezed == recurrenceId ? _self.recurrenceId : recurrenceId // ignore: cast_nullable_to_non_nullable
as String?,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingModel].
extension BookingModelPatterns on BookingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingModel value)  $default,){
final _that = this;
switch (_that) {
case _BookingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingModel value)?  $default,){
final _that = this;
switch (_that) {
case _BookingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String pitchId,  String venueId,  String businessId,  String bookerId,  String? gameId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  int pricePaid,  String currency,  BookingStatus status,  PaymentMethod paymentMethod,  String? customerName,  String? customerPhone,  String? customerEmail,  String? customerUserId,  String? recurrenceId,  bool recurring,  String? notes, @NullableTimestampConverter()  DateTime? confirmedAt, @NullableTimestampConverter()  DateTime? paidAt, @NullableTimestampConverter()  DateTime? cancelledAt, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingModel() when $default != null:
return $default(_that.id,_that.pitchId,_that.venueId,_that.businessId,_that.bookerId,_that.gameId,_that.startTime,_that.endTime,_that.pricePaid,_that.currency,_that.status,_that.paymentMethod,_that.customerName,_that.customerPhone,_that.customerEmail,_that.customerUserId,_that.recurrenceId,_that.recurring,_that.notes,_that.confirmedAt,_that.paidAt,_that.cancelledAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String pitchId,  String venueId,  String businessId,  String bookerId,  String? gameId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  int pricePaid,  String currency,  BookingStatus status,  PaymentMethod paymentMethod,  String? customerName,  String? customerPhone,  String? customerEmail,  String? customerUserId,  String? recurrenceId,  bool recurring,  String? notes, @NullableTimestampConverter()  DateTime? confirmedAt, @NullableTimestampConverter()  DateTime? paidAt, @NullableTimestampConverter()  DateTime? cancelledAt, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BookingModel():
return $default(_that.id,_that.pitchId,_that.venueId,_that.businessId,_that.bookerId,_that.gameId,_that.startTime,_that.endTime,_that.pricePaid,_that.currency,_that.status,_that.paymentMethod,_that.customerName,_that.customerPhone,_that.customerEmail,_that.customerUserId,_that.recurrenceId,_that.recurring,_that.notes,_that.confirmedAt,_that.paidAt,_that.cancelledAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String pitchId,  String venueId,  String businessId,  String bookerId,  String? gameId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  int pricePaid,  String currency,  BookingStatus status,  PaymentMethod paymentMethod,  String? customerName,  String? customerPhone,  String? customerEmail,  String? customerUserId,  String? recurrenceId,  bool recurring,  String? notes, @NullableTimestampConverter()  DateTime? confirmedAt, @NullableTimestampConverter()  DateTime? paidAt, @NullableTimestampConverter()  DateTime? cancelledAt, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BookingModel() when $default != null:
return $default(_that.id,_that.pitchId,_that.venueId,_that.businessId,_that.bookerId,_that.gameId,_that.startTime,_that.endTime,_that.pricePaid,_that.currency,_that.status,_that.paymentMethod,_that.customerName,_that.customerPhone,_that.customerEmail,_that.customerUserId,_that.recurrenceId,_that.recurring,_that.notes,_that.confirmedAt,_that.paidAt,_that.cancelledAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingModel implements BookingModel {
  const _BookingModel({required this.id, required this.pitchId, required this.venueId, required this.businessId, required this.bookerId, this.gameId, @TimestampConverter() required this.startTime, @TimestampConverter() required this.endTime, required this.pricePaid, this.currency = 'RON', this.status = BookingStatus.pending, this.paymentMethod = PaymentMethod.card, this.customerName, this.customerPhone, this.customerEmail, this.customerUserId, this.recurrenceId, this.recurring = false, this.notes, @NullableTimestampConverter() this.confirmedAt, @NullableTimestampConverter() this.paidAt, @NullableTimestampConverter() this.cancelledAt, @TimestampConverter() required this.createdAt});
  factory _BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);

@override final  String id;
@override final  String pitchId;
@override final  String venueId;
@override final  String businessId;
@override final  String bookerId;
/// Set when the booking is tied to an open game; null for private bookings.
@override final  String? gameId;
@override@TimestampConverter() final  DateTime startTime;
@override@TimestampConverter() final  DateTime endTime;
/// Total price in the smallest currency unit (e.g. cents / bani).
@override final  int pricePaid;
@override@JsonKey() final  String currency;
@override@JsonKey() final  BookingStatus status;
/// How the customer is paying. Cash bookings auto-confirm; card
/// bookings stay pending until the payment lands.
@override@JsonKey() final  PaymentMethod paymentMethod;
/// Captured when the booking was placed for someone else (ad-hoc /
/// phone caller). Stored on the booking so it's self-contained even
/// if the matched user record is later removed.
@override final  String? customerName;
@override final  String? customerPhone;
@override final  String? customerEmail;
/// Set when the customer matched an existing user account in the
/// phone lookup. Useful for linking back later (sending receipts,
/// loyalty, etc).
@override final  String? customerUserId;
/// Identifier shared by every booking in a recurring series. Lets
/// us delete or modify the series as a unit later.
@override final  String? recurrenceId;
/// True for bookings that are part of a weekly repeat. A future job
/// uses this to roll the series forward and collect payment.
@override@JsonKey() final  bool recurring;
@override final  String? notes;
/// Set when the booking flips to confirmed (either by payment or by
/// the venue owner manually accepting).
@override@NullableTimestampConverter() final  DateTime? confirmedAt;
/// Set when payment lands. May be null even on confirmed bookings if
/// the owner accepted without payment.
@override@NullableTimestampConverter() final  DateTime? paidAt;
/// Set when the booking is cancelled.
@override@NullableTimestampConverter() final  DateTime? cancelledAt;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of BookingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingModelCopyWith<_BookingModel> get copyWith => __$BookingModelCopyWithImpl<_BookingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.pitchId, pitchId) || other.pitchId == pitchId)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.bookerId, bookerId) || other.bookerId == bookerId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.pricePaid, pricePaid) || other.pricePaid == pricePaid)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerUserId, customerUserId) || other.customerUserId == customerUserId)&&(identical(other.recurrenceId, recurrenceId) || other.recurrenceId == recurrenceId)&&(identical(other.recurring, recurring) || other.recurring == recurring)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,pitchId,venueId,businessId,bookerId,gameId,startTime,endTime,pricePaid,currency,status,paymentMethod,customerName,customerPhone,customerEmail,customerUserId,recurrenceId,recurring,notes,confirmedAt,paidAt,cancelledAt,createdAt]);

@override
String toString() {
  return 'BookingModel(id: $id, pitchId: $pitchId, venueId: $venueId, businessId: $businessId, bookerId: $bookerId, gameId: $gameId, startTime: $startTime, endTime: $endTime, pricePaid: $pricePaid, currency: $currency, status: $status, paymentMethod: $paymentMethod, customerName: $customerName, customerPhone: $customerPhone, customerEmail: $customerEmail, customerUserId: $customerUserId, recurrenceId: $recurrenceId, recurring: $recurring, notes: $notes, confirmedAt: $confirmedAt, paidAt: $paidAt, cancelledAt: $cancelledAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookingModelCopyWith<$Res> implements $BookingModelCopyWith<$Res> {
  factory _$BookingModelCopyWith(_BookingModel value, $Res Function(_BookingModel) _then) = __$BookingModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String pitchId, String venueId, String businessId, String bookerId, String? gameId,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, int pricePaid, String currency, BookingStatus status, PaymentMethod paymentMethod, String? customerName, String? customerPhone, String? customerEmail, String? customerUserId, String? recurrenceId, bool recurring, String? notes,@NullableTimestampConverter() DateTime? confirmedAt,@NullableTimestampConverter() DateTime? paidAt,@NullableTimestampConverter() DateTime? cancelledAt,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$BookingModelCopyWithImpl<$Res>
    implements _$BookingModelCopyWith<$Res> {
  __$BookingModelCopyWithImpl(this._self, this._then);

  final _BookingModel _self;
  final $Res Function(_BookingModel) _then;

/// Create a copy of BookingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pitchId = null,Object? venueId = null,Object? businessId = null,Object? bookerId = null,Object? gameId = freezed,Object? startTime = null,Object? endTime = null,Object? pricePaid = null,Object? currency = null,Object? status = null,Object? paymentMethod = null,Object? customerName = freezed,Object? customerPhone = freezed,Object? customerEmail = freezed,Object? customerUserId = freezed,Object? recurrenceId = freezed,Object? recurring = null,Object? notes = freezed,Object? confirmedAt = freezed,Object? paidAt = freezed,Object? cancelledAt = freezed,Object? createdAt = null,}) {
  return _then(_BookingModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pitchId: null == pitchId ? _self.pitchId : pitchId // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,bookerId: null == bookerId ? _self.bookerId : bookerId // ignore: cast_nullable_to_non_nullable
as String,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,pricePaid: null == pricePaid ? _self.pricePaid : pricePaid // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerUserId: freezed == customerUserId ? _self.customerUserId : customerUserId // ignore: cast_nullable_to_non_nullable
as String?,recurrenceId: freezed == recurrenceId ? _self.recurrenceId : recurrenceId // ignore: cast_nullable_to_non_nullable
as String?,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
