import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';

part 'booking_bloc.freezed.dart';
part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({required BookingService bookingService}) : _bookingService = bookingService, super(const BookingState.initial()) {
    on<_LoadBusinessBookings>(_onLoadBusiness);
    on<_LoadUserBookings>(_onLoadUser);
    on<_CreateBooking>(_onCreate);
    on<_CancelBooking>(_onCancel);
    on<_ConfirmBooking>(_onConfirm);
  }

  final BookingService _bookingService;

  Future<void> _onLoadBusiness(_LoadBusinessBookings event, Emitter<BookingState> emit) async {
    emit(const BookingState.loading());
    await emit.forEach<List<BookingModel>>(
      _bookingService.streamBusinessBookings(event.businessId),
      onData: (bookings) => BookingState.loaded(bookings),
      onError: (e, _) => BookingState.error(e.toString()),
    );
  }

  Future<void> _onLoadUser(_LoadUserBookings event, Emitter<BookingState> emit) async {
    emit(const BookingState.loading());
    await emit.forEach<List<BookingModel>>(
      _bookingService.streamUserBookings(event.userId),
      onData: (bookings) => BookingState.loaded(bookings),
      onError: (e, _) => BookingState.error(e.toString()),
    );
  }

  Future<void> _onCreate(_CreateBooking event, Emitter<BookingState> emit) async {
    try {
      await _bookingService.createBooking(event.booking);
    } on Exception catch (e) {
      emit(BookingState.error(e.toString()));
    }
  }

  Future<void> _onCancel(_CancelBooking event, Emitter<BookingState> emit) async {
    try {
      await _bookingService.cancelBooking(event.bookingId);
    } on Exception catch (e) {
      emit(BookingState.error(e.toString()));
    }
  }

  Future<void> _onConfirm(_ConfirmBooking event, Emitter<BookingState> emit) async {
    try {
      await _bookingService.confirmBooking(event.bookingId);
    } on Exception catch (e) {
      emit(BookingState.error(e.toString()));
    }
  }
}
