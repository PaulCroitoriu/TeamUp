import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/theme/sport_tile.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/business_model.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/features/games/models/game_model.dart';
import 'package:teamup/features/games/screens/game_panel.dart' show GamePanel;
import 'package:teamup/features/messaging/data/messaging_service.dart';
import 'package:teamup/features/messaging/models/message_model.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';
import 'package:teamup/features/notifications/widgets/notification_toast_listener.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/shared/widgets/adaptive_sheet.dart';
import 'package:teamup/shared/widgets/page_header.dart';

final _log = Logger();

const _chatBreakpoint = 760.0;

class _BookingContext {
  const _BookingContext({required this.venue, required this.pitch, required this.booker, required this.business});

  final VenueModel venue;
  final PitchModel pitch;
  final UserModel booker;
  final BusinessModel business;
}

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _bookingService = BookingService();
  final _venueService = VenueService();
  final _authService = AuthService();

  Future<_BookingContext>? _contextFuture;
  String? _loadedForBookingId;

  @override
  void initState() {
    super.initState();
    ActiveBookingScope.enter(widget.bookingId);
  }

  @override
  void didUpdateWidget(covariant BookingDetailScreen old) {
    super.didUpdateWidget(old);
    if (old.bookingId != widget.bookingId) {
      ActiveBookingScope.exit(old.bookingId);
      ActiveBookingScope.enter(widget.bookingId);
    }
  }

  @override
  void dispose() {
    ActiveBookingScope.exit(widget.bookingId);
    super.dispose();
  }

  Future<_BookingContext> _loadContext(BookingModel booking) async {
    final results = await Future.wait([
      _venueService.getVenue(booking.venueId),
      _venueService.getPitch(booking.venueId, booking.pitchId),
      _authService.getUserProfile(booking.bookerId),
      _authService.getBusiness(booking.businessId),
    ]);
    return _BookingContext(
      venue: results[0] as VenueModel,
      pitch: results[1] as PitchModel,
      booker: results[2] as UserModel,
      business: results[3] as BusinessModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BookingModel>(
      stream: _bookingService.streamBooking(widget.bookingId),
      builder: (context, snap) {
        if (snap.hasError) {
          return _LoadingScaffold(message: snap.error.toString());
        }
        if (!snap.hasData) return const _LoadingScaffold();

        final booking = snap.data!;
        if (_loadedForBookingId != booking.id) {
          _loadedForBookingId = booking.id;
          _contextFuture = _loadContext(booking);
        }

        return FutureBuilder<_BookingContext>(
          future: _contextFuture,
          builder: (context, ctxSnap) {
            if (ctxSnap.hasError) return _LoadingScaffold(message: ctxSnap.error.toString());
            if (!ctxSnap.hasData) return const _LoadingScaffold();
            return _BookingView(booking: booking, ctx: ctxSnap.data!);
          },
        );
      },
    );
  }
}

// ─── Loading / error scaffold ───────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TUColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: HeaderBackButton(),
              ),
            ),
            Expanded(
              child: Center(
                child: message == null
                    ? const CircularProgressIndicator()
                    : Padding(padding: const EdgeInsets.all(24), child: Text(message!, textAlign: TextAlign.center)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── The booking view (one column + chat drawer/sheet) ──────

class _BookingView extends StatefulWidget {
  const _BookingView({required this.booking, required this.ctx});
  final BookingModel booking;
  final _BookingContext ctx;

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _bookingService = BookingService();
  final _notificationService = NotificationService();

  BookingModel get booking => widget.booking;
  _BookingContext get ctx => widget.ctx;

  @override
  void initState() {
    super.initState();
    // Opening the game clears its "Action" flag (unread join-request alerts) so
    // it only flags once per request — handling them here returns it to normal.
    _markGameActionsRead();
  }

  Future<void> _markGameActionsRead() async {
    final gid = booking.gameId;
    final uid = _uid;
    if (gid == null || uid == null) return;
    try {
      final list = await _notificationService.streamForUser(uid).first;
      for (final n in list) {
        if (!n.read && n.gameId == gid && n.type == NotificationType.joinRequest) {
          await _notificationService.markRead(n.id);
        }
      }
    } catch (_) {}
  }

  // read (not select): auth doesn't change while on this page, and this getter
  // is also used from tap/async handlers where select() isn't allowed.
  String? get _uid => context.read<AuthBloc>().state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null);
  bool get _isOwner => _uid == ctx.business.ownerUid;
  bool get _isBooker => _uid == booking.bookerId;

  bool get _canConfirm => _isOwner && booking.status == BookingStatus.pending;
  bool get _canCancel => (_isOwner || _isBooker) && booking.status != BookingStatus.cancelled;
  bool get _canOpenToPlayers =>
      _isBooker && booking.gameId == null && booking.status != BookingStatus.cancelled && booking.startTime.isAfter(DateTime.now());

  Future<void> _markMessagesRead() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final list = await _notificationService.streamForUser(uid).first;
      for (final n in list) {
        if (!n.read && n.type == NotificationType.newMessage && n.bookingId == booking.id) {
          await _notificationService.markRead(n.id);
        }
      }
    } catch (_) {}
  }

  void _openChat() {
    final uid = _uid;
    if (uid == null) return;
    _markMessagesRead();
    if (MediaQuery.sizeOf(context).width >= _chatBreakpoint) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: TUColors.bg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(TUColors.rLg))),
        builder: (_) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.85,
            child: _ChatView(booking: booking, ctx: ctx, currentUserId: uid, isSheet: true),
          ),
        ),
      );
    }
  }

  Future<void> _confirm() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _bookingService.confirmBooking(booking.id);
      await _notificationService.create(
        NotificationModel(
          id: '',
          recipientId: booking.bookerId,
          type: NotificationType.bookingConfirmed,
          title: 'Booking confirmed',
          body: '${ctx.pitch.name} • ${_fmtDate(booking.startTime)} ${_fmtTime(booking.startTime)}',
          bookingId: booking.id,
          createdAt: DateTime.now(),
        ),
      );
      messenger.showSnackBar(const SnackBar(content: Text('Booking confirmed')));
    } catch (e, st) {
      _log.e('Confirm booking failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _cancel() async {
    final uid = _uid;
    if (uid == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('This releases the slot and notifies the other party.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Keep')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Cancel booking', style: TextStyle(color: Color(0xFFB23B2E)))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _bookingService.cancelBooking(booking.id);
      final recipient = uid == ctx.business.ownerUid ? booking.bookerId : ctx.business.ownerUid;
      await _notificationService.create(
        NotificationModel(
          id: '',
          recipientId: recipient,
          type: NotificationType.bookingCancelled,
          title: 'Booking cancelled',
          body: '${ctx.pitch.name} • ${_fmtDate(booking.startTime)} ${_fmtTime(booking.startTime)}',
          bookingId: booking.id,
          createdAt: DateTime.now(),
        ),
      );
      messenger.showSnackBar(const SnackBar(content: Text('Booking cancelled')));
    } catch (e, st) {
      _log.e('Cancel booking failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _openToPlayers() async {
    final messenger = ScaffoldMessenger.of(context);
    final cfg = await showAdaptiveSheet<({int capacity, int spotsFilled, bool approval})>(
      context,
      builder: (_) => _OpenToPlayersSheet(pitch: ctx.pitch, booking: booking),
    );
    if (cfg == null) return;
    try {
      await GameService().openBookingAsGame(
        booking: booking,
        sport: ctx.pitch.sport,
        capacity: cfg.capacity,
        spotsFilled: cfg.spotsFilled,
        requiresApproval: cfg.approval,
      );
      messenger.showSnackBar(const SnackBar(content: Text('Open to players — others can join now')));
    } catch (e, st) {
      _log.e('Open booking as game failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Could not open: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _chatBreakpoint;
    final uid = _uid;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TUColors.bg,
      endDrawer: wide && uid != null
          ? Drawer(
              width: 420,
              backgroundColor: TUColors.bg,
              shape: const RoundedRectangleBorder(),
              child: SafeArea(
                child: _ChatView(
                  booking: booking,
                  ctx: ctx,
                  currentUserId: uid,
                  onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
                ),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TUColors.pageMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  leading: const HeaderBackButton(),
                  title: ctx.pitch.name,
                  subtitle: '${ctx.pitch.sport.label} · ${ctx.venue.name}, ${ctx.venue.city}',
                  trailing: _MessageButton(userId: uid, bookingId: booking.id, onTap: uid == null ? null : _openChat),
                ),
                Expanded(child: SelectionArea(child: _details(wide))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _details(bool wide) {
    // "Admin" = the people who manage this booking (the organiser/booker or the
    // venue owner). Plain visitors don't see internal info (timeline, repeat,
    // booking number).
    final isAdmin = _isOwner || _isBooker;
    final isGame = booking.gameId != null;

    // ── Left column: about the slot ──
    final left = <Widget>[
      SportTile(
        sport: ctx.pitch.sport,
        height: 168,
        borderRadius: BorderRadius.circular(TUColors.rLg),
        glyphSize: 62,
        overlay: [
          Positioned(
            top: 12,
            left: 12,
            child: TilePill(
              icon: ctx.pitch.indoor ? Icons.roofing_rounded : Icons.wb_sunny_outlined,
              label: ctx.pitch.indoor ? 'Indoor' : 'Outdoor',
            ),
          ),
          Positioned(top: 12, right: 12, child: _StatusTag(status: booking.status)),
        ],
      ),
      if (isAdmin) ...[
        const SizedBox(height: 12),
        Text(
          'Booking #${booking.id.substring(0, 6).toUpperCase()}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TUColors.ink3, letterSpacing: 0.5),
        ),
      ],
      const SizedBox(height: 14),
      _factsCard(isAdmin: isAdmin, isGame: isGame),
      const SizedBox(height: 12),
      _organiserCard(),
      if (booking.notes != null && booking.notes!.isNotEmpty) ...[
        const SizedBox(height: 12),
        _SectionCard(
          children: [
            const _CardLabel('Notes'),
            const SizedBox(height: 6),
            Text(booking.notes!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: TUColors.ink2, height: 1.5)),
          ],
        ),
      ],
    ];

    // ── Right column: the activity (team / actions / admin timeline) ──
    final right = <Widget>[
      if (isGame) GamePanel(gameId: booking.gameId!),
      if (_canOpenToPlayers) ...[
        FilledButton.icon(
          onPressed: _openToPlayers,
          icon: const Icon(Icons.group_add_rounded, size: 19),
          label: const Text('Open to players'),
          style: FilledButton.styleFrom(
            backgroundColor: TUColors.brand,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Missing a regular this week? Open just this booking so others can join or ask to join.',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3),
        ),
      ],
      if (isAdmin) ...[
        if (isGame || _canOpenToPlayers) const SizedBox(height: 12),
        _BookingTimeline(booking: booking),
      ],
      if (_canConfirm || _canCancel) ...[
        const SizedBox(height: 16),
        _actionsRow(),
      ],
    ];

    if (wide) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: left)),
            const SizedBox(width: 20),
            Expanded(flex: 6, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: right)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        ...left,
        if (right.isNotEmpty) const SizedBox(height: 12),
        ...right,
      ],
    );
  }

  Widget _factsCard({required bool isAdmin, required bool isGame}) {
    final priceAmount = (booking.pricePaid / 100).round();
    return _SectionCard(
      children: [
        _IconRow(
          icon: Icons.calendar_today_rounded,
          title: _fmtFullDate(booking.startTime),
          subtitle: '${_fmtTime(booking.startTime)} – ${_fmtTime(booking.endTime)}',
        ),
        const Divider(height: 24, color: TUColors.line),
        _IconRow(
          icon: Icons.payments_outlined,
          title: '$priceAmount ${booking.currency}',
          subtitle: isGame ? 'Court total · split per player' : 'Full court',
          accent: true,
        ),
        const Divider(height: 24, color: TUColors.line),
        _IconRow(
          icon: Icons.group_outlined,
          title: 'Up to ${ctx.pitch.maxPlayers} players',
          subtitle: [
            ctx.pitch.indoor ? 'Indoor' : 'Outdoor',
            if (ctx.pitch.surface != null) ctx.pitch.surface!,
            if (ctx.pitch.isIlluminated) 'Floodlit',
          ].join(' · '),
        ),
        // Recurring is an organiser/owner detail, not shown to visitors.
        if (isAdmin && booking.recurring) ...[
          const Divider(height: 24, color: TUColors.line),
          const _IconRow(icon: Icons.event_repeat_rounded, title: 'Repeats weekly', subtitle: 'Same day & time'),
        ],
      ],
    );
  }

  Widget _organiserCard() {
    return _SectionCard(
      children: [
        Row(
          children: [
            _InitialsAvatar(user: ctx.booker),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${ctx.booker.firstName} ${ctx.booker.lastName}'.trim(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: TUColors.ink)),
                  const SizedBox(height: 2),
                  Text(_isOwner ? ctx.booker.email : 'Organiser', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
                ],
              ),
            ),
            const _Pill(label: 'Organiser', bg: TUColors.brandSoft, fg: TUColors.brand700),
          ],
        ),
      ],
    );
  }

  Widget _actionsRow() {
    return Row(
      children: [
        if (_canConfirm)
          Expanded(
            child: FilledButton.icon(
              onPressed: _confirm,
              icon: const Icon(Icons.check_rounded, size: 19),
              label: const Text('Confirm'),
              style: FilledButton.styleFrom(
                backgroundColor: TUColors.brand,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        if (_canConfirm && _canCancel) const SizedBox(width: 10),
        if (_canCancel)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _cancel,
              icon: const Icon(Icons.close_rounded, size: 19),
              label: Text(booking.gameId != null && _isBooker ? 'Cancel game' : 'Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB23B2E),
                side: const BorderSide(color: Color(0xFFE7C3BC)),
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Message button (header trailing) ───────────────────────

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.onTap, required this.userId, required this.bookingId});
  final VoidCallback? onTap;
  final String? userId;
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 22, color: TUColors.ink2),
          ),
        ),
      ),
    );

    final uid = userId;
    if (uid == null) return button;

    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService().streamForUser(uid),
      builder: (context, snap) {
        final unread = (snap.data ?? const <NotificationModel>[])
            .any((n) => !n.read && n.type == NotificationType.newMessage && n.bookingId == bookingId);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            button,
            if (unread)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5484D),
                    shape: BoxShape.circle,
                    border: Border.all(color: TUColors.bg, width: 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Hero status tag ────────────────────────────────────────

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg) = switch (status) {
      BookingStatus.pending => ('Pending', const Color(0xFF9A6B00)),
      BookingStatus.confirmed => ('Confirmed', TUColors.brand700),
      BookingStatus.cancelled => ('Cancelled', const Color(0xFFB23B2E)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .94), borderRadius: BorderRadius.circular(TUColors.rPill)),
      child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

// ─── Timeline ───────────────────────────────────────────────

class _BookingTimeline extends StatelessWidget {
  const _BookingTimeline({required this.booking});
  final BookingModel booking;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String _stamp(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final entries = <(IconData, String, DateTime, Color)>[
      (Icons.add_circle_outline, 'Created', booking.createdAt, TUColors.ink3),
      if (booking.confirmedAt != null && booking.status != BookingStatus.cancelled)
        (Icons.check_circle_outline, 'Confirmed', booking.confirmedAt!, TUColors.brand700),
      if (booking.paidAt != null) (Icons.payments_outlined, 'Paid', booking.paidAt!, TUColors.brand700),
      if (booking.status == BookingStatus.cancelled)
        (Icons.cancel_outlined, 'Cancelled', booking.cancelledAt ?? booking.createdAt, const Color(0xFFB23B2E)),
    ];

    return _SectionCard(
      children: [
        const _CardLabel('Timeline'),
        const SizedBox(height: 10),
        for (var i = 0; i < entries.length; i++) ...[
          Row(
            children: [
              Icon(entries[i].$1, size: 16, color: entries[i].$4),
              const SizedBox(width: 10),
              Expanded(child: Text(entries[i].$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: TUColors.ink))),
              Text(_stamp(entries[i].$3), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: TUColors.ink3)),
            ],
          ),
          if (i < entries.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ─── Shared bits ────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TUColors.surface,
        borderRadius: BorderRadius.circular(TUColors.rLg),
        border: Border.all(color: TUColors.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: TUColors.ink3));
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({required this.icon, required this.title, required this.subtitle, this.accent = false});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: TUColors.brandTint, borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, size: 18, color: TUColors.brand700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: accent ? TUColors.brand700 : TUColors.ink)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: TUColors.brandSoft,
      child: Text(user.initials, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.brand700)),
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

// ─── Chat (drawer on desktop, bottom sheet on mobile) ───────

class _ChatView extends StatefulWidget {
  const _ChatView({required this.booking, required this.ctx, required this.currentUserId, this.isSheet = false, this.onClose});
  final BookingModel booking;
  final _BookingContext ctx;
  final String currentUserId;
  final bool isSheet;
  final VoidCallback? onClose;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _messaging = MessagingService();
  final _notifications = NotificationService();
  final _authService = AuthService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  List<String> _gamePlayers = const [];
  StreamSubscription<GameModel>? _gameSub;

  // senderId → short name, for labelling incoming messages.
  Map<String, String> _names = {};

  Future<void> _loadNames() async {
    try {
      final users = await _authService.getUsersByIds(_participants);
      if (mounted) setState(() => _names = {for (final u in users) u.uid: u.shortName});
    } catch (_) {}
  }

  bool get _isGame => widget.booking.gameId != null;
  bool get _isOwner => widget.currentUserId == widget.ctx.business.ownerUid;

  String get _title => _isGame ? '${widget.ctx.pitch.sport.label} team' : (_isOwner ? '${widget.ctx.booker.firstName} ${widget.ctx.booker.lastName}'.trim() : widget.ctx.business.name);
  String get _subtitle => _isGame ? 'Everyone in this game' : 'About this booking';

  List<String> get _participants => _isGame
      ? {..._gamePlayers, widget.booking.bookerId, widget.ctx.business.ownerUid}.toList()
      : [widget.booking.bookerId, widget.ctx.business.ownerUid];

  @override
  void initState() {
    super.initState();
    _loadNames();
    final gameId = widget.booking.gameId;
    if (gameId != null) {
      _gameSub = GameService().streamGame(gameId).listen(
        (g) {
          if (!mounted) return;
          final changed = g.playerIds.length != _gamePlayers.length;
          setState(() => _gamePlayers = g.playerIds);
          if (changed) _loadNames();
        },
        onError: (Object e, StackTrace st) => _log.w('Chat roster stream failed', error: e, stackTrace: st),
      );
    }
  }

  @override
  void dispose() {
    _gameSub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await _messaging.sendBookingMessage(
        bookingId: widget.booking.id,
        senderId: widget.currentUserId,
        participantIds: _participants,
        text: text,
        // Identify the thread by the match: "Football · 21 Jun · 18:00".
        title: '${widget.ctx.pitch.sport.label} · ${_fmtDate(widget.booking.startTime)} · ${_fmtTime(widget.booking.startTime)}',
      );
      _controller.clear();
      // Notify everyone in the conversation except the sender (the other party
      // in a 1-on-1 booking chat; the whole team in a game).
      final recipients = _participants.where((id) => id != widget.currentUserId).toSet();
      final preview = text.length > 80 ? '${text.substring(0, 80)}…' : text;
      for (final r in recipients) {
        try {
          await _notifications.create(
            NotificationModel(
              id: '',
              recipientId: r,
              type: NotificationType.newMessage,
              title: 'New message · $_title',
              body: preview,
              bookingId: widget.booking.id,
              conversationId: result.conversationId,
              createdAt: DateTime.now(),
            ),
          );
        } catch (e, st) {
          _log.w('newMessage notification failed for $r', error: e, stackTrace: st);
        }
      }
      _scrollSoon();
    } catch (e, st) {
      _log.e('Send message failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final convId = _messaging.bookingConversationId(widget.booking.id);
    return Column(
      children: [
        if (widget.isSheet)
          Center(child: Container(margin: const EdgeInsets.only(top: 10, bottom: 4), width: 42, height: 5, decoration: BoxDecoration(color: TUColors.line2, borderRadius: BorderRadius.circular(TUColors.rPill)))),
        // ── Header ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: TUColors.line))),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: TUColors.brandTint, shape: BoxShape.circle),
                child: Icon(_isGame ? Icons.groups_rounded : Icons.chat_bubble_outline_rounded, size: 19, color: TUColors.brand700),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
                    Text(_subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: TUColors.ink3)),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onClose ?? () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded, size: 20, color: TUColors.ink2),
              ),
            ],
          ),
        ),
        // ── Messages ──
        Expanded(
          child: StreamBuilder<List<MessageModel>>(
            stream: _messaging.streamMessages(conversationId: convId, userId: widget.currentUserId),
            builder: (context, snap) {
              if (snap.hasError) {
                return Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('Messages failed to load:\n${snap.error}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFB23B2E), fontSize: 12))));
              }
              final messages = snap.data ?? const <MessageModel>[];
              if (messages.isEmpty) return _ChatEmpty(name: _title);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  final pos = _scrollController.position;
                  if (pos.maxScrollExtent - pos.pixels < 200) _scrollController.jumpTo(pos.maxScrollExtent);
                }
              });
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];
                  final prev = i > 0 ? messages[i - 1] : null;
                  final mine = m.senderId == widget.currentUserId;
                  final newSender = prev == null || prev.senderId != m.senderId;
                  final gap = prev == null || m.sentAt.difference(prev.sentAt).inMinutes >= 5 || newSender;
                  return Padding(
                    padding: EdgeInsets.only(top: gap ? 8 : 2),
                    child: _Bubble(
                      message: m,
                      isMine: mine,
                      // Name shown above the first bubble of an incoming run.
                      senderName: (!mine && newSender) ? (_names[m.senderId] ?? 'Player') : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
        // ── Input ──
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: TUColors.line))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14, color: TUColors.ink),
                    decoration: InputDecoration(
                      hintText: 'Write a message…',
                      hintStyle: const TextStyle(fontSize: 14, color: TUColors.ink3),
                      filled: true,
                      fillColor: TUColors.surface2,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(TUColors.rPill), borderSide: BorderSide.none),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _sending ? TUColors.line2 : TUColors.brand,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _sending ? null : _send,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _sending
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatEmpty extends StatelessWidget {
  const _ChatEmpty({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 44, color: TUColors.ink3.withValues(alpha: .5)),
            const SizedBox(height: 14),
            const Text('No messages yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
            const SizedBox(height: 6),
            Text('Say hi to $name.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: TUColors.ink3)),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMine, this.senderName});
  final MessageModel message;
  final bool isMine;
  final String? senderName;

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? TUColors.brand : TUColors.surface;
    final fg = isMine ? Colors.white : TUColors.ink;
    return Column(
      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (senderName != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 3),
            child: Text(senderName!, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: TUColors.brand700)),
          ),
        Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isMine ? 14 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 14),
              ),
              border: isMine ? null : Border.all(color: TUColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.text, style: TextStyle(fontSize: 14, color: fg)),
                const SizedBox(height: 2),
                Text(_fmtTime(message.sentAt), style: TextStyle(fontSize: 10, color: isMine ? Colors.white.withValues(alpha: .8) : TUColors.ink3)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Open-to-players sheet ──────────────────────────────────

class _OpenToPlayersSheet extends StatefulWidget {
  const _OpenToPlayersSheet({required this.pitch, required this.booking});
  final PitchModel pitch;
  final BookingModel booking;

  @override
  State<_OpenToPlayersSheet> createState() => _OpenToPlayersSheetState();
}

class _OpenToPlayersSheetState extends State<_OpenToPlayersSheet> {
  late int _capacity = widget.pitch.maxPlayers;
  late int _filled = (widget.pitch.maxPlayers - 1).clamp(1, widget.pitch.maxPlayers);
  bool _approval = true;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobileWidth(context);
    final cur = widget.booking.currency;
    final total = (widget.booking.pricePaid / 100).round();
    final perPlayer = _capacity <= 0 ? total : (total / _capacity).round();
    final needs = (_capacity - _filled).clamp(0, _capacity);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mobile)
            Center(child: Container(margin: const EdgeInsets.only(top: 10, bottom: 2), width: 42, height: 5, decoration: BoxDecoration(color: TUColors.line2, borderRadius: BorderRadius.circular(TUColors.rPill)))),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 18, 24, 4),
            child: Text('Open to players', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: TUColors.ink)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text('Just this booking — others can join or ask to join.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: TUColors.ink3)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(color: TUColors.surface, borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
                  child: Column(
                    children: [
                      _SheetStepperRow(
                        title: 'Team size',
                        sub: 'Total spots on the court',
                        value: _capacity,
                        onMinus: _capacity > _filled && _capacity > 2 ? () => setState(() => _capacity--) : null,
                        onPlus: _capacity < widget.pitch.maxPlayers ? () => setState(() => _capacity++) : null,
                      ),
                      const Divider(height: 1, thickness: 1, color: TUColors.line),
                      _SheetStepperRow(
                        title: 'Already coming',
                        sub: 'You and the regulars who can make it',
                        value: _filled,
                        onMinus: _filled > 1 ? () => setState(() => _filled--) : null,
                        onPlus: _filled < _capacity ? () => setState(() => _filled++) : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    needs > 0 ? 'Opens $needs spot${needs == 1 ? '' : 's'} · $perPlayer $cur per player' : 'No open spots — raise the team size',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: TUColors.ink3),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
                  decoration: BoxDecoration(color: TUColors.surface, borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Approve who joins', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
                            const SizedBox(height: 2),
                            Text(_approval ? 'Players ask — you approve each one' : 'Anyone can join instantly', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
                          ],
                        ),
                      ),
                      Switch.adaptive(value: _approval, onChanged: (v) => setState(() => _approval = v)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: TUColors.line))),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
            child: FilledButton(
              onPressed: needs > 0 ? () => Navigator.of(context).pop((capacity: _capacity, spotsFilled: _filled, approval: _approval)) : null,
              style: FilledButton.styleFrom(
                backgroundColor: TUColors.brand,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              child: const Text('Open to players'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetStepperRow extends StatelessWidget {
  const _SheetStepperRow({required this.title, required this.sub, required this.value, required this.onMinus, required this.onPlus});
  final String title;
  final String sub;
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
              ],
            ),
          ),
          _SheetStepBtn(icon: Icons.remove_rounded, onTap: onMinus),
          SizedBox(width: 40, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: TUColors.ink))),
          _SheetStepBtn(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _SheetStepBtn extends StatelessWidget {
  const _SheetStepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? TUColors.brandSoft : TUColors.surface2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 20, color: enabled ? TUColors.brand700 : TUColors.ink3)),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────

String _fmtTime(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _fmtDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]}';
}

String _fmtFullDate(DateTime d) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
}
