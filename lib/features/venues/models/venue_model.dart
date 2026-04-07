import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'venue_model.freezed.dart';
part 'venue_model.g.dart';

@freezed
abstract class VenueModel with _$VenueModel {
  const factory VenueModel({
    required String id,
    required String businessId,
    required String name,
    required String address,
    required String city,
    @GeoPointConverter() required GeoPoint location,
    String? phone,
    String? description,
    String? imageUrl,
    @Default([]) List<String> sports,
    @Default([]) List<String> amenities,
    @Default(true) bool active,
    @TimestampConverter() required DateTime createdAt,
  }) = _VenueModel;

  factory VenueModel.fromJson(Map<String, dynamic> json) =>
      _$VenueModelFromJson(json);

  factory VenueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return VenueModel.fromJson({'id': doc.id, ...data});
  }
}

class GeoPointConverter implements JsonConverter<GeoPoint, dynamic> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(dynamic json) {
    if (json is GeoPoint) return json;
    if (json is Map<String, dynamic>) {
      return GeoPoint(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      );
    }
    return const GeoPoint(0, 0);
  }

  @override
  Map<String, dynamic> toJson(GeoPoint geoPoint) => {
        'latitude': geoPoint.latitude,
        'longitude': geoPoint.longitude,
      };
}
