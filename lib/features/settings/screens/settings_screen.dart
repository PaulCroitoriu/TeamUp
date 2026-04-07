import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/theme/theme_cubit.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/settings/screens/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 24,
            ),
            children: [
              // ── Account section ──
              _SectionHeader(label: 'Account'),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Profile',
                subtitle: 'Name, email, photo',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
              const Divider(height: 1, indent: 56),

              // ── Appearance section ──
              const SizedBox(height: 28),
              _SectionHeader(label: 'Appearance'),
              const SizedBox(height: 8),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) {
                  return _SettingsTile(
                    icon: mode == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: 'Dark mode',
                    trailing: Switch.adaptive(
                      value: mode == ThemeMode.dark,
                      activeTrackColor: colors.secondary,
                      onChanged: (_) =>
                          context.read<ThemeCubit>().toggle(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.translate_rounded,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  // TODO: language picker
                },
              ),

              // ── Support section ──
              const SizedBox(height: 28),
              _SectionHeader(label: 'Support'),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & FAQ',
                onTap: () {
                  // TODO: help screen
                },
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & Privacy',
                onTap: () {
                  // TODO: legal screen
                },
              ),

              // ── Sign out ──
              const SizedBox(height: 28),
              _SectionHeader(label: ''),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign out',
                destructive: true,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign out?'),
                      content:
                          const Text('You can always sign back in later.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            context
                                .read<AuthBloc>()
                                .add(const AuthEvent.signOutRequested());
                          },
                          child: Text(
                            'Sign out',
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // ── App version ──
              Center(
                child: Text(
                  'TeamUp v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withAlpha(102),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

// ─── Settings tile ───────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = destructive ? colors.error : colors.onSurface;

    return ListTile(
      leading: Icon(icon, color: fg.withAlpha(destructive ? 255 : 179)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: colors.onSurface.withAlpha(128),
                fontSize: 13,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: colors.onSurface.withAlpha(77))
              : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
