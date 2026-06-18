import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/messaging/data/messaging_service.dart';
import 'package:teamup/features/messaging/models/conversation_model.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';
import 'package:teamup/shared/widgets/page_header.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.select<AuthBloc, String?>((b) => b.state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null));

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
                const PageHeader(title: 'Messages', subtitle: 'Your booking and team chats'),
                Expanded(
                  child: uid == null
                      ? const Center(child: Text('Sign in to see your messages', style: TextStyle(color: TUColors.ink3)))
                      : _ConversationList(userId: uid),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConversationModel>>(
      stream: MessagingService().streamUserConversations(userId),
      builder: (context, convSnap) {
        if (convSnap.connectionState == ConnectionState.waiting && !convSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (convSnap.hasError) {
          return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Messages failed to load: ${convSnap.error}', textAlign: TextAlign.center)));
        }
        final conversations = (convSnap.data ?? const <ConversationModel>[]).where((c) => c.bookingId != null).toList();
        if (conversations.isEmpty) return const _EmptyInbox();

        // The "other" people across all threads, fetched once for names/avatars.
        final otherIds = <String>{
          for (final c in conversations) ...c.participantIds.where((id) => id != userId),
        };

        return FutureBuilder<List<UserModel>>(
          future: AuthService().getUsersByIds(otherIds.toList()),
          builder: (context, usersSnap) {
            final byId = {for (final u in (usersSnap.data ?? const <UserModel>[])) u.uid: u};
            return StreamBuilder<List<NotificationModel>>(
              stream: NotificationService().streamForUser(userId),
              builder: (context, notifSnap) {
                final unreadBookingIds = {
                  for (final n in (notifSnap.data ?? const <NotificationModel>[]))
                    if (!n.read && n.type == NotificationType.newMessage && n.bookingId != null) n.bookingId!,
                };
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final c = conversations[i];
                    final others = c.participantIds.where((id) => id != userId).toList();
                    return _ConversationTile(
                      conversation: c,
                      userId: userId,
                      others: [for (final id in others) byId[id]].whereType<UserModel>().toList(),
                      otherCount: others.length,
                      unread: unreadBookingIds.contains(c.bookingId),
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

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.userId,
    required this.others,
    required this.otherCount,
    required this.unread,
  });

  final ConversationModel conversation;
  final String userId;
  final List<UserModel> others;
  final int otherCount;
  final bool unread;

  bool get _isGroup => otherCount > 1;

  String get _title {
    // Prefer the denormalised match label ("Football · 21 Jun · 18:00").
    final t = conversation.title;
    if (t != null && t.isNotEmpty) return t;
    // Fallback for legacy conversations without a stored title.
    if (_isGroup) return 'Team · ${otherCount + 1} players';
    if (others.isNotEmpty) return '${others.first.firstName} ${others.first.lastName}'.trim();
    return 'Conversation';
  }

  String get _preview {
    final text = conversation.lastMessageText ?? 'No messages yet';
    final mine = conversation.lastMessageSenderId == userId;
    return mine ? 'You: $text' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TUColors.surface,
      borderRadius: BorderRadius.circular(TUColors.rLg),
      child: InkWell(
        onTap: conversation.bookingId == null
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: conversation.bookingId!)),
              ),
        borderRadius: BorderRadius.circular(TUColors.rLg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rLg),
            border: Border.all(color: TUColors.line),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: TUColors.brandSoft,
                child: _isGroup
                    ? const Icon(Icons.groups_rounded, size: 22, color: TUColors.brand700)
                    : Text(
                        others.isNotEmpty ? others.first.initials : '?',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.brand700),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: unread ? FontWeight.w800 : FontWeight.w700, color: TUColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                        color: unread ? TUColors.ink2 : TUColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    conversation.lastMessageAt == null ? '' : _stamp(conversation.lastMessageAt!),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: TUColors.ink3),
                  ),
                  const SizedBox(height: 6),
                  if (unread)
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFE5484D), shape: BoxShape.circle))
                  else
                    const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 48, color: TUColors.ink3.withValues(alpha: .5)),
            const SizedBox(height: 16),
            const Text('No messages yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: TUColors.ink)),
            const SizedBox(height: 8),
            const Text(
              'Chats from your bookings and games show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: TUColors.ink3),
            ),
          ],
        ),
      ),
    );
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _stamp(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return _weekdays[d.weekday - 1];
  return '${d.day} ${_months[d.month - 1]}';
}
