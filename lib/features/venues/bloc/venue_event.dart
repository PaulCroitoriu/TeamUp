part of 'venue_bloc.dart';

@freezed
sealed class VenueEvent with _$VenueEvent {
  const factory VenueEvent.loadBusinessVenues(String businessId) =
      _LoadBusinessVenues;
  const factory VenueEvent.createVenue(VenueModel venue) = _CreateVenue;
  const factory VenueEvent.updateVenue(VenueModel venue) = _UpdateVenue;
}
