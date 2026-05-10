part of 'booking_bloc.dart';

@freezed
sealed class BookingEvent with _$BookingEvent {
  const factory BookingEvent.loadBusinessBookings(String businessId) = _LoadBusinessBookings;
  const factory BookingEvent.loadUserBookings(String userId) = _LoadUserBookings;
  const factory BookingEvent.createBooking(BookingModel booking) = _CreateBooking;
  const factory BookingEvent.cancelBooking(String bookingId) = _CancelBooking;
  const factory BookingEvent.confirmBooking(String bookingId) = _ConfirmBooking;
}
