import 'package:flutter/material.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/features/bookings/screens/pitch_booking_screen.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

class VenueBrowseScreen extends StatefulWidget {
  const VenueBrowseScreen({super.key, required this.venue, this.initialSport});

  final VenueModel venue;
  final Sport? initialSport;

  @override
  State<VenueBrowseScreen> createState() => _VenueBrowseScreenState();
}

class _VenueBrowseScreenState extends State<VenueBrowseScreen> {
  final _service = VenueService();
  late Sport? _sport = widget.initialSport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final venue = widget.venue;

    return Scaffold(
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: venue.imageUrl != null ? 220 : 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(venue.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                background: venue.imageUrl != null
                    ? Image.network(venue.imageUrl!, fit: BoxFit.cover)
                    : Container(color: colors.primary.withAlpha(15)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: colors.onSurface.withAlpha(140)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${venue.address}, ${venue.city}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(180)),
                          ),
                        ),
                      ],
                    ),
                    if (venue.description != null) ...[
                      const SizedBox(height: 12),
                      Text(venue.description!, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(180), height: 1.5)),
                    ],
                    if (venue.amenities.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final a in venue.amenities)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.onSurface.withAlpha(10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: colors.onSurface.withAlpha(20)),
                              ),
                              child: Text(
                                a,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onSurface.withAlpha(160)),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text('Pitches', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    if (venue.sports.length > 1)
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _SportPill(label: 'All', selected: _sport == null, onTap: () => setState(() => _sport = null)),
                            for (final s in venue.sports)
                              _SportPill(
                                label: s.label,
                                icon: s.iconPath,
                                selected: _sport == s,
                                onTap: () => setState(() => _sport = _sport == s ? null : s),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            StreamBuilder<List<PitchModel>>(
              stream: _service.streamPitches(venue.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                var pitches = snap.data ?? [];
                if (_sport != null) {
                  pitches = pitches.where((p) => p.sport == _sport).toList();
                }
                if (pitches.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          _sport == null ? 'No pitches available' : 'No ${_sport!.label.toLowerCase()} pitches at this venue',
                          style: TextStyle(color: colors.onSurface.withAlpha(140)),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList.separated(
                    itemCount: pitches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _PitchCard(pitch: pitches[i], venue: venue),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SportPill extends StatelessWidget {
  const _SportPill({required this.label, required this.selected, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? colors.primary : colors.onSurface.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Image.asset(icon!, width: 14, height: 14, color: selected ? Colors.white : colors.onSurface.withAlpha(160)),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PitchCard extends StatelessWidget {
  const _PitchCard({required this.pitch, required this.venue});
  final PitchModel pitch;
  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceAmount = (pitch.pricePerHour / 100).toStringAsFixed(0);
    final cover = pitch.imageUrls.isNotEmpty ? pitch.imageUrls.first : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PitchBookingScreen(venue: venue, pitch: pitch),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: cover != null
                  ? Image.network(cover, fit: BoxFit.cover)
                  : Container(
                      color: colors.secondary.withAlpha(15),
                      child: Center(child: Image.asset(pitch.sport.iconPath, width: 28, height: 28, color: colors.secondary.withAlpha(120))),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(pitch.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Image.asset(pitch.sport.iconPath, width: 14, height: 14, color: colors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          pitch.sport.label,
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.secondary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.group_outlined, size: 14, color: colors.onSurface.withAlpha(140)),
                        const SizedBox(width: 3),
                        Text('${pitch.maxPlayers}', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(160))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
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
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.primary.withAlpha(160), fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, color: colors.onSurface.withAlpha(140)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
