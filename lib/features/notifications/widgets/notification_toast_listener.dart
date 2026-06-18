import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';

final _log = Logger();

/// Tracks which booking the user is currently viewing so the toast listener
/// can suppress message toasts for that booking — they're already in the
/// conversation, no need to interrupt them. Booking detail screens set this
/// on init and clear on dispose.
class ActiveBookingScope {
  ActiveBookingScope._();

  static final ValueNotifier<String?> activeId = ValueNotifier<String?>(null);

  static void enter(String bookingId) => activeId.value = bookingId;
  static void exit(String bookingId) {
    if (activeId.value == bookingId) activeId.value = null;
  }
}

/// Subscribes to the current user's notifications stream while mounted and
/// shows an in-app SnackBar for any notification created after the listener
/// started. Used in place of system push for the foreground case so the
/// user gets the message without an OS-level notification.
class NotificationToastListener extends StatefulWidget {
  const NotificationToastListener({super.key, required this.userId, required this.child});

  final String userId;
  final Widget child;

  @override
  State<NotificationToastListener> createState() => _NotificationToastListenerState();
}

class _NotificationToastListenerState extends State<NotificationToastListener> {
  late final DateTime _sessionStart;
  final Set<String> _shown = <String>{};
  StreamSubscription<List<NotificationModel>>? _sub;
  OverlayEntry? _entry;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    _sub = NotificationService().streamForUser(widget.userId).listen(_onUpdate, onError: _onError);
  }

  @override
  void didUpdateWidget(covariant NotificationToastListener old) {
    super.didUpdateWidget(old);
    if (old.userId != widget.userId) {
      _sub?.cancel();
      _shown.clear();
      _sub = NotificationService().streamForUser(widget.userId).listen(_onUpdate, onError: _onError);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _dismiss();
    super.dispose();
  }

  void _onUpdate(List<NotificationModel> items) {
    for (final n in items) {
      if (_shown.contains(n.id)) continue;
      if (!n.createdAt.isAfter(_sessionStart)) {
        // Stale notification from before this session — record so we don't
        // re-show on stream re-emit, but don't toast.
        _shown.add(n.id);
        continue;
      }
      _shown.add(n.id);
      if (!mounted) return;
      // Suppress message toasts for the booking the user is already viewing.
      if (n.type == NotificationType.newMessage && n.bookingId != null && ActiveBookingScope.activeId.value == n.bookingId) {
        continue;
      }
      _show(n);
    }
  }

  void _onError(Object e, StackTrace st) {
    _log.e('Notification toast listener stream error', error: e, stackTrace: st);
  }

  IconData _iconFor(NotificationType type) => switch (type) {
    NotificationType.newBooking => Icons.event_available_outlined,
    NotificationType.bookingConfirmed => Icons.check_circle_outline_rounded,
    NotificationType.bookingCancelled => Icons.cancel_outlined,
    NotificationType.newMessage => Icons.chat_bubble_outline_rounded,
    NotificationType.joinRequest => Icons.person_add_alt_1_outlined,
    NotificationType.joinApproved => Icons.how_to_reg_outlined,
    NotificationType.joinDeclined => Icons.person_off_outlined,
  };

  void _dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _entry?.remove();
    _entry = null;
  }

  /// Resolve where a notification points (always the unified booking page) and
  /// open it; game notifications carry a gameId we map to its booking.
  Future<void> _open(NotificationModel n) async {
    _dismiss();
    final nav = Navigator.of(context);
    try {
      await NotificationService().markRead(n.id);
    } catch (_) {}
    String? bookingId = n.bookingId;
    if (bookingId == null && n.gameId != null) {
      try {
        bookingId = (await GameService().streamGame(n.gameId!).first).bookingId;
      } catch (_) {}
    }
    if (bookingId == null || !mounted) return;
    nav.push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: bookingId!)));
  }

  void _show(NotificationModel n) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    _dismiss();
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final topInset = MediaQuery.paddingOf(context).top;

    _entry = OverlayEntry(
      builder: (_) => Positioned(
        top: topInset + 10,
        right: wide ? 16 : 12,
        left: wide ? null : 12,
        child: _ToastCard(
          icon: _iconFor(n.type),
          title: n.title,
          body: n.body,
          wide: wide,
          onTap: () => _open(n),
          onClose: _dismiss,
        ),
      ),
    );
    overlay.insert(_entry!);
    _dismissTimer = Timer(const Duration(seconds: 5), _dismiss);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Compact toast card — top-right on desktop, full-width banner on mobile.
class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.wide,
    required this.onTap,
    required this.onClose,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool wide;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: TUColors.surface,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: .18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rMd),
            border: Border.all(color: TUColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: TUColors.brandTint, shape: BoxShape.circle),
                child: Icon(icon, size: 17, color: TUColors.brand700),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: TUColors.ink, fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 1),
                    Text(body, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: TUColors.ink2, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              InkWell(
                onTap: onClose,
                customBorder: const CircleBorder(),
                child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close_rounded, size: 16, color: TUColors.ink3)),
              ),
            ],
          ),
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, (1 - t) * -12), child: child),
      ),
      child: wide ? SizedBox(width: 340, child: card) : card,
    );
  }
}
