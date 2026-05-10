part of 'booking_bloc.dart';

@freezed
sealed class BookingState with _$BookingState {
  const factory BookingState.initial() = _Initial;
  const factory BookingState.loading() = _Loading;
  const factory BookingState.loaded(List<BookingModel> bookings) = _Loaded;
  const factory BookingState.error(String message) = _Error;
}
