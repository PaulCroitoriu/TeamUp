import 'package:flutter/material.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/theme/sport_tile.dart';
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

/// Dashboard body for one venue:
///   Overview (occupancy + revenue, Day/Month/Year) → Schedule (EPG, by sport).
class ScheduleView extends StatelessWidget {
  const ScheduleView({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.period,
    required this.onPeriodChanged,
    required this.onPickCustom,
    required this.customStart,
    required this.customEnd,
    required this.sportFilter,
    required this.onSportChanged,
    required this.venuesById,
    required this.venuePitches,
    required this.venueBookings,
    required this.bookingsLoading,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onPeriodChanged;
  final VoidCallback onPickCustom;
  final DateTime? customStart;
  final DateTime? customEnd;
  final Sport? sportFilter;
  final ValueChanged<Sport?> onSportChanged;
  final Map<String, VenueModel> venuesById;

  /// All active pitches for the venue (sorted by sport).
  final List<PitchModel> venuePitches;

  /// All non-cancelled bookings for the venue (any date).
  final List<BookingModel> venueBookings;
  final bool bookingsLoading;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < kMobileBreakpoint;
    final hPad = isMobile ? 14.0 : 32.0;
    final isToday = sameDay(selectedDay, DateTime.now());

    final dayBookings = venueBookings.where((b) => sameDay(b.startTime, selectedDay)).toList();
    final (start, end) = period == StatsPeriod.custom && customStart != null && customEnd != null
        ? (customStart!, DateTime(customEnd!.year, customEnd!.month, customEnd!.day + 1))
        : periodRange(period, selectedDay);
    final stats = computeRangeStats(
      bookings: venueBookings,
      pitches: venuePitches,
      venues: venuesById,
      start: start,
      end: end,
    );

    final sports = <Sport>{for (final p in venuePitches) p.sport}.toList()..sort((a, b) => a.value - b.value);
    final shownPitches = sportFilter == null ? venuePitches : venuePitches.where((p) => p.sport == sportFilter).toList();

    final periodNav = _PeriodNav(
      period: period,
      day: selectedDay,
      onChanged: onDaySelected,
      onPickCustom: onPickCustom,
      customStart: customStart,
      customEnd: customEnd,
    );
    final periodControls = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PeriodToggle(period: period, onChanged: onPeriodChanged),
              const SizedBox(height: 10),
              periodNav,
            ],
          )
        : Row(children: [_PeriodToggle(period: period, onChanged: onPeriodChanged), const Spacer(), periodNav]);

    // Full-width on desktop — the content pane fills the space beside the sidebar.
    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, isMobile ? 12 : 22, hPad, isMobile ? 28 : 40),
      children: [
        // ── Overview: occupancy + revenue, day / month / year / custom ──
        Section(
          title: 'Overview',
          titleIcon: Icons.insights_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              periodControls,
              const SizedBox(height: 14),
              KpiCardsRow(stats: stats, scopeLabel: _scopeLabel(period)),
            ],
          ),
        ),
            const SizedBox(height: 16),

            // ── Schedule (EPG) for the selected day, filterable by sport ──
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
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (sports.length > 1) ...[
                      _SportFilter(sports: sports, selected: sportFilter, onChanged: onSportChanged),
                      const SizedBox(height: 12),
                    ],
                    DateStrip(selected: selectedDay, onSelected: onDaySelected),
                    const SizedBox(height: 12),
                    if (shownPitches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(child: Text('No pitches for this sport', style: TextStyle(color: TUColors.ink3))),
                      )
                    else
                      EpgSchedule(
                        pitches: shownPitches,
                        venues: venuesById,
                        bookings: dayBookings,
                        day: selectedDay,
                      ),
                  ],
                ),
              ),

            if (isToday && shownPitches.isNotEmpty) ...[
              const SizedBox(height: 14),
              AvailableNowCard(
                pitches: shownPitches,
                venues: venuesById,
                bookings: dayBookings,
                day: selectedDay,
              ),
            ],
            if (bookingsLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: LinearProgressIndicator()),
              ),
          ],
    );
  }
}

String _scopeLabel(StatsPeriod p) => switch (p) {
  StatsPeriod.day => 'today',
  StatsPeriod.month => 'this month',
  StatsPeriod.year => 'this year',
  StatsPeriod.custom => 'this period',
};

// ─── Period toggle (Day / Month / Year) ─────────────────────

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.period, required this.onChanged});
  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, StatsPeriod p) {
      final selected = period == p;
      return Material(
        color: selected ? TUColors.brand : Colors.transparent,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        child: InkWell(
          onTap: () => onChanged(p),
          borderRadius: BorderRadius.circular(TUColors.rPill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : TUColors.ink2),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: TUColors.surface2,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        border: Border.all(color: TUColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg('Day', StatsPeriod.day),
          seg('Month', StatsPeriod.month),
          seg('Year', StatsPeriod.year),
          seg('Custom', StatsPeriod.custom),
        ],
      ),
    );
  }
}

// ─── Period navigation (‹ label ›) ──────────────────────────

class _PeriodNav extends StatelessWidget {
  const _PeriodNav({
    required this.period,
    required this.day,
    required this.onChanged,
    required this.onPickCustom,
    required this.customStart,
    required this.customEnd,
  });
  final StatsPeriod period;
  final DateTime day;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onPickCustom;
  final DateTime? customStart;
  final DateTime? customEnd;

  static const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _monFull = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  DateTime _shift(int dir) => switch (period) {
    StatsPeriod.day || StatsPeriod.custom => DateTime(day.year, day.month, day.day + dir),
    StatsPeriod.month => DateTime(day.year, day.month + dir, 1),
    StatsPeriod.year => DateTime(day.year + dir, 1, 1),
  };

  String get _label => switch (period) {
    StatsPeriod.day || StatsPeriod.custom => sameDay(day, DateTime.now()) ? 'Today' : '${_wd[day.weekday - 1]} ${day.day} ${_mon[day.month - 1]} ${day.year}',
    StatsPeriod.month => '${_monFull[day.month - 1]} ${day.year}',
    StatsPeriod.year => '${day.year}',
  };

  @override
  Widget build(BuildContext context) {
    if (period == StatsPeriod.custom) {
      final label = customStart != null && customEnd != null
          ? '${customStart!.day} ${_mon[customStart!.month - 1]} – ${customEnd!.day} ${_mon[customEnd!.month - 1]}'
          : 'Pick dates';
      return Material(
        color: TUColors.surface2,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: InkWell(
          onTap: onPickCustom,
          borderRadius: BorderRadius.circular(TUColors.rMd),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.date_range_rounded, size: 16, color: TUColors.ink2),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: TUColors.ink)),
                const SizedBox(width: 6),
                const Icon(Icons.edit_rounded, size: 14, color: TUColors.ink3),
              ],
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavBtn(icon: Icons.chevron_left_rounded, onTap: () => onChanged(_shift(-1))),
        const SizedBox(width: 10),
        Text(_label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: TUColors.ink)),
        const SizedBox(width: 10),
        _NavBtn(icon: Icons.chevron_right_rounded, onTap: () => onChanged(_shift(1))),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
          child: Icon(icon, size: 20, color: TUColors.ink2),
        ),
      ),
    );
  }
}

// ─── Sport filter chips (EPG) ───────────────────────────────

class _SportFilter extends StatelessWidget {
  const _SportFilter({required this.sports, required this.selected, required this.onChanged});
  final List<Sport> sports;
  final Sport? selected;
  final ValueChanged<Sport?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(label: 'All', active: selected == null, onTap: () => onChanged(null)),
          for (final s in sports) ...[
            const SizedBox(width: 8),
            _Chip(label: s.label, sport: s, active: selected == s, onTap: () => onChanged(selected == s ? null : s)),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap, this.sport});
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Sport? sport;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? TUColors.brand : TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        child: Container(
          padding: EdgeInsets.fromLTRB(sport == null ? 14 : 10, 0, 14, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rPill),
            border: Border.all(color: active ? TUColors.brand : TUColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sport != null) ...[
                SportGlyph(sport: sport!, size: 15, color: active ? Colors.white : sport!.color),
                const SizedBox(width: 6),
              ],
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : TUColors.ink2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget dot(Color c, String l) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: TUColors.ink3)),
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
