import 'package:flutter/material.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/theme/sport_tile.dart';
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/features/games/models/game_model.dart';
import 'package:teamup/features/games/screens/game_detail_screen.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
String _t(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Browse open games that still need players. Reuses Explore's sport / city /
/// search filters; lists each game as a card that deep-links into the game
/// detail (where the player can join or request to join). Self-contained on its
/// own streams so Explore only has to render it.
class OpenGamesView extends StatefulWidget {
  const OpenGamesView({super.key, required this.sports, required this.city, required this.search});

  final Set<Sport> sports;
  final String? city;
  final String search;

  @override
  State<OpenGamesView> createState() => _OpenGamesViewState();
}

class _OpenGamesViewState extends State<OpenGamesView> {
  final _gameService = GameService();
  final _venueService = VenueService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VenueModel>>(
      stream: _venueService.streamVenues(),
      builder: (context, venuesSnap) {
        final venuesById = {for (final v in venuesSnap.data ?? const <VenueModel>[]) v.id: v};
        return StreamBuilder<List<PitchModel>>(
          stream: _venueService.streamPitchesAcrossVenues(),
          builder: (context, pitchSnap) {
            final pitchesById = {for (final p in pitchSnap.data ?? const <PitchModel>[]) p.id: p};
            return StreamBuilder<List<GameModel>>(
              stream: _gameService.streamOpenGames(),
              builder: (context, gameSnap) {
                if (gameSnap.connectionState == ConnectionState.waiting && !gameSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (gameSnap.hasError) {
                  return Center(child: Text(gameSnap.error.toString()));
                }

                final now = DateTime.now();
                var games = (gameSnap.data ?? const <GameModel>[]).where((g) => g.endTime.isAfter(now)).toList();

                if (widget.sports.isNotEmpty) {
                  games = games.where((g) => widget.sports.contains(g.sport)).toList();
                }
                if (widget.city != null) {
                  games = games.where((g) => venuesById[g.venueId]?.city == widget.city).toList();
                }
                final q = widget.search.trim().toLowerCase();
                if (q.isNotEmpty) {
                  games = games.where((g) {
                    final v = venuesById[g.venueId];
                    final p = pitchesById[g.pitchId];
                    return g.sport.label.toLowerCase().contains(q) ||
                        (p?.name.toLowerCase().contains(q) ?? false) ||
                        (v?.name.toLowerCase().contains(q) ?? false) ||
                        (v?.city.toLowerCase().contains(q) ?? false);
                  }).toList();
                }

                if (games.isEmpty) return const _EmptyGames();

                // Two columns on desktop so cards don't stretch; one on mobile.
                return LayoutBuilder(
                  builder: (context, c) {
                    const gap = 12.0;
                    final cols = c.maxWidth >= 760 ? 2 : 1;
                    final itemW = cols == 1 ? c.maxWidth - 40 : (c.maxWidth - 40 - gap) / 2;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final g in games)
                            SizedBox(
                              width: itemW,
                              child: _GameCard(
                                game: g,
                                venue: venuesById[g.venueId],
                                pitch: pitchesById[g.pitchId],
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: g.id)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.venue, required this.pitch, required this.onTap});
  final GameModel game;
  final VenueModel? venue;
  final PitchModel? pitch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final perPlayer = (game.pricePerHour / 100 / game.capacity).round();
    final needs = game.spotsOpen;
    final start = game.startTime;
    final title = pitch?.name ?? game.sport.label;
    final where = venue == null ? game.sport.label : '${venue!.name} · ${venue!.city}';

    return Material(
      color: TUColors.surface,
      borderRadius: BorderRadius.circular(TUColors.rLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rLg),
            border: Border.all(color: TUColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: game.sport.color, borderRadius: BorderRadius.circular(13)),
                    child: Center(child: SportGlyph(sport: game.sport, size: 26, color: Colors.white)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: TUColors.ink),
                              ),
                            ),
                            if (game.requiresApproval) ...[
                              const SizedBox(width: 8),
                              const _Pill(label: 'Approval', bg: TUColors.surface2, fg: TUColors.ink2),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: TUColors.ink3),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                where,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: TUColors.ink2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$perPlayer ${game.currency}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: TUColors.brand700)),
                      const Text('per player', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TUColors.ink3)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 13),
              const Divider(height: 1, thickness: 1, color: TUColors.line),
              const SizedBox(height: 13),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 15, color: TUColors.ink3),
                  const SizedBox(width: 6),
                  Text(
                    '${_weekdays[start.weekday - 1]} ${start.day} · ${_t(start)}–${_t(game.endTime)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TUColors.ink2),
                  ),
                  const Spacer(),
                  Icon(Icons.group_outlined, size: 15, color: needs > 0 ? TUColors.brand700 : TUColors.ink3),
                  const SizedBox(width: 6),
                  Text(
                    needs > 0 ? 'Needs $needs more' : 'Full',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: needs > 0 ? TUColors.brand700 : TUColors.ink3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(TUColors.rPill)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

class _EmptyGames extends StatelessWidget {
  const _EmptyGames();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer_outlined, size: 48, color: TUColors.ink3.withAlpha(120)),
            const SizedBox(height: 16),
            const Text('No open games right now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: TUColors.ink)),
            const SizedBox(height: 8),
            const Text(
              'Try a different sport or city — or open one of your own from a pitch.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: TUColors.ink3),
            ),
          ],
        ),
      ),
    );
  }
}
