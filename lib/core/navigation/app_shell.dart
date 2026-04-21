import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
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

  bool get _isBusiness => widget.user.role == UserRole.business;

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
          _Destination(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Messages'),
          _Destination(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
        ];

  List<Widget> get _screens => _isBusiness
      ? const [
          DashboardScreen(),
          ManageVenuesScreen(),
          ManageBookingsScreen(),
          SettingsScreen(),
        ]
      : const [
          ExploreScreen(),
          MyGamesScreen(),
          ConversationsScreen(),
          SettingsScreen(),
        ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final colors = Theme.of(context).colorScheme;
    final destinations = _destinations;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(
              expanded: _sidebarExpanded,
              selectedIndex: _index,
              destinations: destinations,
              onSelected: (i) => setState(() => _index = i),
              onToggle: () =>
                  setState(() => _sidebarExpanded = !_sidebarExpanded),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: colors.onSurface.withAlpha(20),
            ),
            Expanded(child: _screens[_index]),
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
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon, color: colors.primary),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.expanded,
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
    required this.onToggle,
  });

  final bool expanded;
  final int selectedIndex;
  final List<_Destination> destinations;
  final ValueChanged<int> onSelected;
  final VoidCallback onToggle;

  static const _collapsedWidth = 72.0;
  static const _expandedWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: expanded ? _expandedWidth : _collapsedWidth,
        color: colors.surface,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _expandedWidth,
          maxWidth: _expandedWidth,
          child: SizedBox(
            width: _expandedWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          // ── Brand ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Row(
              children: [
                Icon(Icons.sports_soccer_rounded, color: colors.primary, size: 28),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'TeamUp',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ── Destinations ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: destinations.length,
              itemBuilder: (_, i) => _SidebarItem(
                destination: destinations[i],
                selected: selectedIndex == i,
                expanded: expanded,
                onTap: () => onSelected(i),
              ),
            ),
          ),
          // ── Collapse toggle ──
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: _SidebarToggle(expanded: expanded, onTap: onToggle),
          ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = selected ? colors.primary : colors.onSurfaceVariant;
    final labelColor = selected ? colors.primary : colors.onSurface;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            selected ? destination.selectedIcon : destination.icon,
            color: iconColor,
            size: 22,
          ),
          if (expanded) ...[
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                destination.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? colors.primary.withAlpha(26) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Tooltip(
            message: expanded ? '' : destination.label,
            child: content,
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
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                expanded
                    ? Icons.keyboard_double_arrow_left_rounded
                    : Icons.keyboard_double_arrow_right_rounded,
                color: colors.onSurfaceVariant,
                size: 20,
              ),
              if (expanded) ...[
                const SizedBox(width: 14),
                Text(
                  'Collapse',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
