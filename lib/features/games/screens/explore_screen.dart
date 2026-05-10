import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/screens/pitch_booking_screen.dart';
import 'package:teamup/features/notifications/screens/notifications_screen.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

final _log = Logger();

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _venueService = VenueService();
  final _bookingService = BookingService();

  Set<Sport> _sports = {};
  String? _city;
  Set<DateTime> _filterDates = {};
  Set<int> _filterHours = {};
  bool _openSpotsOnly = false;

  Set<String>? _availablePitchIds;
  bool _availabilityLoading = false;

  bool get _hasAvailabilityFilter => _filterDates.isNotEmpty || _filterHours.isNotEmpty;
  bool get _hasAnyFilter => _city != null || _hasAvailabilityFilter || _openSpotsOnly;

  /// Returns true if the pitch has no booking that overlaps [hour]
  /// (a 1-hour window starting at that hour) on [day].
  bool _isFreeAt(DateTime day, int hour, Iterable<dynamic> dayBookings) {
    final start = DateTime(day.year, day.month, day.day, hour);
    final end = start.add(const Duration(hours: 1));
    return !dayBookings.any((b) => b.status != BookingStatus.cancelled && b.startTime.isBefore(end) && b.endTime.isAfter(start));
  }

  Future<void> _refreshAvailability() async {
    if (!_hasAvailabilityFilter) {
      setState(() {
        _availablePitchIds = null;
        _availabilityLoading = false;
      });
      return;
    }
    final today = DateTime.now();
    final today0 = DateTime(today.year, today.month, today.day);
    final days = _filterDates.isNotEmpty ? _filterDates.toList() : [today0];
    final hours = _filterHours.toList();
    final sports = _sports;
    final capturedDates = _filterDates;
    final capturedHours = _filterHours;
    final capturedSports = _sports;
    setState(() => _availabilityLoading = true);

    Set<String>? result;
    Object? error;
    StackTrace? stack;
    try {
      final allPitches = await _venueService.streamPitchesAcrossVenues().first;
      final pitches = sports.isEmpty ? allPitches : allPitches.where((p) => sports.contains(p.sport)).toList();

      final entries = await Future.wait(
        pitches.map((p) async {
          for (final d in days) {
            final dayBookings = await _bookingService.streamPitchBookingsForDay(p.id, d).first;
            if (hours.isNotEmpty) {
              if (hours.any((h) => _isFreeAt(d, h, dayBookings))) return p.id;
            } else {
              for (var h = 6; h < 22; h++) {
                if (_isFreeAt(d, h, dayBookings)) return p.id;
              }
            }
          }
          return null;
        }),
      );
      result = entries.whereType<String>().toSet();
    } catch (e, st) {
      error = e;
      stack = st;
    }

    if (!mounted) return;
    // Bail if filters changed while we were loading.
    if (!setEquals(_filterDates, capturedDates) || !setEquals(_filterHours, capturedHours) || !setEquals(_sports, capturedSports)) {
      return;
    }
    setState(() {
      _availablePitchIds = result;
      _availabilityLoading = false;
    });
    if (error != null && mounted) {
      _log.e('Availability filter failed', error: error, stackTrace: stack);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Availability filter failed: $error')));
    }
  }

  Future<void> _openFiltersSheet(List<VenueModel> venues) async {
    final cities = {for (final v in venues) v.city}.toList()..sort();

    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        cities: cities,
        initial: _FilterResult(city: _city, dates: _filterDates, hours: _filterHours, openSpotsOnly: _openSpotsOnly),
      ),
    );
    if (result == null) return;
    final availabilityChanged = !setEquals(result.dates, _filterDates) || !setEquals(result.hours, _filterHours);
    setState(() {
      _city = result.city;
      _filterDates = result.dates;
      _filterHours = result.hours;
      _openSpotsOnly = result.openSpotsOnly;
    });
    if (availabilityChanged) await _refreshAvailability();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore'), actions: const [NotificationsBell(), SizedBox(width: 4)]),
      body: SelectionArea(
        child: StreamBuilder<List<VenueModel>>(
          stream: _venueService.streamVenues(),
          builder: (context, venuesSnap) {
            final venues = venuesSnap.data ?? const <VenueModel>[];
            final venuesById = {for (final v in venues) v.id: v};

            return Column(
              children: [
                _TopBar(
                  sports: _sports,
                  onSportsChanged: (s) async {
                    setState(() => _sports = s);
                    await _refreshAvailability();
                  },
                  onFiltersTap: () => _openFiltersSheet(venues),
                  hasActiveFilters: _hasAnyFilter,
                ),
                if (_hasAnyFilter)
                  _ActiveFiltersStrip(
                    city: _city,
                    dates: _filterDates,
                    hours: _filterHours,
                    openSpotsOnly: _openSpotsOnly,
                    onClearCity: () => setState(() => _city = null),
                    onClearDates: () async {
                      setState(() => _filterDates = {});
                      await _refreshAvailability();
                    },
                    onClearHours: () async {
                      setState(() => _filterHours = {});
                      await _refreshAvailability();
                    },
                    onClearOpenSpots: () => setState(() => _openSpotsOnly = false),
                    onClearAll: () async {
                      setState(() {
                        _city = null;
                        _filterDates = {};
                        _filterHours = {};
                        _openSpotsOnly = false;
                      });
                      await _refreshAvailability();
                    },
                  ),
                Expanded(
                  child: StreamBuilder<List<PitchModel>>(
                    stream: _venueService.streamPitchesAcrossVenues(),
                    builder: (context, pitchSnap) {
                      if (pitchSnap.connectionState == ConnectionState.waiting || venuesSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (pitchSnap.hasError) {
                        return Center(child: Text(pitchSnap.error.toString()));
                      }

                      var pitches = pitchSnap.data ?? const <PitchModel>[];

                      if (_sports.isNotEmpty) {
                        pitches = pitches.where((p) => _sports.contains(p.sport)).toList();
                      }

                      if (_city != null) {
                        pitches = pitches.where((p) {
                          final v = venuesById[p.venueId];
                          return v != null && v.city == _city;
                        }).toList();
                      }

                      if (_hasAvailabilityFilter && _availablePitchIds != null) {
                        pitches = pitches.where((p) => _availablePitchIds!.contains(p.id)).toList();
                      }

                      if (_availabilityLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (pitches.isEmpty) return const _EmptyState();

                      // Group by sport when showing more than one sport.
                      if (_sports.length != 1) {
                        final groups = <Sport, List<PitchModel>>{};
                        for (final p in pitches) {
                          groups.putIfAbsent(p.sport, () => []).add(p);
                        }
                        final sortedSports = groups.keys.toList()..sort((a, b) => a.value - b.value);

                        return ListView(
                          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
                          children: [
                            for (final s in sortedSports) ...[
                              _SectionHeader(sport: s, count: groups[s]!.length),
                              const SizedBox(height: 12),
                              _PitchWrap(pitches: groups[s]!, venuesById: venuesById),
                              const SizedBox(height: 28),
                            ],
                          ],
                        );
                      }

                      // Single-sport flat grid.
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
                        children: [_PitchWrap(pitches: pitches, venuesById: venuesById)],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Top bar (sport dropdown + filters button) ──────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.sports, required this.onSportsChanged, required this.onFiltersTap, required this.hasActiveFilters});

  final Set<Sport> sports;
  final ValueChanged<Set<Sport>> onSportsChanged;
  final VoidCallback onFiltersTap;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 6),
      child: Row(
        children: [
          _SportDropdownButton(values: sports, onChanged: onSportsChanged),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton.outlined(onPressed: onFiltersTap, icon: const Icon(Icons.tune_rounded, size: 18), tooltip: 'Filters'),
              if (hasActiveFilters)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SportDropdownButton extends StatelessWidget {
  const _SportDropdownButton({required this.values, required this.onChanged});

  final Set<Sport> values;
  final ValueChanged<Set<Sport>> onChanged;

  String _label() {
    if (values.isEmpty) return 'All sports';
    if (values.length == 1) return values.first.label;
    final sorted = values.toList()..sort((a, b) => a.value - b.value);
    return '${sorted.first.label} +${sorted.length - 1}';
  }

  Future<void> _open(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SportPickerSheet(initial: values, onChanged: onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final single = values.length == 1 ? values.first : null;
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.onSurface.withAlpha(40)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (single != null) ...[
              Image.asset(single.iconPath, width: 16, height: 16, color: colors.secondary),
              const SizedBox(width: 8),
            ] else ...[
              Icon(Icons.sports_rounded, size: 16, color: colors.onSurface.withAlpha(160)),
              const SizedBox(width: 8),
            ],
            Text(_label(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, color: colors.onSurface.withAlpha(180)),
          ],
        ),
      ),
    );
  }
}

class _SportPickerSheet extends StatefulWidget {
  const _SportPickerSheet({required this.initial, required this.onChanged});
  final Set<Sport> initial;
  final ValueChanged<Set<Sport>> onChanged;

  @override
  State<_SportPickerSheet> createState() => _SportPickerSheetState();
}

class _SportPickerSheetState extends State<_SportPickerSheet> {
  late final Set<Sport> _selected = {...widget.initial};

  void _toggle(Sport s) {
    setState(() {
      if (_selected.contains(s)) {
        _selected.remove(s);
      } else {
        _selected.add(s);
      }
    });
    widget.onChanged({..._selected});
  }

  void _selectAll() {
    setState(() => _selected.clear());
    widget.onChanged(const {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAll = _selected.isEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sports', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SportChip(label: 'All sports', selected: isAll, onTap: _selectAll),
                for (final s in Sport.values) _SportChip(label: s.label, icon: s.iconPath, selected: _selected.contains(s), onTap: () => _toggle(s)),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({required this.label, required this.selected, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primary : colors.onSurface.withAlpha(10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Image.asset(icon!, width: 14, height: 14, color: selected ? Colors.white : colors.onSurface.withAlpha(180)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sport section header ───────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.sport, required this.count});
  final Sport sport;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      child: Row(
        children: [
          Image.asset(sport.iconPath, width: 18, height: 18, color: colors.secondary),
          const SizedBox(width: 8),
          Text(sport.label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: colors.onSurface.withAlpha(15), borderRadius: BorderRadius.circular(6)),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.onSurface.withAlpha(160)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pitch wrap (responsive non-stretching tiles) ──────────

class _PitchWrap extends StatelessWidget {
  const _PitchWrap({required this.pitches, required this.venuesById});
  final List<PitchModel> pitches;
  final Map<String, VenueModel> venuesById;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [for (final p in pitches) _PitchTile(pitch: p, venue: venuesById[p.venueId])],
    );
  }
}

// ─── Pitch tile (vertical, fixed width) ────────────────────

class _PitchTile extends StatelessWidget {
  const _PitchTile({required this.pitch, required this.venue});
  final PitchModel pitch;
  final VenueModel? venue;

  static const _tileWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceAmount = (pitch.pricePerHour / 100).toStringAsFixed(0);
    final cover = pitch.imageUrls.isNotEmpty ? pitch.imageUrls.first : null;

    return SizedBox(
      width: _tileWidth,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: venue == null
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PitchBookingScreen(venue: venue!, pitch: pitch),
                  ),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 130,
                child: cover != null
                    ? Image.network(cover, fit: BoxFit.cover)
                    : Container(
                        color: colors.secondary.withAlpha(15),
                        child: Center(child: Image.asset(pitch.sport.iconPath, width: 36, height: 36, color: colors.secondary.withAlpha(120))),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pitch.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (venue != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12, color: colors.onSurface.withAlpha(140)),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              '${venue!.name} • ${venue!.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(160)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MiniChip(icon: Icons.group_outlined, label: '${pitch.maxPlayers}'),
                        const SizedBox(width: 6),
                        if (pitch.indoor)
                          const _MiniChip(icon: Icons.roofing_rounded, label: 'Indoor')
                        else
                          const _MiniChip(icon: Icons.wb_sunny_outlined, label: 'Outdoor'),
                        const Spacer(),
                        Text(
                          '$priceAmount ${pitch.currency}',
                          style: theme.textTheme.titleSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: colors.onSurface.withAlpha(10), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: colors.onSurface.withAlpha(150)),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.onSurface.withAlpha(170)),
          ),
        ],
      ),
    );
  }
}

// ─── Active filters strip ───────────────────────────────────

class _ActiveFiltersStrip extends StatelessWidget {
  const _ActiveFiltersStrip({
    required this.city,
    required this.dates,
    required this.hours,
    required this.openSpotsOnly,
    required this.onClearCity,
    required this.onClearDates,
    required this.onClearHours,
    required this.onClearOpenSpots,
    required this.onClearAll,
  });

  final String? city;
  final Set<DateTime> dates;
  final Set<int> hours;
  final bool openSpotsOnly;
  final VoidCallback onClearCity;
  final VoidCallback onClearDates;
  final VoidCallback onClearHours;
  final VoidCallback onClearOpenSpots;
  final VoidCallback onClearAll;

  String _datesLabel() {
    final sorted = dates.toList()..sort();
    if (sorted.length == 1) return _shortDate(sorted.first);
    return '${_shortDate(sorted.first)} +${sorted.length - 1}';
  }

  String _hoursLabel() {
    final sorted = hours.toList()..sort();
    if (sorted.length == 1) return '${sorted.first.toString().padLeft(2, '0')}:00';
    return '${sorted.first.toString().padLeft(2, '0')}:00 +${sorted.length - 1}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (city != null) _FilterChipPill(label: city!, icon: Icons.location_on_outlined, onClear: onClearCity),
            if (dates.isNotEmpty) _FilterChipPill(label: _datesLabel(), icon: Icons.calendar_today_outlined, onClear: onClearDates),
            if (hours.isNotEmpty) _FilterChipPill(label: _hoursLabel(), icon: Icons.schedule_rounded, onClear: onClearHours),
            if (openSpotsOnly) _FilterChipPill(label: 'Open spots', icon: Icons.group_outlined, onClear: onClearOpenSpots),
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
              ),
              child: Text('Clear all', style: TextStyle(fontSize: 12, color: colors.onSurface.withAlpha(160))),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({required this.label, required this.icon, required this.onClear});
  final String label;
  final IconData icon;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        decoration: BoxDecoration(color: colors.primary.withAlpha(20), borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
            ),
            const SizedBox(width: 2),
            InkWell(
              onTap: onClear,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(Icons.close_rounded, size: 14, color: colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: colors.onSurface.withAlpha(60)),
            const SizedBox(height: 16),
            Text('No pitches match your filters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Try a different sport, city, or time', style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(140))),
          ],
        ),
      ),
    );
  }
}

// ─── Filters sheet ──────────────────────────────────────────

class _FilterResult {
  const _FilterResult({required this.city, required this.dates, required this.hours, required this.openSpotsOnly});
  final String? city;
  final Set<DateTime> dates;
  final Set<int> hours;
  final bool openSpotsOnly;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.cities, required this.initial});
  final List<String> cities;
  final _FilterResult initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _city = widget.initial.city;
  late Set<DateTime> _dates = {...widget.initial.dates};
  late Set<int> _hours = {...widget.initial.hours};
  late bool _openSpotsOnly = widget.initial.openSpotsOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    _city = null;
                    _dates = {};
                    _hours = {};
                    _openSpotsOnly = false;
                  }),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SectionLabel('City'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _city,
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('All cities')),
                ...widget.cities.map((c) => DropdownMenuItem<String?>(value: c, child: Text(c))),
              ],
              onChanged: (v) => setState(() => _city = v),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _SectionLabel('Dates'),
                const SizedBox(width: 8),
                Text('tap multiple', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(120))),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 78,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (_, i) {
                  final d = today.add(Duration(days: i));
                  final isSelected = _dates.contains(d);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: isSelected ? colors.primary : colors.onSurface.withAlpha(10),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() {
                          if (isSelected) {
                            _dates.remove(d);
                          } else {
                            _dates.add(d);
                          }
                        }),
                        child: Container(
                          width: 56,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _weekdayShort(d.weekday),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white.withAlpha(220) : colors.onSurface.withAlpha(140),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${d.day}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : colors.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _SectionLabel('Start times'),
                const SizedBox(width: 8),
                if (_dates.isEmpty) Text('defaults to today', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(120))),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var h = 6; h <= 22; h++)
                  _HourChip(
                    hour: h,
                    selected: _hours.contains(h),
                    onTap: () => setState(() {
                      if (_hours.contains(h)) {
                        _hours.remove(h);
                      } else {
                        _hours.add(h);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: colors.onSurface.withAlpha(8), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Only show open spots', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text('Coming with the games feature', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(130))),
                      ],
                    ),
                  ),
                  Switch.adaptive(value: _openSpotsOnly, onChanged: null),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_FilterResult(city: _city, dates: _dates, hours: _hours, openSpotsOnly: _openSpotsOnly)),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.onSurface.withAlpha(180), letterSpacing: 0.5),
    );
  }
}

class _HourChip extends StatelessWidget {
  const _HourChip({required this.hour, required this.selected, required this.onTap});
  final int hour;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primary : colors.onSurface.withAlpha(10),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          child: Text(
            '${hour.toString().padLeft(2, '0')}:00',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : colors.onSurface),
          ),
        ),
      ),
    );
  }
}

String _shortDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]}';
}

String _weekdayShort(int weekday) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[weekday - 1];
}
