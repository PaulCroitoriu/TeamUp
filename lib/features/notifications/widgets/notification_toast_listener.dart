import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';

final _log = Logger();

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
  };

  void _show(NotificationModel n) {
    final colors = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        backgroundColor: colors.surface,
        elevation: 4,
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: colors.primary.withAlpha(24), shape: BoxShape.circle),
              child: Icon(_iconFor(n.type), size: 18, color: colors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: TextStyle(color: colors.onSurface, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    n.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.onSurface.withAlpha(180), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: n.bookingId == null
            ? null
            : SnackBarAction(
                label: 'Open',
                textColor: colors.primary,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: n.bookingId!)));
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
