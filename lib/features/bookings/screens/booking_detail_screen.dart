import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/business_model.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/messaging/data/messaging_service.dart';
import 'package:teamup/features/messaging/models/message_model.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

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
      appBar: AppBar(title: const Text('Booking')),
      body: StreamBuilder<BookingModel>(
        stream: _bookingService.streamBooking(widget.bookingId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }
          final booking = snap.data!;

          // Load related entities once per bookingId.
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
              return _DetailBody(
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
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
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

  String _formatDate(DateTime d) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _confirm(BuildContext context) async {
    await bookingService.confirmBooking(booking.id);
    await notificationService.create(
      NotificationModel(
        id: '',
        recipientId: booking.bookerId,
        type: NotificationType.bookingConfirmed,
        title: 'Booking confirmed',
        body: '${ctx.pitch.name} • ${_formatDate(booking.startTime)} ${_formatTime(booking.startTime)}',
        bookingId: booking.id,
        createdAt: DateTime.now(),
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking confirmed')));
    }
  }

  Future<void> _cancel(BuildContext context, String currentUserId) async {
    await bookingService.cancelBooking(booking.id);
    // Notify the *other* party.
    final isOwnerCancelling = currentUserId == ctx.business.ownerUid;
    final recipient = isOwnerCancelling ? booking.bookerId : ctx.business.ownerUid;
    await notificationService.create(
      NotificationModel(
        id: '',
        recipientId: recipient,
        type: NotificationType.bookingCancelled,
        title: 'Booking cancelled',
        body: '${ctx.pitch.name} • ${_formatDate(booking.startTime)} ${_formatTime(booking.startTime)}',
        bookingId: booking.id,
        createdAt: DateTime.now(),
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceAmount = (booking.pricePaid / 100).toStringAsFixed(0);

    final currentUserId = context.select<AuthBloc, String?>((b) => b.state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null));
    final isBusinessOwner = currentUserId == ctx.business.ownerUid;
    final isBooker = currentUserId == booking.bookerId;
    final canConfirm = isBusinessOwner && booking.status == BookingStatus.pending;
    final canCancel = (isBusinessOwner || isBooker) && booking.status != BookingStatus.cancelled;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Pitch + venue ──
              Text(ctx.pitch.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${ctx.venue.name} • ${ctx.venue.city}', style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(170))),
              const SizedBox(height: 20),

              // ── Status + price ──
              Row(
                children: [
                  _StatusChip(status: booking.status),
                  const Spacer(),
                  Text(
                    '$priceAmount ${booking.currency}',
                    style: theme.textTheme.titleMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── When ──
              _InfoTile(
                icon: Icons.calendar_today_outlined,
                title: _formatDate(booking.startTime),
                subtitle: '${_formatTime(booking.startTime)} – ${_formatTime(booking.endTime)}',
              ),
              const SizedBox(height: 12),

              // ── Booker ──
              _InfoTile(icon: Icons.person_outline_rounded, title: '${ctx.booker.firstName} ${ctx.booker.lastName}', subtitle: ctx.booker.email),

              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoTile(icon: Icons.notes_rounded, title: 'Notes', subtitle: booking.notes!),
              ],

              if (canConfirm || canCancel) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (canConfirm)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Confirm'),
                          onPressed: () => _confirm(context),
                        ),
                      ),
                    if (canConfirm && canCancel) const SizedBox(width: 12),
                    if (canCancel)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(foregroundColor: colors.error),
                          onPressed: currentUserId == null ? null : () => _cancel(context, currentUserId),
                        ),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 32),
              Divider(color: colors.onSurface.withAlpha(20)),
              const SizedBox(height: 16),
              Text('Messages', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _ChatPanel(
                bookingId: booking.id,
                participantIds: [booking.bookerId, ctx.business.ownerUid],
                currentUserId: currentUserId,
                bookerName: ctx.booker.firstName,
                businessName: ctx.business.name,
                messagingService: messagingService,
                notificationService: notificationService,
                otherPartyId: currentUserId == ctx.business.ownerUid ? booking.bookerId : ctx.business.ownerUid,
                titleForBody: '${ctx.pitch.name} • ${_formatDate(booking.startTime)}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (status) {
      BookingStatus.confirmed => const Color(0xFF34A853),
      BookingStatus.pending => colors.secondary,
      BookingStatus.cancelled => colors.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.onSurface.withAlpha(140)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(160))),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({
    required this.bookingId,
    required this.participantIds,
    required this.currentUserId,
    required this.bookerName,
    required this.businessName,
    required this.messagingService,
    required this.notificationService,
    required this.otherPartyId,
    required this.titleForBody,
  });

  final String bookingId;
  final List<String> participantIds;
  final String? currentUserId;
  final String bookerName;
  final String businessName;
  final MessagingService messagingService;
  final NotificationService notificationService;
  final String otherPartyId;
  final String titleForBody;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final uid = widget.currentUserId;
    if (text.isEmpty || uid == null || _sending) return;

    setState(() => _sending = true);
    try {
      final result = await widget.messagingService.sendBookingMessage(
        bookingId: widget.bookingId,
        senderId: uid,
        participantIds: widget.participantIds,
        text: text,
      );
      _controller.clear();
      // Notify the other party of the new message.
      final senderName = uid == widget.otherPartyId ? widget.bookerName : widget.businessName;
      await widget.notificationService.create(
        NotificationModel(
          id: '',
          recipientId: widget.otherPartyId,
          type: NotificationType.newMessage,
          title: 'New message from $senderName',
          body: text.length > 80 ? '${text.substring(0, 80)}…' : text,
          bookingId: widget.bookingId,
          conversationId: result.conversationId,
          createdAt: DateTime.now(),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final convId = widget.messagingService.bookingConversationId(widget.bookingId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.onSurface.withAlpha(20)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: StreamBuilder<List<MessageModel>>(
              stream: widget.messagingService.streamMessages(convId),
              builder: (context, snap) {
                final messages = snap.data ?? const <MessageModel>[];
                if (messages.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text('No messages yet — say hi!', style: TextStyle(color: colors.onSurface.withAlpha(140))),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _MessageBubble(message: messages[i], isMine: messages[i].senderId == widget.currentUserId),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Write a message…',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});
  final MessageModel message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.7),
        decoration: BoxDecoration(
          color: isMine ? colors.primary.withAlpha(28) : colors.onSurface.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.text, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
