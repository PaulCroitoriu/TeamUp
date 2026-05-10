import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/firebase/firestore.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';

class BookingConflictException implements Exception {
  const BookingConflictException(this.message);
  final String message;

  @override
  String toString() => 'BookingConflictException: $message';
}

class BookingService {
  BookingService({FirebaseFirestore? firestore}) : _firestore = firestore ?? db;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref => _firestore.collection('bookings');

  /// Stream the current user's bookings, most recent first.
  Stream<List<BookingModel>> streamUserBookings(String userId) {
    return _ref
        .where('bookerId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Stream all bookings for a business (across its venues), upcoming first.
  Stream<List<BookingModel>> streamBusinessBookings(String businessId) {
    return _ref
        .where('businessId', isEqualTo: businessId)
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Stream bookings for a single pitch on a given local day — used for
  /// availability checks in the booking UI.
  Stream<List<BookingModel>> streamPitchBookingsForDay(String pitchId, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _ref
        .where('pitchId', isEqualTo: pitchId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('startTime', isLessThan: Timestamp.fromDate(dayEnd))
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  Future<BookingModel> getBooking(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) throw Exception('Booking not found: $id');
    return BookingModel.fromFirestore(doc);
  }

  Stream<BookingModel> streamBooking(String id) {
    return _ref.doc(id).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Booking not found: $id');
      return BookingModel.fromFirestore(doc);
    });
  }

  /// Create a booking, refusing if a non-cancelled booking already overlaps
  /// the requested slot on the same pitch. Bookings are the source of truth
  /// for slot occupancy, so the overlap check runs inside a transaction.
  Future<BookingModel> createBooking(BookingModel booking) async {
    if (!booking.endTime.isAfter(booking.startTime)) {
      throw ArgumentError('endTime must be after startTime');
    }

    final docRef = _ref.doc();
    final created = booking.copyWith(id: docRef.id);

    await _firestore.runTransaction((txn) async {
      // Firestore range queries are limited to one field, so we fetch any
      // booking on this pitch that *starts* before our slot ends, then
      // filter overlaps client-side inside the transaction.
      final candidates = await _ref
          .where('pitchId', isEqualTo: created.pitchId)
          .where('startTime', isLessThan: Timestamp.fromDate(created.endTime))
          .get();

      final conflict = candidates.docs
          .map(BookingModel.fromFirestore)
          .where((b) => b.status != BookingStatus.cancelled)
          .any((b) => b.endTime.isAfter(created.startTime));

      if (conflict) {
        throw const BookingConflictException('This slot overlaps an existing booking.');
      }

      txn.set(docRef, created.toJson());
    });

    return created;
  }

  Future<void> cancelBooking(String id) {
    return _ref.doc(id).update({'status': BookingStatus.cancelled.name});
  }

  Future<void> confirmBooking(String id) {
    return _ref.doc(id).update({'status': BookingStatus.confirmed.name});
  }
}
