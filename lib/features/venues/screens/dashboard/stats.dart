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

/// Telemetry window. Day is the default; month/year aggregate the whole period.
enum StatsPeriod { day, month, year }

/// Half-open [start, end) range covering the [period] containing [anchor].
(DateTime, DateTime) periodRange(StatsPeriod period, DateTime anchor) {
  final a = DateTime(anchor.year, anchor.month, anchor.day);
  switch (period) {
    case StatsPeriod.day:
      return (a, a.add(const Duration(days: 1)));
    case StatsPeriod.month:
      return (DateTime(a.year, a.month, 1), DateTime(a.year, a.month + 1, 1));
    case StatsPeriod.year:
      return (DateTime(a.year, 1, 1), DateTime(a.year + 1, 1, 1));
  }
}

/// Occupancy + revenue across [start, end) — booked hours over the open hours
/// of every pitch on every day in the window.
DayStats computeRangeStats({
  required List<BookingModel> bookings,
  required List<PitchModel> pitches,
  required Map<String, VenueModel> venues,
  required DateTime start,
  required DateTime end,
}) {
  var booked = 0;
  var pending = 0;
  var revenue = 0;
  var bookedHours = 0;
  for (final b in bookings) {
    if (b.status == BookingStatus.cancelled) continue;
    if (b.startTime.isBefore(start) || !b.startTime.isBefore(end)) continue;
    booked++;
    if (b.status == BookingStatus.pending) pending++;
    if (b.status == BookingStatus.confirmed) revenue += b.pricePaid ~/ 100;
    bookedHours += b.endTime.difference(b.startTime).inMinutes ~/ 60;
  }
  var openHours = 0;
  // Iterate by day index (DST-safe day stepping via DateTime normalisation).
  for (var i = 0; ; i++) {
    final d = DateTime(start.year, start.month, start.day + i);
    if (!d.isBefore(end)) break;
    for (final p in pitches) {
      final win = openingWindow(venues[p.venueId], d);
      if (!win.closed) openHours += (win.closeH - win.openH);
    }
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
