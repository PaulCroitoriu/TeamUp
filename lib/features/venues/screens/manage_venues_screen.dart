import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/notifications/screens/notifications_screen.dart';
import 'package:teamup/features/venues/bloc/venue_bloc.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/add_edit_pitch_screen.dart' show AddEditPitchDialog;
import 'package:teamup/features/venues/screens/add_edit_venue_screen.dart' show AddEditVenueDialog;

final _log = Logger();

const _splitBreakpoint = 880.0;
const _mobileBreakpoint = 600.0;

enum _PitchFilter { all, active, indoor, lit }

class ManageVenuesScreen extends StatelessWidget {
  const ManageVenuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final businessId = authState.maybeMap(authenticated: (s) => s.user.businessId, orElse: () => null);

        if (businessId == null) {
          return const Scaffold(body: Center(child: Text('No business linked to this account')));
        }

        return BlocProvider(
          create: (_) => VenueBloc(venueService: VenueService())..add(VenueEvent.loadBusinessVenues(businessId)),
          child: _VenuesShell(businessId: businessId),
        );
      },
    );
  }
}

// ─── Shell with state for selected venue + pitch search ─────

class _VenuesShell extends StatefulWidget {
  const _VenuesShell({required this.businessId});
  final String businessId;

  @override
  State<_VenuesShell> createState() => _VenuesShellState();
}

class _VenuesShellState extends State<_VenuesShell> {
  int _selectedIndex = 0;
  String _pitchQuery = '';
  _PitchFilter _pitchFilter = _PitchFilter.all;
  Set<Sport> _selectedSports = {};

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Venues'), elevation: 0, scrolledUnderElevation: 0, actions: const [NotificationsBell(), SizedBox(width: 4)]),
      body: SelectionArea(
        child: BlocBuilder<VenueBloc, VenueState>(
          builder: (context, state) {
            return state.maybeMap(
              loading: (_) => const Center(child: CircularProgressIndicator()),
              loaded: (s) {
                if (s.venues.isEmpty) {
                  return _EmptyVenues(businessId: widget.businessId, bloc: context.read<VenueBloc>());
                }
                if (_selectedIndex >= s.venues.length) _selectedIndex = 0;
                final venue = s.venues[_selectedIndex];
                return _Body(
                  venue: venue,
                  venues: s.venues,
                  selectedIndex: _selectedIndex,
                  onVenueSelected: (i) => setState(() => _selectedIndex = i),
                  businessId: widget.businessId,
                  bloc: context.read<VenueBloc>(),
                  pitchQuery: _pitchQuery,
                  onPitchQuery: (q) => setState(() => _pitchQuery = q),
                  pitchFilter: _pitchFilter,
                  onPitchFilter: (f) => setState(() => _pitchFilter = f),
                  selectedSports: _selectedSports,
                  onSportsChanged: (s) => setState(() => _selectedSports = s),
                );
              },
              error: (e) => Center(
                child: Text(e.message, style: TextStyle(color: colors.error)),
              ),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

// ─── Body (responsive split) ────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.venue,
    required this.venues,
    required this.selectedIndex,
    required this.onVenueSelected,
    required this.businessId,
    required this.bloc,
    required this.pitchQuery,
    required this.onPitchQuery,
    required this.pitchFilter,
    required this.onPitchFilter,
    required this.selectedSports,
    required this.onSportsChanged,
  });

  final VenueModel venue;
  final List<VenueModel> venues;
  final int selectedIndex;
  final ValueChanged<int> onVenueSelected;
  final String businessId;
  final VenueBloc bloc;
  final String pitchQuery;
  final ValueChanged<String> onPitchQuery;
  final _PitchFilter pitchFilter;
  final ValueChanged<_PitchFilter> onPitchFilter;
  final Set<Sport> selectedSports;
  final ValueChanged<Set<Sport>> onSportsChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    final venuePicker = _VenuePickerBar(
      venue: venue,
      venues: venues,
      selectedIndex: selectedIndex,
      onVenueSelected: onVenueSelected,
      businessId: businessId,
      bloc: bloc,
    );

    final detailsPanel = _DetailsPanel(venue: venue, businessId: businessId, bloc: bloc);
    final pitchesPanel = _PitchesPanel(
      venue: venue,
      query: pitchQuery,
      onQuery: onPitchQuery,
      filter: pitchFilter,
      onFilter: onPitchFilter,
      selectedSports: selectedSports,
      onSportsChanged: onSportsChanged,
    );

    if (width >= _splitBreakpoint) {
      return Column(
        children: [
          venuePicker,
          const Divider(height: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(40, 36, 32, 48),
                        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 540), child: detailsPanel),
                      ),
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: colors.onSurface.withAlpha(20)),
                    Expanded(flex: 6, child: pitchesPanel),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          venuePicker,
          Material(
            color: Theme.of(context).appBarTheme.backgroundColor ?? colors.surface,
            child: TabBar(
              tabs: const [
                Tab(text: 'Venue'),
                Tab(text: 'Pitches'),
              ],
              labelColor: colors.primary,
              unselectedLabelColor: colors.onSurface.withAlpha(150),
              indicatorColor: colors.primary,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 32), child: detailsPanel),
                pitchesPanel,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Venue picker (top bar) ─────────────────────────────────

class _VenuePickerBar extends StatelessWidget {
  const _VenuePickerBar({
    required this.venue,
    required this.venues,
    required this.selectedIndex,
    required this.onVenueSelected,
    required this.businessId,
    required this.bloc,
  });

  final VenueModel venue;
  final List<VenueModel> venues;
  final int selectedIndex;
  final ValueChanged<int> onVenueSelected;
  final String businessId;
  final VenueBloc bloc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < _mobileBreakpoint;

    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 40, 20, isMobile ? 16 : 32, 18),
      child: Row(
        children: [
          // ── Left: storefront icon + picker. Wrapped in `Expanded` (not
          // `Flexible + Spacer`) so the entire remaining space is consumed
          // here. The picker sits at the start of that space and ellipsizes
          // when too long. This guarantees the trailing buttons sit at the
          // row's right edge regardless of the picker's content width.
          Expanded(
            child: Row(
              children: [
                Icon(Icons.storefront_rounded, color: colors.primary, size: 22),
                const SizedBox(width: 10),
                Flexible(
                  child: venues.length > 1
                      ? _VenueDropdown(venues: venues, selectedIndex: selectedIndex, onVenueSelected: onVenueSelected, isExpanded: isMobile)
                      : Text(
                          venue.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Right: trailing actions, anchored to the end ──
          IconButton.outlined(
            onPressed: () => AddEditVenueDialog.show(context, businessId: businessId, bloc: bloc, venue: venue),
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Edit venue',
          ),
          const SizedBox(width: 6),
          IconButton.outlined(
            onPressed: () => AddEditVenueDialog.show(context, businessId: businessId, bloc: bloc),
            icon: const Icon(Icons.add_rounded, size: 18),
            tooltip: 'New venue',
          ),
        ],
      ),
    );
  }
}

class _VenueDropdown extends StatelessWidget {
  const _VenueDropdown({required this.venues, required this.selectedIndex, required this.onVenueSelected, required this.isExpanded});

  final List<VenueModel> venues;
  final int selectedIndex;
  final ValueChanged<int> onVenueSelected;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: selectedIndex,
        isDense: true,
        isExpanded: isExpanded,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2, color: colors.onSurface),
        icon: Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: colors.onSurface.withAlpha(150)),
        items: [
          for (var i = 0; i < venues.length; i++)
            DropdownMenuItem(
              value: i,
              child: Text(venues[i].name, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (i) {
          if (i != null) onVenueSelected(i);
        },
      ),
    );
  }
}

// ─── Empty venues state ─────────────────────────────────────

class _EmptyVenues extends StatelessWidget {
  const _EmptyVenues({required this.businessId, required this.bloc});
  final String businessId;
  final VenueBloc bloc;

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
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: colors.primary.withAlpha(15), shape: BoxShape.circle),
              child: Icon(Icons.storefront_rounded, size: 40, color: colors.primary.withAlpha(140)),
            ),
            const SizedBox(height: 24),
            Text('Set up your first venue', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Add a venue to start adding pitches\nand receiving bookings.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(150), height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: FilledButton.icon(
                onPressed: () => AddEditVenueDialog.show(context, businessId: businessId, bloc: bloc),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add venue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Details panel ──────────────────────────────────────────

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.venue, required this.businessId, required this.bloc});

  final VenueModel venue;
  final String businessId;
  final VenueBloc bloc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Hero(venue: venue),
        const SizedBox(height: 18),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: colors.onSurface.withAlpha(150)),
            const SizedBox(width: 6),
            Expanded(
              child: Text('${venue.address}, ${venue.city}', style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(180))),
            ),
          ],
        ),
        if (venue.phone != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 16, color: colors.onSurface.withAlpha(150)),
              const SizedBox(width: 6),
              Text(venue.phone!, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(180))),
            ],
          ),
        ],
        if (venue.description != null) ...[
          const SizedBox(height: 14),
          Text(venue.description!, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(180), height: 1.5)),
        ],

        if (venue.sports.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SectionLabel('Sports offered'),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in venue.sports) _SportBadge(sport: s)]),
        ],

        const SizedBox(height: 20),
        _FacilitiesCard(venue: venue),
        const SizedBox(height: 12),
        _OpeningHoursCard(venue: venue),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.venue});
  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: venue.imageUrl != null
            ? Image.network(venue.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback(colors))
            : _fallback(colors),
      ),
    );
  }

  Widget _fallback(ColorScheme colors) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary.withAlpha(40), colors.secondary.withAlpha(40)],
        ),
      ),
      child: Center(child: Icon(Icons.storefront_rounded, size: 40, color: colors.onSurface.withAlpha(120))),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.onSurface.withAlpha(160), letterSpacing: 1.2),
    );
  }
}

class _SportBadge extends StatelessWidget {
  const _SportBadge({required this.sport});
  final Sport sport;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: colors.secondary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(sport.iconPath, width: 12, height: 12, color: colors.secondary),
          const SizedBox(width: 5),
          Text(
            sport.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.secondary),
          ),
        ],
      ),
    );
  }
}

class _FacilitiesCard extends StatelessWidget {
  const _FacilitiesCard({required this.venue});
  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final items = <(IconData, String, bool)>[
      (Icons.local_cafe_outlined, 'Café', venue.hasCafe),
      (Icons.local_parking_outlined, 'Parking', venue.hasParking),
      (Icons.wifi_rounded, 'Wi-Fi', venue.hasWifi),
      (Icons.shower_outlined, 'Showers', venue.hasShower),
      (Icons.checkroom_outlined, 'Changing room', venue.hasChangingRoom),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.onSurface.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Facilities'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final (icon, label, on) in items) _FacilityChip(icon: icon, label: label, on: on)],
          ),
          if (venue.amenities.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionLabel('Other amenities'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final a in venue.amenities)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.onSurface.withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.onSurface.withAlpha(20)),
                    ),
                    child: Text(
                      a,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurface.withAlpha(170)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip({required this.icon, required this.label, required this.on});
  final IconData icon;
  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = on ? colors.primary : colors.onSurface.withAlpha(110);
    final bg = on ? colors.primary.withAlpha(20) : colors.onSurface.withAlpha(8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(on ? icon : Icons.do_not_disturb_alt_outlined, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
              decoration: on ? null : TextDecoration.lineThrough,
              decorationColor: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningHoursCard extends StatelessWidget {
  const _OpeningHoursCard({required this.venue});
  final VenueModel venue;

  static const _days = [
    ('monday', 'Mon'),
    ('tuesday', 'Tue'),
    ('wednesday', 'Wed'),
    ('thursday', 'Thu'),
    ('friday', 'Fri'),
    ('saturday', 'Sat'),
    ('sunday', 'Sun'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (venue.openingHours.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.onSurface.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Opening hours'),
          const SizedBox(height: 10),
          for (final (key, label) in _days)
            if (venue.openingHours.containsKey(key))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: colors.onSurface.withAlpha(140)),
                      ),
                    ),
                    Text(
                      venue.openingHours[key]!.closed
                          ? 'Closed'
                          : '${venue.openingHours[key]!.open} – '
                                '${venue.openingHours[key]!.close}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: venue.openingHours[key]!.closed ? colors.error.withAlpha(180) : colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

// ─── Pitches header ─────────────────────────────────────────

class _PitchesHeader extends StatelessWidget {
  const _PitchesHeader({required this.count, required this.query, required this.onQuery, required this.onAdd, required this.isMobile});

  final int count;
  final String query;
  final ValueChanged<String> onQuery;
  final VoidCallback onAdd;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 32, isMobile ? 14 : 28, isMobile ? 20 : 32, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Pitches', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: colors.primary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colors.primary),
                ),
              ),
              const Spacer(),
              if (isMobile)
                IconButton.filled(onPressed: onAdd, icon: const Icon(Icons.add_rounded, size: 18), tooltip: 'Add pitch')
              else
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add pitch'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _SearchField(initial: query, onChanged: onQuery),
        ],
      ),
    );
  }
}

// ─── Pitches panel ──────────────────────────────────────────

class _PitchesPanel extends StatelessWidget {
  const _PitchesPanel({
    required this.venue,
    required this.query,
    required this.onQuery,
    required this.filter,
    required this.onFilter,
    required this.selectedSports,
    required this.onSportsChanged,
  });

  final VenueModel venue;
  final String query;
  final ValueChanged<String> onQuery;
  final _PitchFilter filter;
  final ValueChanged<_PitchFilter> onFilter;
  final Set<Sport> selectedSports;
  final ValueChanged<Set<Sport>> onSportsChanged;

  bool _matchesFilter(PitchModel p) {
    if (selectedSports.isNotEmpty && !selectedSports.contains(p.sport)) {
      return false;
    }
    return switch (filter) {
      _PitchFilter.all => true,
      _PitchFilter.active => p.active,
      _PitchFilter.indoor => p.indoor,
      _PitchFilter.lit => p.isIlluminated,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < _mobileBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──
        StreamBuilder<List<PitchModel>>(
          stream: VenueService().streamAllPitches(venue.id),
          builder: (context, snap) {
            final count = (snap.data ?? const []).length;
            return _PitchesHeader(
              count: count,
              query: query,
              onQuery: onQuery,
              onAdd: () => AddEditPitchDialog.show(context, venueId: venue.id),
              isMobile: isMobile,
            );
          },
        ),
        Expanded(
          child: StreamBuilder<List<PitchModel>>(
            stream: VenueService().streamAllPitches(venue.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                _log.e('Pitches stream error', error: snap.error);
                return Center(
                  child: Text(snap.error.toString(), style: TextStyle(color: colors.error)),
                );
              }
              final all = snap.data ?? const <PitchModel>[];
              if (all.isEmpty) {
                return _EmptyPitches(venueId: venue.id);
              }

              final stats = _PitchStats.from(all);
              final filtered = all.where((p) {
                if (!_matchesFilter(p)) return false;
                if (query.isEmpty) return true;
                return p.name.toLowerCase().contains(query.toLowerCase());
              }).toList();

              final groups = <Sport, List<PitchModel>>{};
              for (final p in filtered) {
                groups.putIfAbsent(p.sport, () => []).add(p);
              }
              final sortedSports = groups.keys.toList()..sort((a, b) => a.value - b.value);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final hPad = isMobile ? 20.0 : 32.0;
                  final available = constraints.maxWidth - hPad * 2;
                  final spacing = isMobile ? 14.0 : 18.0;
                  final cols = available < 520
                      ? 1
                      : available < 880
                      ? 2
                      : 3;
                  final tileWidth = (available - (cols - 1) * spacing) / cols;
                  return ListView(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, isMobile ? 24 : 40),
                    children: [
                      _FilterChipsRow(
                        stats: stats,
                        selected: filter,
                        onSelected: onFilter,
                        selectedSports: selectedSports,
                        onSportsChanged: onSportsChanged,
                        availableSports: venue.sports.isEmpty ? Sport.values : venue.sports,
                      ),
                      SizedBox(height: isMobile ? 14 : 22),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              query.isNotEmpty ? 'No pitches match "$query"' : 'No pitches match this filter',
                              style: TextStyle(color: colors.onSurface.withAlpha(140)),
                            ),
                          ),
                        ),
                      for (final sport in sortedSports) ...[
                        _SportGroupHeader(sport: sport, count: groups[sport]!.length),
                        SizedBox(height: isMobile ? 10 : 14),
                        Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [for (final p in groups[sport]!) _PitchTile(pitch: p, venueId: venue.id, width: tileWidth)],
                        ),
                        SizedBox(height: isMobile ? 22 : 32),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Stats row ──────────────────────────────────────────────

class _PitchStats {
  const _PitchStats({required this.total, required this.active, required this.indoor, required this.lit});
  final int total;
  final int active;
  final int indoor;
  final int lit;

  factory _PitchStats.from(List<PitchModel> pitches) {
    return _PitchStats(
      total: pitches.length,
      active: pitches.where((p) => p.active).length,
      indoor: pitches.where((p) => p.indoor).length,
      lit: pitches.where((p) => p.isIlluminated).length,
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.stats,
    required this.selected,
    required this.onSelected,
    required this.selectedSports,
    required this.onSportsChanged,
    required this.availableSports,
  });

  final _PitchStats stats;
  final _PitchFilter selected;
  final ValueChanged<_PitchFilter> onSelected;
  final Set<Sport> selectedSports;
  final ValueChanged<Set<Sport>> onSportsChanged;
  final List<Sport> availableSports;

  // Toggle behaviour: tapping the active filter clears it back to "all".
  void _toggle(_PitchFilter f) {
    onSelected(selected == f ? _PitchFilter.all : f);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SportsDropdownPill(available: availableSports, selected: selectedSports, onChanged: onSportsChanged),
          const SizedBox(width: 6),
          _FilterPill(label: 'Active', count: stats.active, selected: selected == _PitchFilter.active, onTap: () => _toggle(_PitchFilter.active)),
          const SizedBox(width: 6),
          _FilterPill(label: 'Indoor', count: stats.indoor, selected: selected == _PitchFilter.indoor, onTap: () => _toggle(_PitchFilter.indoor)),
          const SizedBox(width: 6),
          _FilterPill(label: 'Lit', count: stats.lit, selected: selected == _PitchFilter.lit, onTap: () => _toggle(_PitchFilter.lit)),
        ],
      ),
    );
  }
}

class _SportsDropdownPill extends StatelessWidget {
  const _SportsDropdownPill({required this.available, required this.selected, required this.onChanged});

  final List<Sport> available;
  final Set<Sport> selected;
  final ValueChanged<Set<Sport>> onChanged;

  String _label() {
    if (selected.isEmpty) return 'All sports';
    if (selected.length == 1) return selected.first.label;
    final sorted = selected.toList()..sort((a, b) => a.value - b.value);
    return '${sorted.first.label} +${sorted.length - 1}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isFiltered = selected.isNotEmpty;
    final fg = isFiltered ? Colors.white : colors.onSurface.withAlpha(170);

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        elevation: const WidgetStatePropertyAll(4),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4)),
      ),
      builder: (ctx, controller, _) {
        return Material(
          color: isFiltered ? colors.primary : colors.onSurface.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => controller.isOpen ? controller.close() : controller.open(),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_rounded, size: 14, color: fg),
                  const SizedBox(width: 5),
                  Text(
                    _label(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded, size: 18, color: fg),
                ],
              ),
            ),
          ),
        );
      },
      menuChildren: [
        if (isFiltered)
          MenuItemButton(
            onPressed: () => onChanged(const {}),
            leadingIcon: const Icon(Icons.clear_rounded, size: 16),
            child: const Text('Clear selection'),
          ),
        if (isFiltered) const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Divider(height: 1)),
        for (final s in available)
          CheckboxMenuButton(
            value: selected.contains(s),
            onChanged: (v) {
              final next = {...selected};
              if (v == true) {
                next.add(s);
              } else {
                next.remove(s);
              }
              onChanged(next);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(s.iconPath, width: 14, height: 14, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(s.label),
              ],
            ),
          ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.count, required this.selected, required this.onTap});

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = selected ? Colors.white : colors.onSurface.withAlpha(170);
    return Material(
      color: selected ? colors.primary : colors.onSurface.withAlpha(10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withAlpha(40) : colors.onSurface.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search field (debounced, stateful) ────────────────────

class _SearchField extends StatefulWidget {
  const _SearchField({required this.initial, required this.onChanged});
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTyping(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      widget.onChanged(value);
    });
    setState(() {}); // refresh suffix-icon visibility
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 36,
      child: TextField(
        controller: _controller,
        onChanged: _onTyping,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search pitches…',
          hintStyle: TextStyle(fontSize: 13, color: colors.onSurface.withAlpha(110)),
          prefixIcon: const Icon(Icons.search_rounded, size: 16),
          prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: _clear,
                ),
          isDense: true,
          filled: true,
          fillColor: colors.onSurface.withAlpha(8),
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

// ─── Sport group header ─────────────────────────────────────

class _SportGroupHeader extends StatelessWidget {
  const _SportGroupHeader({required this.sport, required this.count});
  final Sport sport;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Row(
        children: [
          // Icon disc for visual anchor
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: colors.secondary.withAlpha(22), shape: BoxShape.circle),
            child: Center(child: Image.asset(sport.iconPath, width: 16, height: 16, color: colors.secondary)),
          ),
          const SizedBox(width: 12),
          Text(sport.label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2)),
          const SizedBox(width: 8),
          Text(
            '· $count',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(120), fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 14),
          // Trailing rule that extends to fill — gives the section a
          // clear top boundary across the panel width.
          Expanded(child: Container(height: 1, color: colors.onSurface.withAlpha(20))),
        ],
      ),
    );
  }
}

// ─── Pitch tile ─────────────────────────────────────────────

class _PitchTile extends StatelessWidget {
  const _PitchTile({required this.pitch, required this.venueId, this.width = 280});
  final PitchModel pitch;
  final String venueId;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceAmount = (pitch.pricePerHour / 100).toStringAsFixed(0);
    final cover = pitch.imageUrls.isNotEmpty ? pitch.imageUrls.first : null;
    final photoCount = pitch.imageUrls.length;
    final dimmed = !pitch.active;

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.onSurface.withAlpha(20)),
        ),
        child: Opacity(
          opacity: dimmed ? 0.62 : 1,
          child: InkWell(
            onTap: () => AddEditPitchDialog.show(context, venueId: venueId, pitch: pitch),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Image header with overlays ──
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (cover != null)
                        Image.network(cover, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback(colors))
                      else
                        _imageFallback(colors),
                      // Overall darkening so photos read as backdrops, not
                      // visual noise. Combined with a stronger bottom
                      // gradient so the status pill always pops.
                      if (cover != null)
                        Positioned.fill(
                          child: DecoratedBox(decoration: BoxDecoration(color: Colors.black.withAlpha(60))),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 80,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withAlpha(150), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      // Status pill (top-right)
                      Positioned(top: 10, right: 10, child: _StatusDot(active: pitch.active)),
                      // Photo count (bottom-left)
                      if (photoCount > 1)
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: Colors.black.withAlpha(140), borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.photo_library_outlined, size: 11, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '$photoCount',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Body ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name + edit affordance
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pitch.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(color: colors.onSurface.withAlpha(10), shape: BoxShape.circle),
                            child: Icon(Icons.edit_outlined, size: 14, color: colors.onSurface.withAlpha(150)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Image.asset(pitch.sport.iconPath, width: 13, height: 13, color: colors.secondary),
                          const SizedBox(width: 5),
                          Text(
                            pitch.sport.label,
                            style: theme.textTheme.bodySmall?.copyWith(color: colors.secondary, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.group_outlined, size: 13, color: colors.onSurface.withAlpha(140)),
                          const SizedBox(width: 3),
                          Text(
                            '${pitch.maxPlayers}',
                            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(160), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Mini(icon: pitch.indoor ? Icons.roofing_rounded : Icons.wb_sunny_outlined, label: pitch.indoor ? 'Indoor' : 'Outdoor'),
                          _Mini(icon: Icons.lightbulb_outline, label: pitch.isIlluminated ? 'Lit' : 'No lights', muted: !pitch.isIlluminated),
                          if (pitch.surface != null) _Mini(icon: Icons.grass_outlined, label: pitch.surface!),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: colors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              priceAmount,
                              style: theme.textTheme.titleMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${pitch.currency}/h',
                              style: theme.textTheme.bodySmall?.copyWith(color: colors.primary.withAlpha(180), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageFallback(ColorScheme colors) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.secondary.withAlpha(40), colors.primary.withAlpha(40)],
        ),
      ),
      child: Center(child: Image.asset(pitch.sport.iconPath, width: 44, height: 44, color: Colors.white.withAlpha(200))),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    // White pill with a colored indicator dot and colored text. White
    // background guarantees legibility on any photo; the colored dot +
    // text carry the meaning without shouting like a solid green chip.
    final accent = active ? const Color(0xFF1E7E3F) : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(45), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: accent, letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.icon, required this.label, this.muted = false});
  final IconData icon;
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = muted ? colors.onSurface.withAlpha(110) : colors.onSurface.withAlpha(170);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: colors.onSurface.withAlpha(10), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}

// ─── Empty pitches state ────────────────────────────────────

class _EmptyPitches extends StatelessWidget {
  const _EmptyPitches({required this.venueId});
  final String venueId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: colors.secondary.withAlpha(15), shape: BoxShape.circle),
              child: Icon(Icons.sports_soccer_outlined, size: 32, color: colors.secondary.withAlpha(140)),
            ),
            const SizedBox(height: 18),
            Text('No pitches yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Add your first pitch to start receiving bookings.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(150)),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => AddEditPitchDialog.show(context, venueId: venueId),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add pitch'),
            ),
          ],
        ),
      ),
    );
  }
}
