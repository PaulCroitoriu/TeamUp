import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/game_status.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/theme/sport_tile.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/bookings/bloc/booking_bloc.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/bookings/screens/manage_bookings_screen.dart'
    show BookingCard;
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/core/enums/join_request_status.dart';
import 'package:teamup/features/games/models/game_model.dart';
import 'package:teamup/features/games/models/join_request_model.dart';
import 'package:teamup/features/games/screens/game_detail_screen.dart';
import 'package:teamup/shared/widgets/page_header.dart';

class MyGamesScreen extends StatelessWidget {
  const MyGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userId = authState.maybeMap(
          authenticated: (s) => s.user.uid,
          orElse: () => null,
        );

        if (userId == null) {
          return const Scaffold(
            body: Center(child: Text('Sign in to see your games')),
          );
        }

        return BlocProvider(
          create: (_) =>
              BookingBloc(bookingService: BookingService())
                ..add(BookingEvent.loadUserBookings(userId)),
          child: _MyGamesBody(userId: userId),
        );
      },
    );
  }
}

class _MyGamesBody extends StatelessWidget {
  const _MyGamesBody({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: TUColors.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(title: 'My Games'),
              const TabBar(
                tabs: [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
              Expanded(
                child: SelectionArea(
                  // Bookings (BookingBloc) + games the user is in (joined or
                  // hosting) are merged into the tabs.
                  child: StreamBuilder<List<GameModel>>(
                    stream: GameService().streamUserGames(userId),
                    builder: (context, gameSnap) {
                      if (gameSnap.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Games failed to load: ${gameSnap.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: TUColors.ink2),
                            ),
                          ),
                        );
                      }
                      final joined = gameSnap.data ?? const <GameModel>[];
                      return StreamBuilder<List<JoinRequestModel>>(
                        stream: GameService().streamMyRequests(userId),
                        builder: (context, reqSnap) {
                          final reqs =
                              reqSnap.data ?? const <JoinRequestModel>[];
                          final active = reqs
                              .where(
                                (r) =>
                                    (r.status == JoinRequestStatus.pending ||
                                        r.status ==
                                            JoinRequestStatus.approved) &&
                                    !joined.any((g) => g.id == r.gameId),
                              )
                              .toList();
                          final statusByGame = {
                            for (final r in active) r.gameId: r.status,
                          };
                          return StreamBuilder<List<GameModel>>(
                            stream: GameService().streamGamesByIds(
                              active.map((r) => r.gameId).toList(),
                            ),
                            builder: (context, rgSnap) {
                              final requestGames =
                                  (rgSnap.data ?? const <GameModel>[])
                                      .map((g) => (g, statusByGame[g.id]!))
                                      .toList();
                              return BlocBuilder<BookingBloc, BookingState>(
                                builder: (context, state) {
                                  return state.maybeMap(
                                    loading: (_) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    loaded: (s) => _Tabs(
                                      bookings: s.bookings,
                                      games: joined,
                                      requestGames: requestGames,
                                      userId: userId,
                                    ),
                                    error: (e) =>
                                        Center(child: Text(e.message)),
                                    orElse: () => const SizedBox.shrink(),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
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

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.bookings,
    required this.games,
    required this.requestGames,
    required this.userId,
  });
  final List<BookingModel> bookings;
  final List<GameModel> games;
  final List<(GameModel, JoinRequestStatus)> requestGames;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Bookings tied to a game are shown as the game row instead (avoids
    // duplicating a hosted open game's booking).
    final plainBookings = bookings.where((b) => b.gameId == null).toList();

    List<Widget> upcoming() {
      final items = <(DateTime, Widget)>[
        for (final b in plainBookings)
          if (b.status != BookingStatus.cancelled && b.endTime.isAfter(now))
            (b.startTime, BookingCard(booking: b)),
        for (final g in games)
          if (g.status != GameStatus.cancelled && g.endTime.isAfter(now))
            (g.startTime, _GameCard(game: g, userId: userId)),
        for (final (g, st) in requestGames)
          if (g.status != GameStatus.cancelled && g.endTime.isAfter(now))
            (
              g.startTime,
              _GameCard(game: g, userId: userId, requestStatus: st),
            ),
      ]..sort((a, b) => a.$1.compareTo(b.$1));
      return [for (final e in items) e.$2];
    }

    List<Widget> past() {
      final items = <(DateTime, Widget)>[
        for (final b in plainBookings)
          if (b.status == BookingStatus.cancelled || !b.endTime.isAfter(now))
            (b.startTime, BookingCard(booking: b)),
        for (final g in games)
          if (!g.endTime.isAfter(now))
            (g.startTime, _GameCard(game: g, userId: userId)),
        for (final (g, st) in requestGames)
          if (!g.endTime.isAfter(now))
            (
              g.startTime,
              _GameCard(game: g, userId: userId, requestStatus: st),
            ),
      ]..sort((a, b) => b.$1.compareTo(a.$1));
      return [for (final e in items) e.$2];
    }

    return TabBarView(
      children: [
        _ItemsList(
          items: upcoming(),
          emptyTitle: 'No upcoming games',
          emptySubtitle: 'Book a pitch or join an open game from Explore',
        ),
        _ItemsList(
          items: past(),
          emptyTitle: 'No past games yet',
          emptySubtitle: 'Your history will show up here',
        ),
      ],
    );
  }
}

class _ItemsList extends StatelessWidget {
  const _ItemsList({
    required this.items,
    required this.emptyTitle,
    required this.emptySubtitle,
  });
  final List<Widget> items;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_soccer_outlined,
                size: 48,
                color: colors.onSurface.withAlpha(60),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withAlpha(140),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => items[i],
    );
  }
}

/// A row for an open game the user is hosting or has joined.
class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.userId,
    this.requestStatus,
  });
  final GameModel game;
  final String userId;
  final JoinRequestStatus? requestStatus;

  static const _months = [
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
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isHost = game.hostId == userId;
    final full = game.spotsOpen <= 0 || game.status != GameStatus.open;
    final now = DateTime.now();
    final isLive = !game.startTime.isAfter(now) && game.endTime.isAfter(now);
    final start = game.startTime;

    return Material(
      color: TUColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: game.id)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLive ? TUColors.brand : TUColors.line,
              width: isLive ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // date block
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: TUColors.brandTint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _weekdays[start.weekday - 1].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: TUColors.brand700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      '${start.day}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: TUColors.ink,
                      ),
                    ),
                    Text(
                      _months[start.month - 1],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: TUColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_time(start)} – ${_time(game.endTime)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: TUColors.ink,
                            ),
                          ),
                        ),
                        if (requestStatus == JoinRequestStatus.pending)
                          const _Pill(
                            label: 'Requested',
                            bg: TUColors.busyBg,
                            fg: TUColors.ink2,
                          )
                        else if (requestStatus == JoinRequestStatus.approved)
                          const _Pill(
                            label: 'Approved · pay',
                            bg: TUColors.brandSoft,
                            fg: TUColors.brand700,
                          )
                        else ...[
                          if (isHost) ...[
                            const _Pill(
                              label: 'Host',
                              bg: TUColors.brandSoft,
                              fg: TUColors.brand700,
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (game.status == GameStatus.private)
                            const _Pill(
                              label: 'Private',
                              bg: TUColors.surface2,
                              fg: TUColors.ink2,
                            )
                          else if (full)
                            const _Pill(
                              label: 'Full',
                              bg: TUColors.busyBg,
                              fg: TUColors.ink3,
                            )
                          else
                            const _Pill(
                              label: 'Open',
                              bg: TUColors.lime,
                              fg: TUColors.brand900,
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        SportGlyph(
                          sport: game.sport,
                          size: 16,
                          color: game.sport.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          game.sport.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: TUColors.ink2,
                          ),
                        ),
                        const Text(
                          '  ·  ',
                          style: TextStyle(color: TUColors.ink3),
                        ),
                        Flexible(
                          child: Text(
                            full
                                ? '${game.spotsFilled}/${game.capacity} players'
                                : '${game.spotsFilled}/${game.capacity} · needs ${game.spotsOpen} more',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: TUColors.brand700,
                            ),
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TUColors.rPill),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
