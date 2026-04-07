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
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: colors.surface,
              indicatorColor: colors.primary.withAlpha(26),
              selectedIconTheme: IconThemeData(color: colors.primary),
              unselectedIconTheme:
                  IconThemeData(color: colors.onSurface.withAlpha(128)),
              selectedLabelTextStyle: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: colors.onSurface.withAlpha(128),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              leading: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                child: Icon(
                  Icons.sports_soccer_rounded,
                  color: colors.primary,
                  size: 32,
                ),
              ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
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
