import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/game_status.dart';
import 'package:teamup/core/enums/join_request_status.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/theme/sport_tile.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/bookings/screens/book_config_sheet.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/features/games/models/game_model.dart';
import 'package:teamup/features/games/models/join_request_model.dart';
import 'package:teamup/shared/widgets/adaptive_sheet.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

final _log = Logger();

/// How many weeks ahead a "repeats weekly" booking materialises, mirroring the
/// owner-side manual booking. A future job rolls the series forward.
const _kRecurringWeeks = 52;

const _weekdayKeys = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

enum _SlotStatus { available, booked, open }

class _Slot {
  const _Slot({
    required this.start,
    required this.end,
    required this.status,
    this.game,
  });
  final DateTime start;
  final DateTime end;
  final _SlotStatus status;
  final GameModel? game;

  bool get available => status == _SlotStatus.available;
  bool get isOpen => status == _SlotStatus.open;
}

class PitchBookingScreen extends StatefulWidget {
  const PitchBookingScreen({
    super.key,
    required this.venue,
    required this.pitch,
    this.onBack,
  });

  final VenueModel venue;
  final PitchModel pitch;

  /// When set, the screen is shown inline (not pushed as a route) — used on
  /// desktop so it doesn't cover the sidebar. The app bar back button and the
  /// post-booking navigation use this instead of popping a route.
  final VoidCallback? onBack;

  @override
  State<PitchBookingScreen> createState() => _PitchBookingScreenState();
}

class _PitchBookingScreenState extends State<PitchBookingScreen> {
  final _bookingService = BookingService();
  final _gameService = GameService();
  final _authService = AuthService();
  final _notificationService = NotificationService();

  late DateTime _selectedDay = _stripTime(DateTime.now());
  _Slot? _selectedSlot;
  bool _booking = false;
  String? _confirmedBookingId;

  // The current user's join requests, keyed by gameId — drives the Requested/
  // Accepted slot state.
  Map<String, JoinRequestStatus> _myRequests = {};
  StreamSubscription<List<JoinRequestModel>>? _myRequestsSub;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthBloc>().state.maybeMap(
      authenticated: (s) => s.user.uid,
      orElse: () => null,
    );
    if (uid != null) {
      _myRequestsSub = _gameService.streamMyRequests(uid).listen(
        (reqs) {
          if (!mounted) return;
          setState(
            () => _myRequests = {for (final r in reqs) r.gameId: r.status},
          );
        },
        onError: (Object e, StackTrace st) =>
            _log.w('My requests stream failed', error: e, stackTrace: st),
      );
    }
  }

  @override
  void dispose() {
    _myRequestsSub?.cancel();
    super.dispose();
  }

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  List<_Slot> _slotsFor(
    DateTime day,
    List<BookingModel> bookings,
    List<GameModel> games,
  ) {
    final dayKey = _weekdayKeys[day.weekday - 1];
    final hours = widget.venue.openingHours[dayKey];
    if (hours == null || hours.closed) return const [];

    final openH = int.tryParse(hours.open.split(':').first) ?? 9;
    final closeH = int.tryParse(hours.close.split(':').first) ?? 22;
    if (closeH <= openH) return const [];

    final now = DateTime.now();
    final result = <_Slot>[];
    for (var h = openH; h < closeH; h++) {
      final start = DateTime(day.year, day.month, day.day, h);
      final end = DateTime(day.year, day.month, day.day, h + 1);
      final isPast = start.isBefore(now);

      // An open game at this hour takes precedence: it's joinable while it has
      // room, otherwise the court is taken (shown as booked).
      GameModel? game;
      for (final g in games) {
        if (g.startTime.isAtSameMomentAs(start)) {
          game = g;
          break;
        }
      }
      if (game != null &&
          !isPast &&
          game.status == GameStatus.open &&
          game.spotsOpen > 0) {
        result.add(
          _Slot(start: start, end: end, status: _SlotStatus.open, game: game),
        );
        continue;
      }

      final isBooked =
          game != null ||
          bookings.any(
            (b) =>
                b.status != BookingStatus.cancelled &&
                b.startTime.isBefore(end) &&
                b.endTime.isAfter(start),
          );
      result.add(
        _Slot(
          start: start,
          end: end,
          status: (isPast || isBooked)
              ? _SlotStatus.booked
              : _SlotStatus.available,
        ),
      );
    }
    return result;
  }

  /// Opens the booking-configuration sheet (game type · players · payment) on
  /// Continue/Join. On success the sheet shows a receipt and pops `true`, after
  /// which we route to the booking detail.
  Future<void> _openConfig(_Slot slot, String userId) async {
    final joinGame = slot.isOpen ? slot.game : null;

    // Approved request → pay to confirm (no booking-detail navigation).
    if (joinGame != null &&
        _myRequests[joinGame.id] == JoinRequestStatus.approved) {
      await showAdaptiveSheet<bool>(
        context,
        builder: (_) => BookConfigSheet(
          venue: widget.venue,
          pitch: widget.pitch,
          slotStart: slot.start,
          slotEnd: slot.end,
          day: _selectedDay,
          joinGame: joinGame,
          payOnly: true,
          onSubmit: (_) => _confirmJoin(joinGame, userId),
        ),
      );
      return;
    }

    final completed = await showAdaptiveSheet<bool>(
      context,
      builder: (_) => BookConfigSheet(
        venue: widget.venue,
        pitch: widget.pitch,
        slotStart: slot.start,
        slotEnd: slot.end,
        day: _selectedDay,
        joinGame: joinGame,
        onSubmit: joinGame != null
            ? (joinGame.requiresApproval
                  ? (_) => _requestJoin(joinGame, userId)
                  : (_) => _joinGame(joinGame, userId))
            : (cfg) => _createBooking(slot, userId, cfg),
      ),
    );
    if (completed == true &&
        joinGame == null &&
        _confirmedBookingId != null &&
        mounted) {
      final route = MaterialPageRoute(
        builder: (_) => BookingDetailScreen(bookingId: _confirmedBookingId!),
      );
      if (widget.onBack != null) {
        // Inline (desktop): close the inline booking and open the confirmation
        // as a route instead of replacing the host route.
        widget.onBack!();
        Navigator.of(context).push(route);
      } else {
        Navigator.of(context).pushReplacement(route);
      }
    }
  }

  /// Creates the booking from a configured [cfg]. Returns the new booking id,
  /// or null on failure (a snackbar is shown). Stores the id for post-flow nav.
  Future<String?> _createBooking(
    _Slot slot,
    String userId,
    BookConfig cfg,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _booking = true);
    try {
      final draft = BookingModel(
        id: '',
        pitchId: widget.pitch.id,
        venueId: widget.venue.id,
        businessId: widget.venue.businessId,
        bookerId: userId,
        startTime: slot.start,
        endTime: slot.end,
        pricePaid: widget.pitch.pricePerHour,
        currency: widget.pitch.currency,
        paymentMethod: cfg.method,
        createdAt: DateTime.now(),
      );

      // Open game → write the game + its reserving booking atomically;
      // recurring private → materialise a weekly series; one-off private → a
      // single booking.
      final BookingModel booking;
      if (cfg.open) {
        final (_, b) = await _gameService.createOpenGame(
          booking: draft,
          game: GameModel(
            id: '',
            pitchId: widget.pitch.id,
            venueId: widget.venue.id,
            businessId: widget.venue.businessId,
            sport: widget.pitch.sport,
            hostId: userId,
            startTime: slot.start,
            endTime: slot.end,
            capacity: cfg.gameSize,
            spotsFilled: cfg.confirmed,
            requiresApproval: cfg.requiresApproval,
            playerIds: [userId],
            pricePerHour: widget.pitch.pricePerHour,
            currency: widget.pitch.currency,
            createdAt: DateTime.now(),
          ),
        );
        booking = b;
      } else if (cfg.recurring) {
        final recurrenceId = 'rec_${DateTime.now().microsecondsSinceEpoch}_$userId';
        final series = [
          for (var w = 0; w < _kRecurringWeeks; w++)
            draft.copyWith(
              startTime: slot.start.add(Duration(days: 7 * w)),
              endTime: slot.end.add(Duration(days: 7 * w)),
              recurring: true,
            ),
        ];
        final created = await _bookingService.createRecurringBookings(series, recurrenceId: recurrenceId);
        booking = created.first;
      } else {
        booking = await _bookingService.createBooking(draft);
      }

      // Notify the business owner.
      try {
        final business = await _authService.getBusiness(
          widget.venue.businessId,
        );
        await _notificationService.create(
          NotificationModel(
            id: '',
            recipientId: business.ownerUid,
            type: NotificationType.newBooking,
            title: 'New booking request',
            body:
                '${widget.pitch.name} • ${_formatDate(slot.start)} ${_formatTime(slot.start)}',
            bookingId: booking.id,
            createdAt: DateTime.now(),
          ),
        );
      } catch (e, st) {
        // Don't fail the booking if the notification write fails.
        _log.w(
          'Failed to write newBooking notification: ${_describeError(e)}',
          stackTrace: st,
        );
      }

      if (!mounted) return null;
      setState(() => _confirmedBookingId = booking.id);
      return booking.id;
    } on BookingConflictException catch (e, st) {
      _log.w('Booking conflict on create', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return null;
    } catch (e, st) {
      final detail = _describeError(e);
      _log.e('Booking creation failed: $detail', stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(detail)));
      return null;
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  /// Joins an existing open game. Returns the game id on success, or null on
  /// failure (a snackbar is shown).
  Future<String?> _joinGame(GameModel game, String userId) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _booking = true);
    try {
      await _gameService.joinGame(game.id, userId);
      return game.id;
    } on GameJoinException catch (e, st) {
      _log.w('Join failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return null;
    } catch (e, st) {
      final detail = _describeError(e);
      _log.e('Join failed: $detail', stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(detail)));
      return null;
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  /// Sends a join request for an approval-required game. Returns the game id on
  /// success (so the sheet shows the "Request sent" state), or null on failure.
  Future<String?> _requestJoin(GameModel game, String userId) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _booking = true);
    try {
      await _gameService.requestToJoin(gameId: game.id, userId: userId);
      return game.id;
    } on GameJoinException catch (e, st) {
      _log.w('Join request failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return null;
    } catch (e, st) {
      final detail = _describeError(e);
      _log.e('Join request failed: $detail', stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(detail)));
      return null;
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  /// Confirm the spot after approval (no in-app payment — the joiner settles
  /// their share with the organiser).
  Future<String?> _confirmJoin(GameModel game, String userId) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _booking = true);
    try {
      await _gameService.confirmJoin(gameId: game.id, userId: userId);
      return game.id;
    } on GameJoinException catch (e, st) {
      _log.w('Confirm join failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return null;
    } catch (e, st) {
      final detail = _describeError(e);
      _log.e('Confirm join failed: $detail', stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(detail)));
      return null;
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  /// Web async errors come through as JS NativeErrors wrapped in a Dart
  /// "converted Future" envelope. The interesting fields live on the inner
  /// JS object (`name`, `code`, `message`). Read them via dynamic dispatch
  /// (which JS interop translates to property reads) so we get a useful
  /// string instead of the opaque wrapper text.
  String _describeError(Object e) {
    final dynamic d = e;
    dynamic inner;
    try {
      inner = d.error;
    } catch (_) {}
    inner ??= d;

    String? safe(dynamic Function() get) {
      try {
        final v = get();
        return v?.toString();
      } catch (_) {
        return null;
      }
    }

    final name = safe(() => inner.name);
    final code = safe(() => inner.code);
    final message = safe(() => inner.message);
    final parts = <String>[
      if (name != null) 'name=$name',
      if (code != null) 'code=$code',
      if (message != null) 'message=$message',
    ];
    return parts.isEmpty ? e.toString() : parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    final priceAmount = (widget.pitch.pricePerHour / 100).toStringAsFixed(0);
    final sport = widget.pitch.sport;

    final userId = context.select<AuthBloc, String?>(
      (b) => b.state.maybeMap(
        authenticated: (s) => s.user.uid,
        orElse: () => null,
      ),
    );

    // Match the design's gutters: 34px on desktop, 18px on mobile.
    final gutter = MediaQuery.sizeOf(context).width >= 600 ? 34.0 : 18.0;

    return Scaffold(
      backgroundColor: TUColors.surface,
      appBar: AppBar(
        backgroundColor: TUColors.surface,
        foregroundColor: TUColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(
          widget.pitch.name,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: TUColors.ink,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Pitch summary header (sport tile · club · rate) ──
          Padding(
            padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sport.color,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: SportGlyph(
                      sport: sport,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sport.label} · ${widget.venue.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TUColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: TUColors.ink3,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${widget.venue.city} · ${widget.pitch.indoor ? 'Indoor' : 'Outdoor'}',
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
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$priceAmount ${widget.pitch.currency}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: TUColors.brand700,
                      ),
                    ),
                    const Text(
                      'per hour',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: TUColors.ink3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Date strip ──
          _DateStrip(
            gutter: gutter,
            selected: _selectedDay,
            onSelected: (d) => setState(() {
              _selectedDay = d;
              _selectedSlot = null;
            }),
          ),

          // ── Slot grid ──
          Expanded(
            child: StreamBuilder<List<GameModel>>(
              stream: _gameService.streamPitchGamesForDay(
                widget.pitch.id,
                _selectedDay,
              ),
              builder: (context, gameSnap) {
                final games = gameSnap.data ?? const <GameModel>[];
                return StreamBuilder<List<BookingModel>>(
                  stream: _bookingService.streamPitchBookingsForDay(
                    widget.pitch.id,
                    _selectedDay,
                  ),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final slots = _slotsFor(
                      _selectedDay,
                      snap.data ?? const <BookingModel>[],
                      games,
                    );
                    if (slots.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Closed on this day',
                            style: TextStyle(color: TUColors.ink2),
                          ),
                        ),
                      );
                    }
                    final openCount = slots
                        .where((s) => s.available || s.isOpen)
                        .length;
                    return ListView(
                      padding: EdgeInsets.fromLTRB(gutter, 22, gutter, 24),
                      children: [
                        // slothead: "Wed 17 · N open" + legend (legend hidden
                        // on mobile, matching the design).
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_weekdayLabel(_selectedDay)} ${_selectedDay.day} · $openCount open',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: TUColors.ink,
                                ),
                              ),
                            ),
                            if (gutter >= 30) ...const [
                              SizedBox(width: 12),
                              _LegendDot(
                                color: TUColors.brandSoft,
                                label: 'Available',
                              ),
                              SizedBox(width: 14),
                              _LegendDot(color: TUColors.lime, label: 'Open'),
                              SizedBox(width: 14),
                              _LegendDot(
                                color: TUColors.busyBg,
                                label: 'Booked',
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, c) {
                            // 3 columns on desktop (design repeat(3)), 2 otherwise.
                            final cols = c.maxWidth >= 720 ? 3 : 2;
                            final gap = cols == 3 ? 14.0 : 12.0;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: cols,
                                    mainAxisExtent: 112,
                                    mainAxisSpacing: gap,
                                    crossAxisSpacing: gap,
                                  ),
                              itemCount: slots.length,
                              itemBuilder: (_, i) {
                                final sl = slots[i];
                                final reqStatus = sl.game != null
                                    ? _myRequests[sl.game!.id]
                                    : null;
                                final canAct =
                                    sl.isOpen &&
                                    sl.game != null &&
                                    userId != null &&
                                    !sl.game!.playerIds.contains(userId) &&
                                    reqStatus != JoinRequestStatus.pending;
                                final selectable =
                                    !_booking && (sl.available || canAct);
                                return _SlotCard(
                                  slot: sl,
                                  price:
                                      '$priceAmount ${widget.pitch.currency}',
                                  selected: _selectedSlot?.start == sl.start,
                                  requestStatus: reqStatus,
                                  onTap: selectable
                                      ? () => setState(() => _selectedSlot = sl)
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ── Sticky continue bar / sign-in prompt ──
          if (userId == null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 16),
              color: const Color(0xFFFBEEDD),
              child: const Text(
                'Sign in to book a slot',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TUColors.brand900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (_selectedSlot != null)
            _ContinueBar(
              gutter: gutter,
              day: _selectedDay,
              start: _selectedSlot!.start,
              price: '$priceAmount ${widget.pitch.currency}',
              isJoin: _selectedSlot!.isOpen,
              requestNeeded:
                  _selectedSlot!.isOpen &&
                  (_selectedSlot!.game?.requiresApproval ?? false),
              payMode:
                  _selectedSlot!.isOpen &&
                  _myRequests[_selectedSlot!.game?.id] ==
                      JoinRequestStatus.approved,
              busy: _booking,
              onContinue: () => _openConfig(_selectedSlot!, userId),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: TUColors.ink2,
          ),
        ),
      ],
    );
  }
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({
    required this.gutter,
    required this.day,
    required this.start,
    required this.price,
    required this.busy,
    required this.onContinue,
    this.isJoin = false,
    this.requestNeeded = false,
    this.payMode = false,
  });

  final double gutter;
  final DateTime day;
  final DateTime start;
  final String price;
  final bool busy;
  final bool isJoin;
  final bool requestNeeded;
  final bool payMode;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final end = start.add(const Duration(hours: 1));
    return Container(
      decoration: const BoxDecoration(
        color: TUColors.surface,
        border: Border(top: BorderSide(color: TUColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(
        gutter,
        14,
        gutter,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatTime(start)}–${_formatTime(end)} · ${_weekdayLabel(day)} ${day.day}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TUColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payMode
                      ? 'Approved — pay to confirm your spot'
                      : isJoin
                      ? (requestNeeded
                            ? 'Request to join · host approves'
                            : 'Joining an open game')
                      : 'Full court booking',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: TUColors.ink2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          FilledButton(
            onPressed: busy ? null : onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: TUColors.brand,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TUColors.rMd),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        payMode
                            ? 'Confirm spot'
                            : isJoin
                            ? (requestNeeded ? 'Request to join' : 'Join game')
                            : 'Continue · $price',
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.gutter,
    required this.selected,
    required this.onSelected,
  });

  final double gutter;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  static const _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: TUColors.surface2,
        border: Border(
          top: BorderSide(color: TUColors.line),
          bottom: BorderSide(color: TUColors.line),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 12),
        itemCount: 14,
        itemBuilder: (context, i) {
          final day = start.add(Duration(days: i));
          final isSelected = day == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: Material(
              color: isSelected ? TUColors.brand : TUColors.surface2,
              borderRadius: BorderRadius.circular(TUColors.rMd),
              child: InkWell(
                onTap: () => onSelected(day),
                borderRadius: BorderRadius.circular(TUColors.rMd),
                child: Container(
                  width: 60,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _weekdayLabels[day.weekday - 1].toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: isSelected ? Colors.white : TUColors.ink3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : TUColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A compact, informative booking slot: time range, status tag, and price.
class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.price,
    required this.selected,
    required this.onTap,
    this.requestStatus,
  });

  final _Slot slot;
  final String price;
  final bool selected;
  final VoidCallback? onTap;
  final JoinRequestStatus? requestStatus;

  @override
  Widget build(BuildContext context) {
    final open = slot.isOpen;
    final active = onTap != null || selected;

    final Color bg;
    final Color border;
    if (selected) {
      bg = TUColors.brandTint;
      border = TUColors.brand;
    } else if (open) {
      bg = TUColors.brandTint;
      border = TUColors.brandSoft;
    } else if (slot.available) {
      bg = TUColors.surface;
      border = TUColors.line;
    } else {
      bg = TUColors.surface2;
      border = TUColors.line;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rMd),
            border: Border.all(color: border, width: selected ? 1.8 : 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTime(slot.start),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: active || open
                                ? TUColors.ink
                                : TUColors.ink3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${_formatTime(slot.start)}–${_formatTime(slot.end)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: TUColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (open)
                    _OpenTag(
                      approval: slot.game?.requiresApproval ?? false,
                      requestStatus: requestStatus,
                    )
                  else if (slot.available)
                    const _StatusTag(
                      label: 'Available',
                      bg: TUColors.brandSoft,
                      fg: TUColors.brand700,
                    )
                  else
                    const _StatusTag(
                      label: 'Booked',
                      bg: TUColors.busyBg,
                      fg: TUColors.ink3,
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: (open && slot.game != null)
                        ? _JoinedDots(
                            filled: slot.game!.spotsFilled,
                            total: slot.game!.capacity,
                          )
                        : Text.rich(
                            TextSpan(
                              text: price.split(' ').first,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: active ? TUColors.ink : TUColors.ink3,
                              ),
                              children: [
                                TextSpan(
                                  text: ' ${price.split(' ').last}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: TUColors.ink3,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: TUColors.brand,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JoinedDots extends StatelessWidget {
  const _JoinedDots({required this.filled, required this.total});
  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    final show = total.clamp(0, 4);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
          width: show == 0 ? 0 : (16 + (show - 1) * 11),
          child: Stack(
            children: [
              for (var i = 0; i < show; i++)
                Positioned(
                  left: i * 11,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: i < filled ? TUColors.brand : TUColors.line2,
                      shape: BoxShape.circle,
                      border: Border.all(color: TUColors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            '$filled/$total',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: TUColors.brand700,
            ),
          ),
        ),
      ],
    );
  }
}

class _OpenTag extends StatelessWidget {
  const _OpenTag({required this.approval, this.requestStatus});

  final bool approval;
  final JoinRequestStatus? requestStatus;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    Color bg;
    Color fg;
    switch (requestStatus) {
      case JoinRequestStatus.pending:
        icon = Icons.hourglass_top_rounded;
        label = 'Requested';
        bg = TUColors.busyBg;
        fg = TUColors.ink2;
      case JoinRequestStatus.approved:
        icon = Icons.verified_rounded;
        label = 'Accepted';
        bg = TUColors.brandSoft;
        fg = TUColors.brand700;
      default:
        icon = approval ? Icons.lock_outline_rounded : Icons.bolt_rounded;
        label = approval ? 'Request' : 'Open';
        bg = TUColors.lime;
        fg = TUColors.brand900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TUColors.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TUColors.rPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

const _weekdayLabelsTop = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
String _weekdayLabel(DateTime d) => _weekdayLabelsTop[d.weekday - 1];

String _formatDate(DateTime d) {
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

String _formatTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
