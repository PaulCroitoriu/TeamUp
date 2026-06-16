import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/theme/sport_tile.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/screens/pitch_booking_screen.dart';
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/shared/widgets/adaptive_sheet.dart';
import 'package:teamup/shared/widgets/page_header.dart';

final _log = Logger();

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _venueService = VenueService();
  final _bookingService = BookingService();
  final _gameService = GameService();

  Set<String> _openPitchIds = {};
  StreamSubscription? _openGamesSub;

  Set<Sport> _sports = {};
  String? _city;
  String _search = '';
  Set<DateTime> _filterDates = {};
  Set<int> _filterHours = {};
  bool _openSpotsOnly = false;

  Set<String>? _availablePitchIds;
  bool _availabilityLoading = false;

  // Inline booking shown in the content area on desktop (keeps the sidebar
  // visible); mobile pushes a full-screen route instead.
  VenueModel? _openVenue;
  PitchModel? _openPitch;

  bool get _hasAvailabilityFilter =>
      _filterDates.isNotEmpty || _filterHours.isNotEmpty;
  bool get _hasAnyFilter =>
      _city != null || _hasAvailabilityFilter || _openSpotsOnly;

  int get _filterCount =>
      (_city != null ? 1 : 0) +
      _filterDates.length +
      _filterHours.length +
      (_openSpotsOnly ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _openGamesSub = _gameService.streamOpenGames().listen(
      (games) {
        if (!mounted) return;
        setState(() => _openPitchIds = {for (final g in games) g.pitchId});
      },
      onError: (Object e, StackTrace st) =>
          _log.e('Open-games stream failed', error: e, stackTrace: st),
    );
  }

  @override
  void dispose() {
    _openGamesSub?.cancel();
    super.dispose();
  }

  /// Returns true if the pitch has no booking that overlaps [hour]
  /// (a 1-hour window starting at that hour) on [day].
  bool _isFreeAt(DateTime day, int hour, Iterable<dynamic> dayBookings) {
    final start = DateTime(day.year, day.month, day.day, hour);
    final end = start.add(const Duration(hours: 1));
    return !dayBookings.any(
      (b) =>
          b.status != BookingStatus.cancelled &&
          b.startTime.isBefore(end) &&
          b.endTime.isAfter(start),
    );
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
      final pitches = sports.isEmpty
          ? allPitches
          : allPitches.where((p) => sports.contains(p.sport)).toList();

      final entries = await Future.wait(
        pitches.map((p) async {
          for (final d in days) {
            final dayBookings = await _bookingService
                .streamPitchBookingsForDay(p.id, d)
                .first;
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
    if (!setEquals(_filterDates, capturedDates) ||
        !setEquals(_filterHours, capturedHours) ||
        !setEquals(_sports, capturedSports)) {
      return;
    }
    setState(() {
      _availablePitchIds = result;
      _availabilityLoading = false;
    });
    if (error != null && mounted) {
      _log.e('Availability filter failed', error: error, stackTrace: stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Availability filter failed: $error')),
      );
    }
  }

  Future<void> _openFiltersSheet(List<VenueModel> venues) async {
    final cities = {for (final v in venues) v.city}.toList()..sort();

    final result = await showAdaptiveSheet<_FilterResult>(
      context,
      builder: (_) => _FilterSheet(
        cities: cities,
        initial: _FilterResult(
          city: _city,
          dates: _filterDates,
          hours: _filterHours,
          openSpotsOnly: _openSpotsOnly,
        ),
      ),
    );
    if (result == null) return;
    final availabilityChanged =
        !setEquals(result.dates, _filterDates) ||
        !setEquals(result.hours, _filterHours);
    setState(() {
      _city = result.city;
      _filterDates = result.dates;
      _filterHours = result.hours;
      _openSpotsOnly = result.openSpotsOnly;
    });
    if (availabilityChanged) await _refreshAvailability();
  }

  void _selectPitch(VenueModel venue, PitchModel pitch) {
    if (MediaQuery.sizeOf(context).width >= 600) {
      // Desktop: render inline so the sidebar stays visible.
      setState(() {
        _openVenue = venue;
        _openPitch = pitch;
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PitchBookingScreen(venue: venue, pitch: pitch),
        ),
      );
    }
  }

  void _closePitch() => setState(() {
    _openVenue = null;
    _openPitch = null;
  });

  @override
  Widget build(BuildContext context) {
    if (_openPitch != null && _openVenue != null) {
      return PitchBookingScreen(
        venue: _openVenue!,
        pitch: _openPitch!,
        onBack: _closePitch,
      );
    }

    return Scaffold(
      backgroundColor: TUColors.bg,
      body: SafeArea(
        bottom: false,
        child: Padding(
          // Roomier gutter on tablet/desktop; flush 20px page padding on mobile.
          padding: EdgeInsets.all(_pageGutter(context)),
          child: SelectionArea(
            child: StreamBuilder<List<VenueModel>>(
              stream: _venueService.streamVenues(),
              builder: (context, venuesSnap) {
                final venues = venuesSnap.data ?? const <VenueModel>[];
                final venuesById = {for (final v in venues) v.id: v};

                return Column(
                  children: [
                    PageHeader(
                      title: 'Explore',
                      subtitle:
                          'Book pitches and courts across ${_city ?? 'your city'} — or join a game that needs players.',
                    ),
                    _TopBar(
                      sports: _sports,
                      onSportsChanged: (s) async {
                        setState(() => _sports = s);
                        await _refreshAvailability();
                      },
                      onFiltersTap: () => _openFiltersSheet(venues),
                      filterCount: _filterCount,
                      onSearchChanged: (q) => setState(() => _search = q),
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
                        onClearOpenSpots: () =>
                            setState(() => _openSpotsOnly = false),
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
                          if (pitchSnap.connectionState ==
                                  ConnectionState.waiting ||
                              venuesSnap.connectionState ==
                                  ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (pitchSnap.hasError) {
                            return Center(
                              child: Text(pitchSnap.error.toString()),
                            );
                          }

                          var pitches = pitchSnap.data ?? const <PitchModel>[];

                          if (_sports.isNotEmpty) {
                            pitches = pitches
                                .where((p) => _sports.contains(p.sport))
                                .toList();
                          }

                          if (_city != null) {
                            pitches = pitches.where((p) {
                              final v = venuesById[p.venueId];
                              return v != null && v.city == _city;
                            }).toList();
                          }

                          if (_search.trim().isNotEmpty) {
                            final q = _search.trim().toLowerCase();
                            pitches = pitches.where((p) {
                              final v = venuesById[p.venueId];
                              return p.name.toLowerCase().contains(q) ||
                                  (v?.name.toLowerCase().contains(q) ??
                                      false) ||
                                  (v?.city.toLowerCase().contains(q) ?? false);
                            }).toList();
                          }

                          if (_hasAvailabilityFilter &&
                              _availablePitchIds != null) {
                            pitches = pitches
                                .where(
                                  (p) => _availablePitchIds!.contains(p.id),
                                )
                                .toList();
                          }

                          if (_availabilityLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (pitches.isEmpty) return const _EmptyState();

                          // Group by sport when showing more than one sport.
                          if (_sports.length != 1) {
                            final groups = <Sport, List<PitchModel>>{};
                            for (final p in pitches) {
                              groups.putIfAbsent(p.sport, () => []).add(p);
                            }
                            final sortedSports = groups.keys.toList()
                              ..sort((a, b) => a.value - b.value);

                            return ListView(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                              children: [
                                for (final s in sortedSports) ...[
                                  _SectionHeader(
                                    sport: s,
                                    count: groups[s]!.length,
                                  ),
                                  const SizedBox(height: 16),
                                  _PitchWrap(
                                    pitches: groups[s]!,
                                    venuesById: venuesById,
                                    onOpen: _selectPitch,
                                    openPitchIds: _openPitchIds,
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ],
                            );
                          }

                          // Single-sport flat grid.
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                            children: [
                              _PitchWrap(
                                pitches: pitches,
                                venuesById: venuesById,
                                onOpen: _selectPitch,
                                openPitchIds: _openPitchIds,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Extra horizontal page padding: flush on mobile, roomier on tablet/desktop
/// so the wide sidebar layout isn't cramped against the content.
double _pageGutter(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= 1100) return 32;
  if (w >= 700) return 16;
  return 0;
}

// ─── Top bar (sport dropdown + filters button) ──────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.sports,
    required this.onSportsChanged,
    required this.onFiltersTap,
    required this.filterCount,
    required this.onSearchChanged,
  });

  final Set<Sport> sports;
  final ValueChanged<Set<Sport>> onSportsChanged;
  final VoidCallback onFiltersTap;
  final int filterCount;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    // Search pill shows on wider widths; on mobile it's the dropdown + Filters
    // only (matching the design's mobile filter bar).
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final sportDrop = _SportDropdownButton(
      values: sports,
      onChanged: onSportsChanged,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          wide ? sportDrop : Expanded(child: sportDrop),
          const SizedBox(width: 9),
          // Dark "Filters" pill with a lime count badge.
          Material(
            color: TUColors.ink,
            borderRadius: BorderRadius.circular(TUColors.rPill),
            child: InkWell(
              onTap: onFiltersTap,
              borderRadius: BorderRadius.circular(TUColors.rPill),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (filterCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 20,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: TUColors.lime,
                          borderRadius: BorderRadius.circular(TUColors.rPill),
                        ),
                        child: Text(
                          '$filterCount',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: TUColors.brand900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (wide) ...[
            const SizedBox(width: 9),
            Expanded(child: _SearchPill(onChanged: onSearchChanged)),
          ],
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      height: 44,
      decoration: BoxDecoration(
        color: TUColors.surface,
        border: Border.all(color: TUColors.line, width: 1.5),
        borderRadius: BorderRadius.circular(TUColors.rPill),
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          const Icon(Icons.search_rounded, size: 18, color: TUColors.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TUColors.ink,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search venues, clubs…',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TUColors.ink3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
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
    await showAdaptiveSheet<void>(
      context,
      builder: (_) => _SportPickerSheet(initial: values, onChanged: onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    final single = values.length == 1 ? values.first : null;
    return Material(
      color: TUColors.surface,
      borderRadius: BorderRadius.circular(TUColors.rPill),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(TUColors.rPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: TUColors.line2, width: 1.5),
            borderRadius: BorderRadius.circular(TUColors.rPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (single != null)
                SportGlyph(sport: single, size: 18, color: single.color)
              else
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 18,
                  color: TUColors.brand,
                ),
              const SizedBox(width: 9),
              Text(
                _label(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: TUColors.ink,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: TUColors.ink3,
              ),
            ],
          ),
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
    final mobile = isMobileWidth(context);
    final isAll = _selected.isEmpty;
    final count = _selected.length;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mobile)
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 2),
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: TUColors.line2,
                borderRadius: BorderRadius.circular(TUColors.rPill),
              ),
            ),
          // ── header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 16, 12),
            child: Row(
              children: [
                const Text(
                  'Sports',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: TUColors.ink,
                  ),
                ),
                const Spacer(),
                _SheetCloseButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          // ── body ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SportChip(
                  label: 'All sports',
                  selected: isAll,
                  onTap: _selectAll,
                  accent: TUColors.brand,
                ),
                for (final s in Sport.values)
                  _SportChip(
                    label: s.label,
                    sport: s,
                    selected: _selected.contains(s),
                    onTap: () => _toggle(s),
                    accent: s.color,
                  ),
              ],
            ),
          ),
          // ── footer ──
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: TUColors.line)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: TUColors.brand,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TUColors.rMd),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(count == 0 ? 'Done' : 'Done · $count selected'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(Icons.close_rounded, size: 18, color: TUColors.ink2),
        ),
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accent,
    this.sport,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  final Sport? sport;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? accent : TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rPill),
            border: Border.all(
              color: selected ? accent : TUColors.line,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sport != null) ...[
                SportGlyph(
                  sport: sport!,
                  size: 18,
                  color: selected ? Colors.white : TUColors.ink,
                ),
                const SizedBox(width: 9),
              ] else ...[
                Icon(
                  Icons.explore_outlined,
                  size: 17,
                  color: selected ? Colors.white : TUColors.ink,
                ),
                const SizedBox(width: 9),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : TUColors.ink,
                ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: sport.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SportGlyph(sport: sport, size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            sport.label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: TUColors.ink,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
            decoration: BoxDecoration(
              color: TUColors.surface2,
              borderRadius: BorderRadius.circular(TUColors.rPill),
              border: Border.all(color: TUColors.line),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: TUColors.ink2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: TUColors.line, thickness: 1)),
        ],
      ),
    );
  }
}

// ─── Pitch wrap (responsive non-stretching tiles) ──────────

class _PitchWrap extends StatelessWidget {
  const _PitchWrap({
    required this.pitches,
    required this.venuesById,
    required this.onOpen,
    required this.openPitchIds,
  });
  final List<PitchModel> pitches;
  final Map<String, VenueModel> venuesById;
  final void Function(VenueModel venue, PitchModel pitch) onOpen;
  final Set<String> openPitchIds;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final columns = w >= 900
            ? 3
            : w >= 560
            ? 2
            : 1;
        const gap = 14.0;
        final itemW = columns == 1 ? w : 350.0;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final p in pitches)
              SizedBox(
                width: itemW,
                child: _PitchTile(
                  pitch: p,
                  venue: venuesById[p.venueId],
                  onOpen: onOpen,
                  hasOpenGame: openPitchIds.contains(p.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Pitch tile (vertical, fixed width) ────────────────────

class _PitchTile extends StatelessWidget {
  const _PitchTile({
    required this.pitch,
    required this.venue,
    required this.onOpen,
    required this.hasOpenGame,
  });
  final PitchModel pitch;
  final VenueModel? venue;
  final void Function(VenueModel venue, PitchModel pitch) onOpen;
  final bool hasOpenGame;

  @override
  Widget build(BuildContext context) {
    final priceAmount = (pitch.pricePerHour / 100).toStringAsFixed(0);

    return Material(
      color: TUColors.surface,
      borderRadius: BorderRadius.circular(TUColors.rLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: venue == null ? null : () => onOpen(venue!, pitch),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rLg),
            border: Border.all(color: TUColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SportTile(
                sport: pitch.sport,
                height: 150,
                glyphSize: 60,
                overlay: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: TilePill(
                      icon: pitch.indoor
                          ? Icons.roofing_rounded
                          : Icons.wb_sunny_outlined,
                      label: pitch.indoor ? 'Indoor' : 'Outdoor',
                    ),
                  ),
                  if (hasOpenGame)
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: TilePill(
                        icon: Icons.bolt_rounded,
                        label: 'Open game',
                        background: TUColors.lime,
                        foreground: TUColors.brand900,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pitch.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: TUColors.ink,
                      ),
                    ),
                    if (venue != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: TUColors.ink3,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '${venue!.name} · ${venue!.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: TUColors.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 11),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: TUColors.line,
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.group_outlined,
                          label: '${pitch.maxPlayers}',
                        ),
                        const Spacer(),
                        Text.rich(
                          TextSpan(
                            text: '$priceAmount ${pitch.currency}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: TUColors.brand700,
                            ),
                            children: const [
                              TextSpan(
                                text: ' /h',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: TUColors.ink3,
                                ),
                              ),
                            ],
                          ),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: TUColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TUColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: TUColors.ink2),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TUColors.ink2,
            ),
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
    if (sorted.length == 1) {
      return '${sorted.first.toString().padLeft(2, '0')}:00';
    }
    return '${sorted.first.toString().padLeft(2, '0')}:00 +${sorted.length - 1}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (city != null)
              _FilterChipPill(
                label: city!,
                icon: Icons.location_on_outlined,
                onClear: onClearCity,
              ),
            if (dates.isNotEmpty)
              _FilterChipPill(
                label: _datesLabel(),
                icon: Icons.calendar_today_outlined,
                onClear: onClearDates,
              ),
            if (hours.isNotEmpty)
              _FilterChipPill(
                label: _hoursLabel(),
                icon: Icons.schedule_rounded,
                onClear: onClearHours,
              ),
            if (openSpotsOnly)
              _FilterChipPill(
                label: 'Open spots',
                icon: Icons.group_outlined,
                onClear: onClearOpenSpots,
              ),
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface.withAlpha(160),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({
    required this.label,
    required this.icon,
    required this.onClear,
  });
  final String label;
  final IconData icon;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 2),
            InkWell(
              onTap: onClear,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: colors.primary,
                ),
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
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: colors.onSurface.withAlpha(60),
            ),
            const SizedBox(height: 16),
            Text(
              'No pitches match your filters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different sport, city, or time',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withAlpha(140),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filters sheet ──────────────────────────────────────────

class _FilterResult {
  const _FilterResult({
    required this.city,
    required this.dates,
    required this.hours,
    required this.openSpotsOnly,
  });
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
    final mobile = isMobileWidth(context);
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mobile)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 2),
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: TUColors.line2,
                  borderRadius: BorderRadius.circular(TUColors.rPill),
                ),
              ),
            // ── header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: TUColors.ink,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      _city = null;
                      _dates = {};
                      _hours = {};
                      _openSpotsOnly = false;
                    }),
                    style: TextButton.styleFrom(
                      foregroundColor: TUColors.brand,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            // ── body ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel('City'),
                    const SizedBox(height: 11),
                    DropdownButtonFormField<String?>(
                      initialValue: _city,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: TUColors.ink3,
                      ),
                      borderRadius: BorderRadius.circular(TUColors.rMd),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: TUColors.ink,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: TUColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TUColors.rMd),
                          borderSide: const BorderSide(
                            color: TUColors.line2,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TUColors.rMd),
                          borderSide: const BorderSide(
                            color: TUColors.brand,
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All cities'),
                        ),
                        ...widget.cities.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c,
                            child: Text(c),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _city = v),
                    ),
                    const SizedBox(height: 20),
                    const _FieldLabel('Dates', hint: 'tap multiple'),
                    const SizedBox(height: 11),
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 14,
                        itemBuilder: (_, i) {
                          final d = today.add(Duration(days: i));
                          final on = _dates.contains(d);
                          return Padding(
                            padding: const EdgeInsets.only(right: 9),
                            child: _DayChip(
                              dow: _weekdayShort(d.weekday),
                              day: d.day,
                              selected: on,
                              onTap: () => setState(() {
                                if (on) {
                                  _dates.remove(d);
                                } else {
                                  _dates.add(d);
                                }
                              }),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel(
                      'Start times',
                      hint: _dates.isEmpty ? 'defaults to today' : null,
                    ),
                    const SizedBox(height: 11),
                    GridView.count(
                      crossAxisCount: mobile ? 3 : 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 9,
                      crossAxisSpacing: 9,
                      childAspectRatio: 2.4,
                      children: [
                        for (var h = 6; h <= 22; h++)
                          _TimeChip(
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
                    // "only open spots" — disabled until the games feature lands.
                    Opacity(
                      opacity: 0.55,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TUColors.surface2,
                          borderRadius: BorderRadius.circular(TUColors.rMd),
                          border: Border.all(color: TUColors.line),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Only show open spots',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: TUColors.ink,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Coming with the games feature',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: TUColors.ink3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _openSpotsOnly,
                              onChanged: null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── footer ──
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: TUColors.line)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(
                  _FilterResult(
                    city: _city,
                    dates: _dates,
                    hours: _hours,
                    openSpotsOnly: _openSpotsOnly,
                  ),
                ),
                icon: const Icon(Icons.check_rounded, size: 19),
                label: const Text('Apply filters'),
                style: FilledButton.styleFrom(
                  backgroundColor: TUColors.brand,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TUColors.rMd),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, {this.hint});
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: TUColors.ink,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(width: 8),
          Text(
            hint!,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: TUColors.ink3,
            ),
          ),
        ],
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.dow,
    required this.day,
    required this.selected,
    required this.onTap,
  });
  final String dow;
  final int day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TUColors.brand : TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
          width: 62,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dow.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: selected ? Colors.white : TUColors.ink3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : TUColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.hour,
    required this.selected,
    required this.onTap,
  });
  final int hour;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TUColors.brand : TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rSm),
        child: Center(
          child: Text(
            '${hour.toString().padLeft(2, '0')}:00',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : TUColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

String _shortDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${months[d.month - 1]}';
}

String _weekdayShort(int weekday) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[weekday - 1];
}
