import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/venues/bloc/venue_bloc.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/add_edit_pitch_screen.dart';
import 'package:teamup/features/venues/screens/add_edit_venue_screen.dart';

class ManageVenuesScreen extends StatelessWidget {
  const ManageVenuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final businessId = authState.maybeMap(
          authenticated: (s) => s.user.businessId,
          orElse: () => null,
        );

        if (businessId == null) {
          return const Scaffold(
            body: Center(child: Text('No business linked to this account')),
          );
        }

        return BlocProvider(
          create: (_) =>
              VenueBloc(venueService: VenueService())
                ..add(VenueEvent.loadBusinessVenues(businessId)),
          child: _VenuesBody(businessId: businessId),
        );
      },
    );
  }
}

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
                return _EmptyState(
                  businessId: widget.businessId,
                  bloc: context.read<VenueBloc>(),
                );
              }

              if (_selectedIndex >= s.venues.length) {
                _selectedIndex = 0;
              }
              final venue = s.venues[_selectedIndex];

              return _VenueOverview(
                venue: venue,
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

// ─── Empty state ─────────────────────────────────────────────

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
              decoration: BoxDecoration(
                color: colors.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 40,
                color: colors.primary.withAlpha(128),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add your venue',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up your venue to start receiving\nbookings from players nearby',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withAlpha(128),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: AddEditVenueScreen(businessId: businessId),
                    ),
                  ),
                ),
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

// ─── Venue overview (main view) ──────────────────────────────

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

  Widget _buildVenueHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        // Venue name or dropdown
        if (venues.length > 1)
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedIndex,
              isDense: true,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: colors.onSurface.withAlpha(128),
              ),
              items: [
                for (var i = 0; i < venues.length; i++)
                  DropdownMenuItem(value: i, child: Text(venues[i].name)),
              ],
              onChanged: (i) {
                if (i != null) onVenueSelected(i);
              },
            ),
          )
        else
          Text(
            venue.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        const Spacer(),
        // Edit
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Edit venue',
          style: IconButton.styleFrom(
            backgroundColor: colors.onSurface.withAlpha(10),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: AddEditVenueScreen(businessId: businessId, venue: venue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Add venue
        IconButton(
          icon: const Icon(Icons.add_business_outlined, size: 20),
          tooltip: 'Add venue',
          style: IconButton.styleFrom(
            backgroundColor: colors.onSurface.withAlpha(10),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: AddEditVenueScreen(businessId: businessId),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Venue header (name + actions)
        _buildVenueHeader(context),
        const SizedBox(height: 16),
        // Hero image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: colors.primary.withAlpha(12),
              image: venue.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(venue.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: venue.imageUrl == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 44,
                        color: colors.primary.withAlpha(64),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a cover photo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.primary.withAlpha(102),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),

        // Info rows
        _InfoRow(
          icon: Icons.location_on_outlined,
          text: '${venue.address}, ${venue.city}',
        ),
        if (venue.phone != null)
          _InfoRow(icon: Icons.phone_outlined, text: venue.phone!),
        if (venue.description != null) ...[
          const SizedBox(height: 12),
          Text(
            venue.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withAlpha(179),
              height: 1.5,
            ),
          ),
        ],
        if (venue.sports.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: venue.sports.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.secondary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.secondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        if (venue.amenities.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: venue.amenities.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.onSurface.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.onSurface.withAlpha(20)),
                ),
                child: Text(
                  a,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface.withAlpha(153),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPitchesPanel(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            children: [
              Text(
                'Pitches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditPitchScreen(venueId: venue.id),
                  ),
                ),
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      // Two-column: venue info left, pitches right
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: _buildVenueInfo(context)),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
          ),
          // Right — pitches (scrollable)
          Expanded(flex: 4, child: _buildPitchesPanel(context)),
        ],
      );
    }

    // Mobile: single-column scroll
    return CustomScrollView(
      slivers: [
        // Header row inline
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _buildVenueHeader(context),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildVenueInfoSliver(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 12, 12),
            child: Row(
              children: [
                Text(
                  'Pitches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditPitchScreen(venueId: venue.id),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
        ),
        _PitchesSliver(venueId: venue.id, hPad: 20),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildVenueInfoSliver(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: colors.primary.withAlpha(12),
                image: venue.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(venue.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: venue.imageUrl == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 44,
                          color: colors.primary.withAlpha(64),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a cover photo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.primary.withAlpha(102),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: '${venue.address}, ${venue.city}',
          ),
          if (venue.phone != null)
            _InfoRow(icon: Icons.phone_outlined, text: venue.phone!),
          if (venue.description != null) ...[
            const SizedBox(height: 12),
            Text(
              venue.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withAlpha(179),
                height: 1.5,
              ),
            ),
          ],
          if (venue.sports.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: venue.sports.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.secondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Info row ────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.onSurface.withAlpha(102)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withAlpha(179),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pitches list view (for wide layout) ─────────────────────

class _PitchesListView extends StatelessWidget {
  const _PitchesListView({required this.venueId});
  final String venueId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return StreamBuilder<List<PitchModel>>(
      stream: VenueService().streamPitches(venueId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final pitches = snapshot.data ?? [];

        if (pitches.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_soccer_outlined,
                    size: 36,
                    color: colors.onSurface.withAlpha(51),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No pitches yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withAlpha(128),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add your first pitch to start\nreceiving bookings',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withAlpha(89),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: pitches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _PitchCard(pitch: pitches[i], venueId: venueId),
        );
      },
    );
  }
}

// ─── Pitches sliver (real-time) ──────────────────────────────

class _PitchesSliver extends StatelessWidget {
  const _PitchesSliver({required this.venueId, required this.hPad});
  final String venueId;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return StreamBuilder<List<PitchModel>>(
      stream: VenueService().streamPitches(venueId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final pitches = snapshot.data ?? [];

        if (pitches.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.onSurface.withAlpha(26),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_soccer_outlined,
                      size: 36,
                      color: colors.onSurface.withAlpha(51),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No pitches yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withAlpha(128),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add your first pitch to start receiving bookings',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withAlpha(89),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          sliver: SliverList.separated(
            itemCount: pitches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                _PitchCard(pitch: pitches[i], venueId: venueId),
          ),
        );
      },
    );
  }
}

// ─── Pitch card ──────────────────────────────────────────────

class _PitchCard extends StatelessWidget {
  const _PitchCard({required this.pitch, required this.venueId});
  final PitchModel pitch;
  final String venueId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final price =
        '${(pitch.pricePerHour / 100).toStringAsFixed(0)} ${pitch.currency}/h';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditPitchScreen(venueId: venueId, pitch: pitch),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.secondary.withAlpha(18),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.sports_soccer_rounded,
                  color: colors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Info
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
                    const SizedBox(height: 3),
                    Text(
                      [
                        pitch.sport.label,
                        '${pitch.maxPlayers}v${pitch.maxPlayers}',
                        if (pitch.surface != null) pitch.surface!,
                        if (pitch.indoor) 'Indoor',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withAlpha(115),
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  price,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
