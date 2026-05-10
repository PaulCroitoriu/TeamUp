import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final service = NotificationService();

    final userId = context.select<AuthBloc, String?>((b) => b.state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null));

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Sign in to see notifications')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [TextButton(onPressed: () => service.markAllRead(userId), child: const Text('Mark all read'))],
      ),
      body: SelectionArea(
        child: StreamBuilder<List<NotificationModel>>(
          stream: service.streamForUser(userId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 48, color: colors.onSurface.withAlpha(60)),
                      const SizedBox(height: 16),
                      Text('No notifications yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: colors.onSurface.withAlpha(15)),
              itemBuilder: (_, i) => _NotificationTile(notification: items[i], service: service),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.service});
  final NotificationModel notification;
  final NotificationService service;

  IconData get _icon => switch (notification.type) {
    NotificationType.newBooking => Icons.event_available_outlined,
    NotificationType.bookingConfirmed => Icons.check_circle_outline_rounded,
    NotificationType.bookingCancelled => Icons.cancel_outlined,
    NotificationType.newMessage => Icons.chat_bubble_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unread = !notification.read;

    return Material(
      color: unread ? colors.primary.withAlpha(8) : Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (unread) {
            await service.markRead(notification.id);
          }
          if (!context.mounted) return;
          if (notification.bookingId != null) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: notification.bookingId!)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: colors.primary.withAlpha(20), shape: BoxShape.circle),
                child: Icon(_icon, size: 20, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: unread ? FontWeight.w700 : FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(notification.body, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(150))),
                  ],
                ),
              ),
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsBell extends StatelessWidget {
  const NotificationsBell({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final userId = context.select<AuthBloc, String?>((b) => b.state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null));
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: NotificationService().streamUnreadCount(userId),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: 'Notifications',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(color: colors.error, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
