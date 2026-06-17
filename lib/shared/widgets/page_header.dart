import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/screens/notifications_screen.dart';

/// Boxed back button used as a [PageHeader] leading on detail pages, so the
/// back affordance looks identical everywhere. Pops the route by default.
class HeaderBackButton extends StatelessWidget {
  const HeaderBackButton({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rMd),
            border: Border.all(color: TUColors.line),
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 22, color: TUColors.ink2),
        ),
      ),
    );
  }
}

/// Shared page header from the TeamUp redesign — a large title, an optional
/// lede subtitle, and the notification bell. Reused across every top-level page
/// so the header looks and behaves identically everywhere.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.trailing, this.leading});

  final String title;
  final String? subtitle;

  /// Optional widget before the title (e.g. a back button on a detail page).
  final Widget? leading;

  /// Defaults to the [NotificationBell]. Pass a widget to override (e.g. an
  /// add button) or [SizedBox.shrink] to hide it.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // Larger, more confident header on desktop; compact on mobile. Acts as the
    // page's top bar: it owns the status-bar inset (0 when already inside a
    // SafeArea) plus comfortable top spacing, so screens don't add their own.
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final topInset = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topInset + (wide ? 28 : 18), 20, wide ? 26 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: wide ? 34 : 28, fontWeight: FontWeight.w800, letterSpacing: -0.7, color: TUColors.ink, height: 1.05),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: wide ? 6 : 4),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: wide ? 15 : 13.5, fontWeight: FontWeight.w500, color: TUColors.ink2, height: 1.35),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing ?? const NotificationBell(),
        ],
      ),
    );
  }
}

/// Boxed notification bell with a ping badge wired to the unread-notification
/// count. Part of the shared header but usable standalone.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthBloc, String?>((b) => b.state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null));

    final button = Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rMd),
            border: Border.all(color: TUColors.line),
          ),
          child: const Icon(Icons.notifications_none_rounded, size: 22, color: TUColors.ink2),
        ),
      ),
    );

    if (userId == null) return button;

    return StreamBuilder<int>(
      stream: NotificationService().streamUnreadCount(userId),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            button,
            if (count > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Sport.tennis.color,
                    borderRadius: BorderRadius.circular(TUColors.rPill),
                    border: Border.all(color: TUColors.bg, width: 2),
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
