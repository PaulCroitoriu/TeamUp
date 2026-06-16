import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/auth/widgets/player_profile_view.dart';
import 'package:teamup/features/settings/screens/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TUColors.bg,
      appBar: AppBar(
        backgroundColor: TUColors.bg,
        foregroundColor: TUColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4)),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return state.maybeMap(
            authenticated: (s) => PlayerProfileView(
              user: s.user,
              extra: [
                _ContactCard(user: s.user),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EditProfileScreen(user: s.user)),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TUColors.brand700,
                    side: const BorderSide(color: TUColors.line2, width: 1.5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            orElse: () => const Center(child: Text('Not signed in')),
          );
        },
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TUColors.surface,
        borderRadius: BorderRadius.circular(TUColors.rLg),
        border: Border.all(color: TUColors.line),
      ),
      child: Column(
        children: [
          _ContactRow(icon: Icons.mail_outline_rounded, value: user.email),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const Divider(height: 1, thickness: 1, color: TUColors.line),
            _ContactRow(icon: Icons.phone_outlined, value: user.phone!),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 19, color: TUColors.ink3),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: TUColors.ink)),
          ),
        ],
      ),
    );
  }
}
