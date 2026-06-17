import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';
import 'package:teamup/shared/widgets/page_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final service = NotificationService();

    final userId = context.select<AuthBloc, String?>((b) => b.state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null));

    if (userId == null) {
      return const Scaffold(
        backgroundColor: TUColors.bg,
        body: Center(child: Text('Sign in to see notifications')),
      );
    }

    return Scaffold(
      backgroundColor: TUColors.bg,
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
                  title: 'Notifications',
                  trailing: _MarkAllReadButton(onTap: () => service.markAllRead(userId)),
                ),
                Expanded(
                  child: SelectionArea(
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
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: TUColors.line),
                          itemBuilder: (_, i) => _NotificationTile(notification: items[i], service: service),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: TUColors.brand700,
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
      ),
      child: const Text('Mark all read'),
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
    NotificationType.joinRequest => Icons.person_add_alt_1_outlined,
    NotificationType.joinApproved => Icons.how_to_reg_outlined,
    NotificationType.joinDeclined => Icons.person_off_outlined,
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
          final nav = Navigator.of(context);
          if (unread) {
            await service.markRead(notification.id);
          }
          // Everything opens the unified booking page. A game notification is
          // resolved to its booking first.
          String? bookingId = notification.bookingId;
          if (bookingId == null && notification.gameId != null) {
            try {
              bookingId = (await GameService().streamGame(notification.gameId!).first).bookingId;
            } catch (_) {}
          }
          if (bookingId == null) return;
          nav.push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: bookingId!)));
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
