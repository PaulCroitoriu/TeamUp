import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return state.maybeMap(
            authenticated: (s) => _ProfileBody(
              user: s.user,
              isWide: isWide,
              theme: theme,
              colors: colors,
            ),
            orElse: () => const Center(child: Text('Not signed in')),
          );
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.user,
    required this.isWide,
    required this.theme,
    required this.colors,
  });

  final UserModel user;
  final bool isWide;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 24,
            vertical: 32,
          ),
          children: [
            // ── Avatar ──
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: colors.primary.withAlpha(26),
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${user.firstName} ${user.lastName}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.secondary.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role == UserRole.business ? 'Business' : 'Player',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // ── Info fields ──
            _InfoRow(label: 'First name', value: user.firstName),
            _InfoRow(label: 'Last name', value: user.lastName),
            _InfoRow(label: 'Email', value: user.email),
            if (user.businessId != null)
              _InfoRow(label: 'Business ID', value: user.businessId!),

            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                // TODO: edit profile
              },
              child: const Text('Edit profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Read-only info row ──────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurface.withAlpha(128),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.onSurface.withAlpha(26),
              ),
            ),
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
