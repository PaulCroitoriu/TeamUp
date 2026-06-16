import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/dashboard/shared.dart';

class DayStats {
  const DayStats({
    required this.bookedCount,
    required this.pendingCount,
    required this.revenueRon,
    required this.occupancy,
    required this.openHours,
    required this.bookedHours,
  });
  final int bookedCount;
  final int pendingCount;
  final int revenueRon;

  /// Booked-hours / open-hours ratio in [0, 1].
  final double occupancy;
  final int openHours;
  final int bookedHours;
}

DayStats computeStats({
  required List<BookingModel> bookings,
  required List<PitchModel> pitches,
  required Map<String, VenueModel> venues,
  required DateTime day,
}) {
  var booked = 0;
  var pending = 0;
  var revenue = 0;
  var bookedHours = 0;
  for (final b in bookings) {
    if (b.status == BookingStatus.cancelled) continue;
    booked++;
    if (b.status == BookingStatus.pending) pending++;
    if (b.status == BookingStatus.confirmed) revenue += b.pricePaid ~/ 100;
    bookedHours += b.endTime.difference(b.startTime).inMinutes ~/ 60;
  }
  var openHours = 0;
  for (final p in pitches) {
    final win = openingWindow(venues[p.venueId], day);
    if (!win.closed) openHours += (win.closeH - win.openH);
  }
  final occupancy = openHours == 0 ? 0.0 : (bookedHours / openHours).clamp(0.0, 1.0);
  return DayStats(
    bookedCount: booked,
    pendingCount: pending,
    revenueRon: revenue,
    occupancy: occupancy,
    openHours: openHours,
    bookedHours: bookedHours,
  );
}

Map<String, int> revenuePerVenue(List<BookingModel> bookings) {
  final out = <String, int>{};
  for (final b in bookings) {
    if (b.status != BookingStatus.confirmed) continue;
    out[b.venueId] = (out[b.venueId] ?? 0) + (b.pricePaid ~/ 100);
  }
  return out;
}
