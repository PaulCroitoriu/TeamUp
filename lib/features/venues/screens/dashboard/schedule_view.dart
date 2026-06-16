import 'package:flutter/material.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/dashboard/shared.dart';
import 'package:teamup/features/venues/screens/dashboard/stats.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/available_now_card.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/date_strip.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/epg_schedule.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/kpi_cards.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/section.dart';

/// Dashboard body for one venue. Layout priority:
///   Date strip → Schedule (the main thing) → KPIs / Available now beneath.
class ScheduleView extends StatelessWidget {
  const ScheduleView({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.venuesById,
    required this.venuePitches,
    required this.venueDayBookings,
    required this.bookingsLoading,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final Map<String, VenueModel> venuesById;
  final List<PitchModel> venuePitches;
  final List<BookingModel> venueDayBookings;
  final bool bookingsLoading;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < kMobileBreakpoint;
    final hPad = isMobile ? 14.0 : 24.0;
    final isToday = sameDay(selectedDay, DateTime.now());

    final stats = computeStats(
      bookings: venueDayBookings,
      pitches: venuePitches,
      venues: venuesById,
      day: selectedDay,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1360),
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, isMobile ? 12 : 20, hPad, isMobile ? 28 : 40),
          children: [
            DateStrip(selected: selectedDay, onSelected: onDaySelected),
            const SizedBox(height: 16),
            if (venuePitches.isEmpty)
              Section(
                title: 'Schedule',
                titleIcon: Icons.tv_rounded,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('This venue has no active pitches yet')),
                ),
              )
            else
              Section(
                title: isToday ? 'Today’s schedule' : 'Schedule',
                titleIcon: Icons.tv_rounded,
                action: _LegendDots(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: EpgSchedule(
                  pitches: venuePitches,
                  venues: venuesById,
                  bookings: venueDayBookings,
                  day: selectedDay,
                ),
              ),
            const SizedBox(height: 18),
            KpiCardsRow(stats: stats),
            if (isToday) ...[
              const SizedBox(height: 14),
              AvailableNowCard(
                pitches: venuePitches,
                venues: venuesById,
                bookings: venueDayBookings,
                day: selectedDay,
              ),
            ],
            if (bookingsLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: LinearProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget dot(Color c, String l) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.onSurface.withAlpha(160))),
      ],
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot(const Color(0xFF1E7E3F), 'Confirmed'),
        const SizedBox(width: 10),
        dot(const Color(0xFFE6A100), 'Pending'),
      ],
    );
  }
}
