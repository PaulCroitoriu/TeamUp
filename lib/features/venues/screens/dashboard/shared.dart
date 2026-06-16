import 'package:teamup/features/venues/models/venue_model.dart';

const kMobileBreakpoint = 600.0;
const kHourCount = 24;
const kWeekdayKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String two(int n) => n.toString().padLeft(2, '0');

class OpeningWindow {
  const OpeningWindow({required this.closed, required this.openH, required this.closeH});
  final bool closed;
  final int openH;
  final int closeH;
}

OpeningWindow openingWindow(VenueModel? venue, DateTime day) {
  if (venue == null) return const OpeningWindow(closed: true, openH: 0, closeH: 0);
  final hours = venue.openingHours[kWeekdayKeys[day.weekday - 1]];
  if (hours == null || hours.closed) return const OpeningWindow(closed: true, openH: 0, closeH: 0);
  final openH = int.tryParse(hours.open.split(':').first) ?? 0;
  var closeH = int.tryParse(hours.close.split(':').first) ?? kHourCount;
  if (closeH == 0) closeH = kHourCount; // midnight close → end of day
  return OpeningWindow(closed: false, openH: openH, closeH: closeH);
}
