import 'package:flutter/material.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/data/push_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';
import 'package:teamup/features/notifications/widgets/notification_toast_listener.dart';
import 'package:teamup/features/games/screens/explore_screen.dart';
import 'package:teamup/features/games/screens/my_games_screen.dart';
import 'package:teamup/features/messaging/screens/conversations_screen.dart';
import 'package:teamup/features/settings/screens/settings_screen.dart';
import 'package:teamup/features/venues/screens/dashboard_screen.dart';
import 'package:teamup/features/venues/screens/manage_venues_screen.dart';
import 'package:teamup/features/bookings/screens/manage_bookings_screen.dart';

/// Top-level scaffold that switches between bottom nav (mobile)
/// and navigation rail (≥ 600 px).
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.user});
  final UserModel user;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _sidebarExpanded = true;
  final _pushService = PushService();

  // On desktop each tab keeps its own navigator so detail pages open *inside*
  // the content pane and the sidebar stays visible. Tabs are built lazily and
  // kept alive once visited, preserving their navigation stack across switches.
  final List<GlobalKey<NavigatorState>> _navKeys =
      List.generate(4, (_) => GlobalKey<NavigatorState>());
  final Set<int> _built = {0};

  bool get _isBusiness => widget.user.role == UserRole.business;

  /// Switch tabs; re-tapping the active tab pops its stack back to the root.
  void _select(int i) {
    if (i == _index) {
      _navKeys[i].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() {
      _index = i;
      _built.add(i);
    });
  }

  @override
  void initState() {
    super.initState();
    _pushService.register(widget.user.uid);
  }

  @override
  void didUpdateWidget(covariant AppShell old) {
    super.didUpdateWidget(old);
    if (old.user.uid != widget.user.uid) {
      _pushService.register(widget.user.uid);
    }
  }

  @override
  void dispose() {
    _pushService.unregister(widget.user.uid);
    super.dispose();
  }

  List<_Destination> get _destinations => _isBusiness
      ? const [
          _Destination(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
          _Destination(Icons.store_outlined, Icons.store_rounded, 'Venues'),
          _Destination(Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Bookings'),
          _Destination(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
        ]
      : const [
          _Destination(Icons.explore_outlined, Icons.explore_rounded, 'Explore'),
          _Destination(Icons.sports_soccer_outlined, Icons.sports_soccer_rounded, 'My Games'),
          _Destination(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Messages', isMessages: true),
          _Destination(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
        ];

  List<Widget> get _screens => _isBusiness
      ? const [DashboardScreen(), ManageVenuesScreen(), ManageBookingsScreen(), SettingsScreen()]
      : const [ExploreScreen(), MyGamesScreen(), ConversationsScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final colors = Theme.of(context).colorScheme;
    final destinations = _destinations;

    final shell = _buildShell(context, isWide, colors, destinations);
    return NotificationToastListener(userId: widget.user.uid, child: shell);
  }

  Widget _buildShell(BuildContext context, bool isWide, ColorScheme colors, List<_Destination> destinations) {
    if (isWide) {
      final screens = _screens;
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(
              expanded: _sidebarExpanded,
              selectedIndex: _index,
              destinations: destinations,
              userId: widget.user.uid,
              onSelected: _select,
              onToggle: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
            ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    if (_built.contains(i))
                      _TabNavigator(navigatorKey: _navKeys[i], child: screens[i])
                    else
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withAlpha(26),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: d.isMessages
                  ? _UnreadMessagesDot(userId: widget.user.uid, child: Icon(d.icon))
                  : Icon(d.icon),
              selectedIcon: d.isMessages
                  ? _UnreadMessagesDot(userId: widget.user.uid, child: Icon(d.selectedIcon, color: colors.primary))
                  : Icon(d.selectedIcon, color: colors.primary),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

/// A per-tab nested navigator (desktop). Its root route renders the tab screen;
/// detail pages pushed from within stay inside the content pane, leaving the
/// sidebar in place.
class _TabNavigator extends StatelessWidget {
  const _TabNavigator({required this.navigatorKey, required this.child});
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => child,
      ),
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label, {this.isMessages = false});
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isMessages;
}

/// Overlays a small red dot on [child] when the user has unread chat messages,
/// used to badge the Messages nav item.
class _UnreadMessagesDot extends StatelessWidget {
  const _UnreadMessagesDot({required this.userId, required this.child});
  final String userId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService().streamForUser(userId),
      builder: (context, snap) {
        final unread = (snap.data ?? const <NotificationModel>[])
            .any((n) => !n.read && n.type == NotificationType.newMessage);
        if (!unread) return child;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -3,
              right: -4,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5484D),
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Dark pitch-green gradient sidebar from the TeamUp redesign — brand logo
/// tile, lime-accented selection with a left accent bar, and a Collapse row.
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.expanded, required this.selectedIndex, required this.destinations, required this.userId, required this.onSelected, required this.onToggle});

  final bool expanded;
  final int selectedIndex;
  final List<_Destination> destinations;
  final String userId;
  final ValueChanged<int> onSelected;
  final VoidCallback onToggle;

  static const _collapsedWidth = 80.0;
  static const _expandedWidth = 248.0;
  static const _sideEnd = Color(0xFF0A2A18);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: expanded ? _expandedWidth : _collapsedWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.1, -1),
            end: Alignment(0.1, 1),
            colors: [TUColors.brand900, _sideEnd],
            stops: [0, 0.9],
          ),
        ),
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _expandedWidth,
          maxWidth: _expandedWidth,
          child: SizedBox(
            width: _expandedWidth,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Brand ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: expanded
                            // Full lockup (mark + wordmark) tuned for dark backgrounds.
                            ? Image.asset('assets/logo/teamup-lockup-dark.png', height: 52, fit: BoxFit.contain)
                            // Collapsed rail — mark only.
                            : Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 16, offset: const Offset(0, 6))],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.asset('assets/logo/teamup-mark.png', width: 38, height: 38, fit: BoxFit.cover),
                                ),
                              ),
                      ),
                    ),
                    // ── Destinations ──
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: destinations.length,
                        itemBuilder: (_, i) => _SidebarItem(
                          destination: destinations[i],
                          selected: selectedIndex == i,
                          expanded: expanded,
                          userId: userId,
                          onTap: () => onSelected(i),
                        ),
                      ),
                    ),
                    // ── Collapse toggle ──
                    _SidebarToggle(expanded: expanded, onTap: onToggle),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.destination, required this.selected, required this.expanded, required this.userId, required this.onTap});

  final _Destination destination;
  final bool selected;
  final bool expanded;
  final String userId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : Colors.white.withValues(alpha: .66);

    // The highlight pill is inset from the sidebar's left edge, leaving a gutter
    // for the lime accent bar, which sits flush against the screen edge.
    final pill = Container(
      margin: const EdgeInsets.only(left: 14, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? TUColors.lime.withValues(alpha: .14) : Colors.transparent,
        borderRadius: BorderRadius.circular(TUColors.rMd),
      ),
      child: Row(
        children: [
          destination.isMessages
              ? _UnreadMessagesDot(
                  userId: userId,
                  child: Icon(selected ? destination.selectedIcon : destination.icon, color: fg, size: 21),
                )
              : Icon(selected ? destination.selectedIcon : destination.icon, color: fg, size: 21),
          if (expanded) ...[
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                destination.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: .06),
          child: Tooltip(
            message: expanded ? '' : destination.label,
            child: Stack(
              children: [
                pill,
                // lime accent bar flush against the sidebar's left (screen) edge
                if (selected)
                  Positioned(
                    left: 0,
                    top: 12,
                    bottom: 12,
                    child: Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        color: TUColors.lime,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
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

class _SidebarToggle extends StatelessWidget {
  const _SidebarToggle({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Colors.white.withValues(alpha: .5);
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 12, 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x1AFFFFFF)))),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TUColors.rMd),
          hoverColor: Colors.white.withValues(alpha: .06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(expanded ? Icons.keyboard_arrow_left_rounded : Icons.keyboard_arrow_right_rounded, color: fg, size: 20),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  Text('Collapse', style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
