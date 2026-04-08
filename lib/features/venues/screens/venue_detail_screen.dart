import 'package:flutter/material.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/add_edit_pitch_screen.dart';

class VenueDetailScreen extends StatelessWidget {
  const VenueDetailScreen({super.key, required this.venue});
  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(title: Text(venue.name)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditPitchScreen(venueId: venue.id),
          ),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: CustomScrollView(
            slivers: [
              // ── Venue info header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image or placeholder
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: colors.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(16),
                          image: venue.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(venue.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: venue.imageUrl == null
                            ? Center(
                                child: Icon(
                                  Icons.store_rounded,
                                  size: 48,
                                  color: colors.primary.withAlpha(77),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Address
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 18,
                              color: colors.onSurface.withAlpha(128)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${venue.address}, ${venue.city}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface.withAlpha(179),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (venue.phone != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined,
                                size: 18,
                                color: colors.onSurface.withAlpha(128)),
                            const SizedBox(width: 6),
                            Text(
                              venue.phone!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface.withAlpha(179),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (venue.description != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          venue.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withAlpha(179),
                          ),
                        ),
                      ],
                      if (venue.sports.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: venue.sports
                              .map((s) => Chip(
                                    label: Text(s.label),
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Pitches',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Pitches list (real-time) ──
              _PitchesList(
                venueId: venue.id,
                isWide: isWide,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PitchesList extends StatelessWidget {
  const _PitchesList({required this.venueId, required this.isWide});
  final String venueId;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final venueService = VenueService();

    return StreamBuilder<List<PitchModel>>(
      stream: venueService.streamPitches(venueId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )),
          );
        }

        final pitches = snapshot.data ?? [];

        if (pitches.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No pitches yet — tap + to add one',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withAlpha(102),
                  ),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 8,
          ),
          sliver: SliverList.separated(
            itemCount: pitches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _PitchCard(pitch: pitches[i]),
          ),
        );
      },
    );
  }
}

class _PitchCard extends StatelessWidget {
  const _PitchCard({required this.pitch});
  final PitchModel pitch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceDisplay =
        '${(pitch.pricePerHour / 100).toStringAsFixed(0)} ${pitch.currency}/h';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Sport icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.secondary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.sports_soccer_rounded,
                color: colors.secondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pitch.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pitch.sport.label} · ${pitch.maxPlayers} players'
                    '${pitch.surface != null ? ' · ${pitch.surface}' : ''}'
                    '${pitch.indoor ? ' · Indoor' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withAlpha(128),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              priceDisplay,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
