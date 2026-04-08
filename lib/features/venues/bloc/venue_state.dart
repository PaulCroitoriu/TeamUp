part of 'venue_bloc.dart';

@freezed
sealed class VenueState with _$VenueState {
  const factory VenueState.initial() = _Initial;
  const factory VenueState.loading() = _Loading;
  const factory VenueState.loaded(List<VenueModel> venues) = _Loaded;
  const factory VenueState.error(String message) = _Error;
}
