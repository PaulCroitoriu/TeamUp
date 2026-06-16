import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/business_model.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/features/games/screens/game_detail_screen.dart';
import 'package:teamup/features/messaging/data/messaging_service.dart';
import 'package:teamup/features/messaging/models/message_model.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';
import 'package:teamup/features/notifications/widgets/notification_toast_listener.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/shared/widgets/adaptive_sheet.dart';

final _log = Logger();

const _splitBreakpoint = 760.0;

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
  final _notificationService = NotificationService();
  final _messagingService = MessagingService();

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
    return Scaffold(
      appBar: AppBar(title: const Text('Booking'), elevation: 0, scrolledUnderElevation: 0),
      body: SelectionArea(
        child: StreamBuilder<BookingModel>(
          stream: _bookingService.streamBooking(widget.bookingId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text(snap.error.toString()));
            }
            final booking = snap.data!;

            if (_loadedForBookingId != booking.id) {
              _loadedForBookingId = booking.id;
              _contextFuture = _loadContext(booking);
            }

            return FutureBuilder<_BookingContext>(
              future: _contextFuture,
              builder: (context, ctxSnap) {
                if (!ctxSnap.hasData) {
                  if (ctxSnap.hasError) {
                    return Center(child: Text(ctxSnap.error.toString()));
                  }
                  return const Center(child: CircularProgressIndicator());
                }
                return _Layout(
                  booking: booking,
                  ctx: ctxSnap.data!,
                  bookingService: _bookingService,
                  notificationService: _notificationService,
                  messagingService: _messagingService,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Responsive layout ──────────────────────────────────────

class _Layout extends StatelessWidget {
  const _Layout({
    required this.booking,
    required this.ctx,
    required this.bookingService,
    required this.notificationService,
    required this.messagingService,
  });

  final BookingModel booking;
  final _BookingContext ctx;
  final BookingService bookingService;
  final NotificationService notificationService;
  final MessagingService messagingService;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final currentUserId = context.select<AuthBloc, String?>((b) => b.state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null));
    final isBusinessOwner = currentUserId == ctx.business.ownerUid;

    final details = _DetailsPanel(
      booking: booking,
      ctx: ctx,
      currentUserId: currentUserId,
      isBusinessOwner: isBusinessOwner,
      bookingService: bookingService,
      notificationService: notificationService,
    );
    final chat = _ChatPanel(
      booking: booking,
      ctx: ctx,
      currentUserId: currentUserId,
      isBusinessOwner: isBusinessOwner,
      messagingService: messagingService,
      notificationService: notificationService,
    );

    if (width >= _splitBreakpoint) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: details),
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: colors.onSurface.withAlpha(20)),
          Expanded(flex: 4, child: chat),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).appBarTheme.backgroundColor ?? colors.surface,
            child: TabBar(
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Messages'),
              ],
              labelColor: colors.primary,
              unselectedLabelColor: colors.onSurface.withAlpha(150),
              indicatorColor: colors.primary,
            ),
          ),
          Expanded(child: TabBarView(children: [details, chat])),
        ],
      ),
    );
  }
}

// ─── Details panel ──────────────────────────────────────────

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({
    required this.booking,
    required this.ctx,
    required this.currentUserId,
    required this.isBusinessOwner,
    required this.bookingService,
    required this.notificationService,
  });

  final BookingModel booking;
  final _BookingContext ctx;
  final String? currentUserId;
  final bool isBusinessOwner;
  final BookingService bookingService;
  final NotificationService notificationService;

  bool get _isBooker => currentUserId == booking.bookerId;
  bool get _canConfirm => isBusinessOwner && booking.status == BookingStatus.pending;
  bool get _canCancel => (isBusinessOwner || _isBooker) && booking.status != BookingStatus.cancelled;

  // The booker can open an upcoming private booking to players (e.g. a single
  // occurrence of a recurring booking when a regular drops out this week).
  bool get _canOpenToPlayers =>
      _isBooker &&
      booking.gameId == null &&
      booking.status != BookingStatus.cancelled &&
      booking.startTime.isAfter(DateTime.now());

  Future<void> _openToPlayers(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final cfg = await showAdaptiveSheet<({int capacity, int spotsFilled, bool approval})>(
      context,
      builder: (_) => _OpenToPlayersSheet(pitch: ctx.pitch, booking: booking),
    );
    if (cfg == null) return;
    try {
      final game = await GameService().openBookingAsGame(
        booking: booking,
        sport: ctx.pitch.sport,
        capacity: cfg.capacity,
        spotsFilled: cfg.spotsFilled,
        requiresApproval: cfg.approval,
      );
      messenger.showSnackBar(const SnackBar(content: Text('Open to players — others can join now')));
      nav.push(MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: game.id)));
    } catch (e, st) {
      _log.e('Open booking as game failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Could not open: $e')));
    }
  }

  Future<void> _confirm(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await bookingService.confirmBooking(booking.id);
      await notificationService.create(
        NotificationModel(
          id: '',
          recipientId: booking.bookerId,
          type: NotificationType.bookingConfirmed,
          title: 'Booking confirmed',
          body:
              '${ctx.pitch.name} • ${_fmtDate(booking.startTime)} '
              '${_fmtTime(booking.startTime)}',
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

  Future<void> _cancel(BuildContext context) async {
    final uid = currentUserId;
    if (uid == null) return;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('This will release the slot and notify the other party.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Keep')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await bookingService.cancelBooking(booking.id);
      final isOwnerCancelling = uid == ctx.business.ownerUid;
      final recipient = isOwnerCancelling ? booking.bookerId : ctx.business.ownerUid;
      await notificationService.create(
        NotificationModel(
          id: '',
          recipientId: recipient,
          type: NotificationType.bookingCancelled,
          title: 'Booking cancelled',
          body:
              '${ctx.pitch.name} • ${_fmtDate(booking.startTime)} '
              '${_fmtTime(booking.startTime)}',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceAmount = (booking.pricePaid / 100).toStringAsFixed(0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _Hero(pitch: ctx.pitch),
        const SizedBox(height: 16),
        _StatusBanner(status: booking.status),
        const SizedBox(height: 20),
        Text(ctx.pitch.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.1)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 14, color: colors.onSurface.withAlpha(140)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${ctx.venue.name} • ${ctx.venue.city}',
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(170)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Booking #${booking.id.substring(0, 6).toUpperCase()}',
          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(110), letterSpacing: 0.5),
        ),
        const SizedBox(height: 24),

        // ── When + Price row ──
        _SectionCard(
          children: [
            _IconRow(
              icon: Icons.calendar_today_rounded,
              title: _fmtFullDate(booking.startTime),
              subtitle: '${_fmtTime(booking.startTime)} – ${_fmtTime(booking.endTime)}',
            ),
            const Divider(height: 24),
            _IconRow(
              icon: Icons.payments_outlined,
              title: '$priceAmount ${booking.currency}',
              subtitle: 'Paid by booker',
              titleColor: colors.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Booker ──
        _SectionCard(
          children: [
            Row(
              children: [
                _Avatar(user: ctx.booker),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${ctx.booker.firstName} ${ctx.booker.lastName}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(ctx.booker.email, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(140))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: colors.secondary.withAlpha(20), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    'Booker',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.secondary, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),

        if (booking.notes != null && booking.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionCard(
            children: [
              Text(
                'Notes',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.onSurface.withAlpha(170), letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(booking.notes!, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(180), height: 1.5)),
            ],
          ),
        ],

        const SizedBox(height: 12),
        _BookingTimeline(booking: booking),

        // ── Open to players / view the open game ──
        if (_isBooker && booking.gameId != null) ...[
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: booking.gameId!)),
            ),
            icon: const Icon(Icons.groups_rounded),
            label: const Text('View open game'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary.withAlpha(90)),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ] else if (_canOpenToPlayers) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openToPlayers(context),
            icon: const Icon(Icons.group_add_rounded),
            label: const Text('Open to players'),
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 8),
          Text(
            'Missing a regular this week? Open just this booking so others can join or ask to join.',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(140)),
          ),
        ],

        if (_canConfirm || _canCancel) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              if (_canConfirm)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirm(context),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Confirm'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              if (_canConfirm && _canCancel) const SizedBox(width: 10),
              if (_canCancel)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _cancel(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(color: colors.error.withAlpha(80)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Hero image ─────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.pitch});
  final PitchModel pitch;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cover = pitch.imageUrls.isNotEmpty ? pitch.imageUrls.first : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: cover != null ? Image.network(cover, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _heroFallback(colors)) : _heroFallback(colors),
      ),
    );
  }

  Widget _heroFallback(ColorScheme colors) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary.withAlpha(40), colors.secondary.withAlpha(40)],
        ),
      ),
      child: Center(child: Image.asset(pitch.sport.iconPath, width: 56, height: 56, color: colors.onSurface.withAlpha(120))),
    );
  }
}

// ─── Status banner ──────────────────────────────────────────

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final entries = <(IconData, String, DateTime?, Color)>[
      (Icons.add_circle_outline, 'Created', booking.createdAt, colors.onSurface.withAlpha(160)),
      if (booking.confirmedAt != null) (Icons.check_circle_outline, 'Confirmed', booking.confirmedAt, const Color(0xFF1E7E3F)),
      if (booking.paidAt != null) (Icons.payments_outlined, 'Paid', booking.paidAt, colors.primary),
      if (booking.cancelledAt != null) (Icons.cancel_outlined, 'Cancelled', booking.cancelledAt, colors.error),
    ];

    return _SectionCard(
      children: [
        Text(
          'Timeline',
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.onSurface.withAlpha(170), letterSpacing: 0.5),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < entries.length; i++) ...[
          Row(
            children: [
              Icon(entries[i].$1, size: 16, color: entries[i].$4),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entries[i].$2,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.onSurface),
                ),
              ),
              Text(_stamp(entries[i].$3!), style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(150))),
            ],
          ),
          if (i < entries.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (color, icon, label) = switch (status) {
      BookingStatus.pending => (colors.secondary, Icons.hourglass_top_rounded, 'Awaiting payment'),
      BookingStatus.confirmed => (const Color(0xFF34A853), Icons.check_circle_rounded, 'Confirmed'),
      BookingStatus.cancelled => (colors.error, Icons.cancel_rounded, 'Cancelled'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Section card ───────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.onSurface.withAlpha(20)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({required this.icon, required this.title, required this.subtitle, this.titleColor});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: colors.primary.withAlpha(20), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: titleColor),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(140))),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Avatar ─────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});
  final UserModel user;
  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initials = (user.firstName.isNotEmpty ? user.firstName[0] : '') + (user.lastName.isNotEmpty ? user.lastName[0] : '');

    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(user.photoUrl!, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initials(initials, colors)),
      );
    }
    return _initials(initials, colors);
  }

  Widget _initials(String text, ColorScheme colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: colors.primary.withAlpha(28), shape: BoxShape.circle),
      child: Center(
        child: Text(
          text.toUpperCase(),
          style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeight.w700, color: colors.primary),
        ),
      ),
    );
  }
}

// ─── Chat panel ─────────────────────────────────────────────

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({
    required this.booking,
    required this.ctx,
    required this.currentUserId,
    required this.isBusinessOwner,
    required this.messagingService,
    required this.notificationService,
  });

  final BookingModel booking;
  final _BookingContext ctx;
  final String? currentUserId;
  final bool isBusinessOwner;
  final MessagingService messagingService;
  final NotificationService notificationService;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  String get _otherPartyId => widget.isBusinessOwner ? widget.booking.bookerId : widget.ctx.business.ownerUid;

  String get _otherPartyName => widget.isBusinessOwner ? widget.ctx.booker.firstName : widget.ctx.business.name;

  List<String> get _participants => [widget.booking.bookerId, widget.ctx.business.ownerUid];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final uid = widget.currentUserId;
    if (text.isEmpty || uid == null || _sending) return;

    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await widget.messagingService.sendBookingMessage(
        bookingId: widget.booking.id,
        senderId: uid,
        participantIds: _participants,
        text: text,
      );
      _controller.clear();

      // Notify the other side.
      try {
        final senderName = widget.isBusinessOwner ? widget.ctx.business.name : '${widget.ctx.booker.firstName} ${widget.ctx.booker.lastName}';
        await widget.notificationService.create(
          NotificationModel(
            id: '',
            recipientId: _otherPartyId,
            type: NotificationType.newMessage,
            title: 'New message from $senderName',
            body: text.length > 80 ? '${text.substring(0, 80)}…' : text,
            bookingId: widget.booking.id,
            conversationId: result.conversationId,
            createdAt: DateTime.now(),
          ),
        );
      } catch (e, st) {
        _log.w('Failed to write newMessage notification', error: e, stackTrace: st);
      }

      _scrollToBottomSoon();
    } catch (e, st) {
      _log.e('Send message failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final convId = widget.messagingService.bookingConversationId(widget.booking.id);
    final uid = widget.currentUserId;

    return Column(
      children: [
        // ── Header ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(bottom: BorderSide(color: colors.onSurface.withAlpha(20))),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: colors.primary.withAlpha(20), shape: BoxShape.circle),
                child: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: colors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_otherPartyName, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
                    Text('About this booking', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(140))),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Messages list ──
        Expanded(
          child: uid == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Sign in to send messages.', style: TextStyle(color: colors.onSurface.withAlpha(140))),
                  ),
                )
              : StreamBuilder<List<MessageModel>>(
                  stream: widget.messagingService.streamMessages(conversationId: convId, userId: uid),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Messages failed to load:\n${snap.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.error, fontSize: 12),
                          ),
                        ),
                      );
                    }
                    final messages = snap.data ?? const <MessageModel>[];
                    if (messages.isEmpty) {
                      return _ChatEmpty(otherName: _otherPartyName);
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        final pos = _scrollController.position;
                        if (pos.maxScrollExtent - pos.pixels < 200) {
                          _scrollController.jumpTo(pos.maxScrollExtent);
                        }
                      }
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final m = messages[i];
                        final prev = i > 0 ? messages[i - 1] : null;
                        final showGap = prev == null || m.sentAt.difference(prev.sentAt).inMinutes >= 5 || prev.senderId != m.senderId;
                        return Padding(
                          padding: EdgeInsets.only(top: showGap ? 8 : 2),
                          child: _Bubble(message: m, isMine: m.senderId == uid),
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
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.onSurface.withAlpha(20))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    enabled: uid != null,
                    decoration: InputDecoration(
                      hintText: 'Write a message…',
                      filled: true,
                      fillColor: colors.onSurface.withAlpha(10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _sending || uid == null ? colors.onSurface.withAlpha(20) : colors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _sending || uid == null ? null : _send,
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
  const _ChatEmpty({required this.otherName});
  final String otherName;

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
            Icon(Icons.chat_bubble_outline_rounded, size: 44, color: colors.onSurface.withAlpha(60)),
            const SizedBox(height: 14),
            Text('No messages yet', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Say hi to $otherName about the booking.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(140)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMine});
  final MessageModel message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bg = isMine ? colors.primary : colors.onSurface.withAlpha(12);
    final fg = isMine ? Colors.white : colors.onSurface;
    final timeColor = isMine ? Colors.white.withAlpha(190) : colors.onSurface.withAlpha(140);

    return Align(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.text, style: theme.textTheme.bodyMedium?.copyWith(color: fg)),
            const SizedBox(height: 2),
            Text(_fmtTime(message.sentAt), style: TextStyle(fontSize: 10, color: timeColor)),
          ],
        ),
      ),
    );
  }
}

// ─── Open-to-players sheet ──────────────────────────────────

/// Lets the booker turn a private booking into an open game for this occurrence:
/// pick the team size, how many are already coming, and whether to vet joiners.
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
            Container(margin: const EdgeInsets.only(top: 10, bottom: 2), width: 42, height: 5, decoration: BoxDecoration(color: TUColors.line2, borderRadius: BorderRadius.circular(TUColors.rPill))),
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
              onPressed: needs > 0
                  ? () => Navigator.of(context).pop((capacity: _capacity, spotsFilled: _filled, approval: _approval))
                  : null,
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

String _fmtTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _fmtDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]}';
}

String _fmtFullDate(DateTime d) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
}
