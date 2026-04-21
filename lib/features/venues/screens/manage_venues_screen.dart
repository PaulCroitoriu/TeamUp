import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/venues/bloc/venue_bloc.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/add_edit_pitch_screen.dart' show AddEditPitchDialog;
import 'package:teamup/features/venues/screens/add_edit_venue_screen.dart' show AddEditVenueDialog;

final _log = Logger();

// Shared spacing constants for consistency.
const _pad = 40.0;
const _gap = 28.0;

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
          child: _VenuesBody(businessId: businessId),
        );
      },
    );
  }
}

// ─── Body ───────────────────────────────────────────────────

class _VenuesBody extends StatefulWidget {
  const _VenuesBody({required this.businessId});
  final String businessId;

  @override
  State<_VenuesBody> createState() => _VenuesBodyState();
}

class _VenuesBodyState extends State<_VenuesBody> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VenueBloc, VenueState>(
        builder: (context, state) {
          return state.maybeMap(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            loaded: (s) {
              if (s.venues.isEmpty) {
                return _EmptyState(businessId: widget.businessId, bloc: context.read<VenueBloc>());
              }
              if (_selectedIndex >= s.venues.length) _selectedIndex = 0;
              return _VenueOverview(
                venue: s.venues[_selectedIndex],
                venues: s.venues,
                selectedIndex: _selectedIndex,
                onVenueSelected: (i) => setState(() => _selectedIndex = i),
                businessId: widget.businessId,
                bloc: context.read<VenueBloc>(),
              );
            },
            error: (e) => Center(child: Text(e.message)),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.businessId, required this.bloc});
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
              child: Icon(Icons.storefront_rounded, size: 40, color: colors.primary.withAlpha(128)),
            ),
            const SizedBox(height: 24),
            Text('Add your venue', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Set up your venue to start receiving\nbookings from players nearby',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(128), height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: () => AddEditVenueDialog.show(context, businessId: businessId, bloc: bloc),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add venue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Venue overview (main view) ─────────────────────────────

class _VenueOverview extends StatelessWidget {
  const _VenueOverview({
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

  // ── Header ──

  Widget _buildVenueHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        if (venues.length > 1)
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedIndex,
              isDense: true,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: colors.onSurface.withAlpha(128)),
              items: [for (var i = 0; i < venues.length; i++) DropdownMenuItem(value: i, child: Text(venues[i].name))],
              onChanged: (i) {
                if (i != null) onVenueSelected(i);
              },
            ),
          )
        else
          Text(venue.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Edit venue',
          style: IconButton.styleFrom(backgroundColor: colors.onSurface.withAlpha(10)),
          onPressed: () => AddEditVenueDialog.show(context, businessId: businessId, bloc: bloc, venue: venue),
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.add_business_outlined, size: 20),
          tooltip: 'Add venue',
          style: IconButton.styleFrom(backgroundColor: colors.onSurface.withAlpha(10)),
          onPressed: () => AddEditVenueDialog.show(context, businessId: businessId, bloc: bloc),
        ),
      ],
    );
  }

  // ── Venue info (wide layout left panel) ──

  Widget _buildVenueInfo(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(_pad),
      children: [
        _buildVenueHeader(context),
        const SizedBox(height: _gap),
        _VenueHeroImage(venue: venue),
        const SizedBox(height: _gap),
        _VenueDetails(venue: venue),
      ],
    );
  }

  // ── Pitches panel (wide layout right panel) ──

  Widget _buildPitchesPanel(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_pad, _pad, _pad, _gap),
          child: Row(
            children: [
              Text('Pitches', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => AddEditPitchDialog.show(context, venueId: venue.id),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(child: _PitchesListView(venueId: venue.id)),
      ],
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildVenueInfo(context)),
          VerticalDivider(width: 1, thickness: 1, color: Theme.of(context).colorScheme.onSurface.withAlpha(20)),
          Expanded(flex: 5, child: _buildPitchesPanel(context)),
        ],
      );
    }

    // Mobile: single-column scroll
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(padding: const EdgeInsets.fromLTRB(_pad, _gap, _pad, 0), child: _buildVenueHeader(context)),
          ),
        ),
        SliverToBoxAdapter(child: _buildVenueInfoSliver(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(_pad, _pad, _pad, _gap),
            child: Row(
              children: [
                Text('Pitches', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => AddEditPitchDialog.show(context, venueId: venue.id),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
        ),
        _PitchesSliver(venueId: venue.id, hPad: _pad),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildVenueInfoSliver(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_pad, 12, _pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VenueHeroImage(venue: venue),
          const SizedBox(height: _gap),
          _VenueDetails(venue: venue),
        ],
      ),
    );
  }
}

// ─── Shared venue widgets ───────────────────────────────────

class _VenueHeroImage extends StatelessWidget {
  const _VenueHeroImage({required this.venue});
  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: colors.primary.withAlpha(12),
          image: venue.imageUrl != null ? DecorationImage(image: NetworkImage(venue.imageUrl!), fit: BoxFit.cover) : null,
        ),
        child: venue.imageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_rounded, size: 40, color: colors.primary.withAlpha(64)),
                  const SizedBox(height: 8),
                  Text('Add a cover photo', style: theme.textTheme.bodySmall?.copyWith(color: colors.primary.withAlpha(102))),
                ],
              )
            : null,
      ),
    );
  }
}

class _VenueDetails extends StatelessWidget {
  const _VenueDetails({required this.venue});
  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(icon: Icons.location_on_outlined, text: '${venue.address}, ${venue.city}'),
        if (venue.phone != null) _InfoRow(icon: Icons.phone_outlined, text: venue.phone!),
        if (venue.description != null) ...[
          const SizedBox(height: 12),
          Text(venue.description!, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(179), height: 1.5)),
        ],
        if (venue.sports.isNotEmpty) ...[
          const SizedBox(height: _gap),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: venue.sports.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: colors.secondary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  s.label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.secondary),
                ),
              );
            }).toList(),
          ),
        ],
        if (venue.amenities.isNotEmpty) ...[
          const SizedBox(height: _gap),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: venue.amenities.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.onSurface.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.onSurface.withAlpha(20)),
                ),
                child: Text(
                  a,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurface.withAlpha(153)),
                ),
              );
            }).toList(),
          ),
        ],
        if (venue.openingHours.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Opening hours', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'].where((d) => venue.openingHours.containsKey(d)).map((
            day,
          ) {
            final h = venue.openingHours[day]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${day[0].toUpperCase()}${day.substring(1)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(140)),
                    ),
                  ),
                  Text(
                    h.closed ? 'Closed' : '${h.open} – ${h.close}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: h.closed ? colors.error.withAlpha(180) : colors.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.onSurface.withAlpha(102)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(179))),
          ),
        ],
      ),
    );
  }
}

// ─── Pitches list view (for wide layout) ────────────────────

class _PitchesListView extends StatelessWidget {
  const _PitchesListView({required this.venueId});
  final String venueId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return StreamBuilder<List<PitchModel>>(
      stream: VenueService().streamAllPitches(venueId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final pitches = snapshot.data ?? [];
        if (pitches.isEmpty) return _EmptyPitches(colors: colors, theme: theme);

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(_pad, 0, _pad, _pad),
          itemCount: pitches.length,
          separatorBuilder: (_, __) => const SizedBox(height: _gap),
          itemBuilder: (context, i) => _PitchCard(pitch: pitches[i], venueId: venueId),
        );
      },
    );
  }
}

// ─── Pitches sliver (for mobile scroll) ─────────────────────

class _PitchesSliver extends StatelessWidget {
  const _PitchesSliver({required this.venueId, required this.hPad});
  final String venueId;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return StreamBuilder<List<PitchModel>>(
      stream: VenueService().streamAllPitches(venueId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(_pad),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final pitches = snapshot.data ?? [];
        if (pitches.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: _gap),
              child: _EmptyPitches(colors: colors, theme: theme),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          sliver: SliverList.separated(
            itemCount: pitches.length,
            separatorBuilder: (_, __) => const SizedBox(height: _gap),
            itemBuilder: (context, i) => _PitchCard(pitch: pitches[i], venueId: venueId),
          ),
        );
      },
    );
  }
}

class _EmptyPitches extends StatelessWidget {
  const _EmptyPitches({required this.colors, required this.theme});
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_pad),
      decoration: BoxDecoration(
        border: Border.all(color: colors.onSurface.withAlpha(26)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_soccer_outlined, size: 36, color: colors.onSurface.withAlpha(51)),
          const SizedBox(height: 12),
          Text('No pitches yet', style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(128))),
          const SizedBox(height: 4),
          Text(
            'Add your first pitch to start receiving bookings',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(89)),
          ),
        ],
      ),
    );
  }
}

// ─── Pitch card (horizontal: image left, details right) ─────

class _PitchCard extends StatefulWidget {
  const _PitchCard({required this.pitch, required this.venueId});
  final PitchModel pitch;
  final String venueId;

  @override
  State<_PitchCard> createState() => _PitchCardState();
}

class _PitchCardState extends State<_PitchCard> {
  int _photoPage = 0;

  static const _imageWidth = 180.0;

  void _showFullImage(BuildContext context, List<String> urls, int initial) {
    showDialog(
      context: context,
      builder: (_) => _FullImageViewer(urls: urls, initialIndex: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pitch = widget.pitch;
    final priceAmount = (pitch.pricePerHour / 100).toStringAsFixed(0);
    final hasPhotos = pitch.imageUrls.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: image ──
          SizedBox(width: _imageWidth, height: 210, child: hasPhotos ? _buildCarousel(pitch, colors) : _buildPlaceholder(pitch, colors)),

          // ── Right: details ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + status
                  Row(
                    children: [
                      Expanded(
                        child: Text(pitch.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      _StatusBadge(active: pitch.active),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sport
                  Row(
                    children: [
                      Image.asset(pitch.sport.iconPath, width: 18, height: 18, color: colors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        pitch.sport.label,
                        style: theme.textTheme.bodyMedium?.copyWith(color: colors.secondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        priceAmount,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: colors.primary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pitch.currency}/h',
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.primary.withAlpha(150), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Chips + edit button
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Chip(icon: Icons.group_outlined, label: '${pitch.maxPlayers} players'),
                            if (pitch.surface != null) _Chip(icon: Icons.grass_outlined, label: pitch.surface!),
                            _Chip(icon: pitch.indoor ? Icons.roofing_rounded : Icons.wb_sunny_outlined, label: pitch.indoor ? 'Indoor' : 'Outdoor'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => AddEditPitchDialog.show(context, venueId: widget.venueId, pitch: pitch),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Edit pitch',
                        style: IconButton.styleFrom(backgroundColor: colors.onSurface.withAlpha(10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(PitchModel pitch, ColorScheme colors) {
    return GestureDetector(
      onTap: () => _showFullImage(context, pitch.imageUrls, _photoPage),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: pitch.imageUrls.length,
            onPageChanged: (i) => setState(() => _photoPage = i),
            itemBuilder: (_, i) {
              return Image.network(
                pitch.imageUrls[i],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  final pct = progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null;
                  return Center(child: CircularProgressIndicator(value: pct, strokeWidth: 2));
                },
                errorBuilder: (context, error, stack) {
                  _log.e('Image load failed', error: error);
                  return Center(child: Icon(Icons.broken_image_outlined, size: 32, color: colors.onSurface.withAlpha(60)));
                },
              );
            },
          ),
          if (pitch.imageUrls.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pitch.imageUrls.length,
                  (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: i == _photoPage ? Colors.white : Colors.white.withAlpha(100)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(PitchModel pitch, ColorScheme colors) {
    return Container(
      color: colors.secondary.withAlpha(10),
      child: Center(child: Image.asset(pitch.sport.iconPath, width: 44, height: 44, color: colors.secondary.withAlpha(50))),
    );
  }
}

// ─── Status badge ───────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF34A853) : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Full-screen image viewer ───────────────────────────────

class _FullImageViewer extends StatefulWidget {
  const _FullImageViewer({required this.urls, required this.initialIndex});
  final List<String> urls;
  final int initialIndex;

  @override
  State<_FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<_FullImageViewer> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Swipeable images
          PageView.builder(
            controller: _controller,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              child: Center(
                child: Image.network(
                  widget.urls[i],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
                  },
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              style: IconButton.styleFrom(backgroundColor: Colors.white.withAlpha(25)),
            ),
          ),
          // Counter
          if (widget.urls.length > 1)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withAlpha(120), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${_current + 1} / ${widget.urls.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          // Dot indicators
          if (widget.urls.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.urls.length,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: i == _current ? Colors.white : Colors.white.withAlpha(80)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Chip for pitch details ─────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.onSurface.withAlpha(8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.onSurface.withAlpha(18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: colors.onSurface.withAlpha(100)), const SizedBox(width: 5)],
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurface.withAlpha(140)),
          ),
        ],
      ),
    );
  }
}
