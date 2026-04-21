import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/add_edit_pitch_screen.dart' show AddEditPitchDialog;

final _log = Logger();

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({super.key, required this.venue});
  final VenueModel venue;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    if (!isWide) return _MobileLayout(venue: widget.venue);

    return Scaffold(
      appBar: AppBar(title: Text(widget.venue.name)),
      body: Row(
        children: [
          SizedBox(width: 300, child: _VenueInfoPanel(venue: widget.venue)),
          const VerticalDivider(width: 1),
          Expanded(
            child: _PitchesListPanel(
              venueId: widget.venue.id,
              onAdd: () => AddEditPitchDialog.show(context, venueId: widget.venue.id),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Left panel: venue info ──────────────────────────────────

class _VenueInfoPanel extends StatelessWidget {
  const _VenueInfoPanel({required this.venue});
  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Image or placeholder
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: colors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
            image: venue.imageUrl != null ? DecorationImage(image: NetworkImage(venue.imageUrl!), fit: BoxFit.cover) : null,
          ),
          child: venue.imageUrl == null ? Center(child: Icon(Icons.store_rounded, size: 40, color: colors.primary.withAlpha(77))) : null,
        ),
        const SizedBox(height: 16),

        // Address
        _InfoRow(icon: Icons.location_on_outlined, text: '${venue.address}, ${venue.city}'),
        if (venue.phone != null) ...[const SizedBox(height: 8), _InfoRow(icon: Icons.phone_outlined, text: venue.phone!)],
        if (venue.description != null) ...[
          const SizedBox(height: 14),
          Text(venue.description!, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(160), height: 1.5)),
        ],
        if (venue.sports.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: venue.sports.map((s) => Chip(label: Text(s.label), visualDensity: VisualDensity.compact)).toList(),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.onSurface.withAlpha(120)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(160))),
        ),
      ],
    );
  }
}

// ─── Right panel: pitches list ───────────────────────────────

class _PitchesListPanel extends StatelessWidget {
  const _PitchesListPanel({required this.venueId, required this.onAdd});
  final String venueId;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
          child: Row(
            children: [
              Text('Pitches', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton.filled(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 20),
                style: IconButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<PitchModel>>(
            stream: VenueService().streamPitches(venueId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final pitches = snapshot.data ?? [];
              if (pitches.isEmpty) {
                return Center(
                  child: Text('No pitches yet', style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(102))),
                );
              }
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: pitches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _PitchCard(pitch: pitches[i], venueId: venueId),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Pitch card (enhanced — photo carousel + all info) ──────

class _PitchCard extends StatefulWidget {
  const _PitchCard({required this.pitch, required this.venueId});
  final PitchModel pitch;
  final String venueId;

  @override
  State<_PitchCard> createState() => _PitchCardState();
}

class _PitchCardState extends State<_PitchCard> {
  int _photoPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pitch = widget.pitch;
    final price = '${(pitch.pricePerHour / 100).toStringAsFixed(0)} ${pitch.currency}/h';
    final hasPhotos = pitch.imageUrls.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo carousel or placeholder ──
          SizedBox(
            height: 180,
            width: double.infinity,
            child: hasPhotos
                ? Stack(
                    children: [
                      PageView.builder(
                        itemCount: pitch.imageUrls.length,
                        onPageChanged: (i) => setState(() => _photoPage = i),
                        itemBuilder: (_, i) {
                          final url = pitch.imageUrls[i];
                          _log.d('Loading image $i: ${url.substring(0, url.length.clamp(0, 80))}…');
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              final pct = progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null;
                              _log.d(
                                  'Image $i loading: ${pct != null ? '${(pct * 100).toStringAsFixed(0)}%' : '${progress.cumulativeBytesLoaded} bytes'}');
                              return Center(
                                child: CircularProgressIndicator(
                                  value: pct,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) {
                              _log.e('Image $i failed', error: error);
                              return Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                  color: colors.onSurface.withAlpha(60),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      if (pitch.imageUrls.length > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              pitch.imageUrls.length,
                              (i) => Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _photoPage ? Colors.white : Colors.white.withAlpha(100),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Container(
                    color: colors.secondary.withAlpha(12),
                    child: Center(child: Icon(Icons.sports_soccer_rounded, size: 56, color: colors.secondary.withAlpha(60))),
                  ),
          ),

          // ── Info section ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(pitch.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: colors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        price,
                        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _PitchDetail(icon: Icons.sports_rounded, label: pitch.sport.label),
                    _PitchDetail(icon: Icons.group_outlined, label: '${pitch.maxPlayers} players'),
                    if (pitch.surface != null) _PitchDetail(icon: Icons.grass_outlined, label: pitch.surface!),
                    _PitchDetail(icon: pitch.indoor ? Icons.roofing_rounded : Icons.wb_sunny_outlined, label: pitch.indoor ? 'Indoor' : 'Outdoor'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: pitch.active ? const Color(0xFF34A853) : colors.error),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pitch.active ? 'Active' : 'Inactive',
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(100), fontSize: 12),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => AddEditPitchDialog.show(context, venueId: widget.venueId, pitch: pitch),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchDetail extends StatelessWidget {
  const _PitchDetail({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: colors.onSurface.withAlpha(100)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurface.withAlpha(150)),
        ),
      ],
    );
  }
}

// ─── Mobile layout (unchanged single-column) ─────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.venue});
  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(venue.name)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        onPressed: () => AddEditPitchDialog.show(context, venueId: venue.id),
        child: const Icon(Icons.add_rounded),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: colors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(16),
                      image: venue.imageUrl != null ? DecorationImage(image: NetworkImage(venue.imageUrl!), fit: BoxFit.cover) : null,
                    ),
                    child: venue.imageUrl == null ? Center(child: Icon(Icons.store_rounded, size: 48, color: colors.primary.withAlpha(77))) : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: colors.onSurface.withAlpha(128)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${venue.address}, ${venue.city}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(179)),
                        ),
                      ),
                    ],
                  ),
                  if (venue.phone != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 18, color: colors.onSurface.withAlpha(128)),
                        const SizedBox(width: 6),
                        Text(venue.phone!, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(179))),
                      ],
                    ),
                  ],
                  if (venue.description != null) ...[
                    const SizedBox(height: 16),
                    Text(venue.description!, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(179))),
                  ],
                  if (venue.sports.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: venue.sports.map((s) => Chip(label: Text(s.label), visualDensity: VisualDensity.compact)).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Pitches', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          StreamBuilder<List<PitchModel>>(
            stream: VenueService().streamPitches(venue.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                  ),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(102)),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList.separated(
                  itemCount: pitches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _PitchCard(pitch: pitches[i], venueId: venue.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
