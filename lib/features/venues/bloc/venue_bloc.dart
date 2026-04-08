import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

part 'venue_bloc.freezed.dart';
part 'venue_event.dart';
part 'venue_state.dart';

class VenueBloc extends Bloc<VenueEvent, VenueState> {
  VenueBloc({required VenueService venueService})
      : _venueService = venueService,
        super(const VenueState.initial()) {
    on<_LoadBusinessVenues>(_onLoad);
    on<_CreateVenue>(_onCreate);
    on<_UpdateVenue>(_onUpdate);
  }

  final VenueService _venueService;

  Future<void> _onLoad(
    _LoadBusinessVenues event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueState.loading());
    await emit.forEach<List<VenueModel>>(
      _venueService.streamBusinessVenues(event.businessId),
      onData: (venues) => VenueState.loaded(venues),
      onError: (e, _) => VenueState.error(e.toString()),
    );
  }

  Future<void> _onCreate(
    _CreateVenue event,
    Emitter<VenueState> emit,
  ) async {
    try {
      await _venueService.createVenue(event.venue);
    } on Exception catch (e) {
      emit(VenueState.error(e.toString()));
    }
  }

  Future<void> _onUpdate(
    _UpdateVenue event,
    Emitter<VenueState> emit,
  ) async {
    try {
      await _venueService.updateVenue(event.venue);
    } on Exception catch (e) {
      emit(VenueState.error(e.toString()));
    }
  }
}
