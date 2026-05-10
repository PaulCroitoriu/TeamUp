import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/firebase/firestore.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

class VenueService {
  VenueService({FirebaseFirestore? firestore}) : _firestore = firestore ?? db;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _venuesRef => _firestore.collection('venues');

  CollectionReference<Map<String, dynamic>> _pitchesRef(String venueId) => _venuesRef.doc(venueId).collection('pitches');

  // ─── Venues ────────────────────────────────────────────────

  /// Stream all active venues (for explore).
  Stream<List<VenueModel>> streamVenues() {
    return _venuesRef.where('active', isEqualTo: true).snapshots().map((snap) => snap.docs.map(VenueModel.fromFirestore).toList());
  }

  /// Stream active venues offering a specific sport. The venue's `sports`
  /// array is denormalised from its pitches so this is a single query.
  Stream<List<VenueModel>> streamVenuesBySport(Sport sport) {
    return _venuesRef
        .where('active', isEqualTo: true)
        .where('sports', arrayContains: sport.name)
        .snapshots()
        .map((snap) => snap.docs.map(VenueModel.fromFirestore).toList());
  }

  /// Stream venues belonging to a specific business.
  Stream<List<VenueModel>> streamBusinessVenues(String businessId) {
    return _venuesRef.where('businessId', isEqualTo: businessId).snapshots().map((snap) => snap.docs.map(VenueModel.fromFirestore).toList());
  }

  /// Get a single venue by ID.
  Future<VenueModel> getVenue(String venueId) async {
    final doc = await _venuesRef.doc(venueId).get();
    if (!doc.exists) throw Exception('Venue not found: $venueId');
    return VenueModel.fromFirestore(doc);
  }

  /// Create a new venue. Returns the created model with its generated ID.
  Future<VenueModel> createVenue(VenueModel venue) async {
    final doc = _venuesRef.doc();
    final created = venue.copyWith(id: doc.id);
    await doc.set(created.toJson());
    return created;
  }

  /// Update an existing venue.
  Future<void> updateVenue(VenueModel venue) async {
    await _venuesRef.doc(venue.id).update(venue.toJson());
  }

  // ─── Pitches ───────────────────────────────────────────────

  /// Stream all active pitches for a venue.
  Stream<List<PitchModel>> streamPitches(String venueId) {
    return _pitchesRef(venueId).where('active', isEqualTo: true).snapshots().map((snap) => snap.docs.map(PitchModel.fromFirestore).toList());
  }

  /// Stream every active pitch across all venues, optionally filtered by sport.
  /// Uses a Firestore collectionGroup query — pitches are subcollections, so
  /// this is the only way to fan out without venue-by-venue reads.
  Stream<List<PitchModel>> streamPitchesAcrossVenues({Sport? sport}) {
    Query<Map<String, dynamic>> q = _firestore.collectionGroup('pitches').where('active', isEqualTo: true);
    if (sport != null) {
      q = q.where('sport', isEqualTo: sport.name);
    }
    return q.snapshots().map((snap) => snap.docs.map(PitchModel.fromFirestore).toList());
  }

  /// Stream all pitches (active + inactive) for venue management.
  Stream<List<PitchModel>> streamAllPitches(String venueId) {
    return _pitchesRef(venueId).snapshots().map((snap) => snap.docs.map(PitchModel.fromFirestore).toList());
  }

  /// Toggle a pitch's active status.
  Future<void> togglePitchActive(String venueId, String pitchId, bool active) {
    return _pitchesRef(venueId).doc(pitchId).update({'active': active});
  }

  /// Get a single pitch.
  Future<PitchModel> getPitch(String venueId, String pitchId) async {
    final doc = await _pitchesRef(venueId).doc(pitchId).get();
    if (!doc.exists) throw Exception('Pitch not found: $pitchId');
    return PitchModel.fromFirestore(doc);
  }

  /// Create a new pitch under a venue.
  Future<PitchModel> createPitch(String venueId, PitchModel pitch) async {
    final doc = _pitchesRef(venueId).doc();
    final created = pitch.copyWith(id: doc.id);
    await doc.set(created.toJson());
    return created;
  }

  /// Update an existing pitch.
  Future<void> updatePitch(String venueId, PitchModel pitch) async {
    await _pitchesRef(venueId).doc(pitch.id).update(pitch.toJson());
  }
}
