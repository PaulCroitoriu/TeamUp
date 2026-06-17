import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/auth/widgets/player_profile_view.dart';
import 'package:teamup/features/settings/screens/business_profile_screen.dart';
import 'package:teamup/features/settings/screens/edit_profile_screen.dart';
import 'package:teamup/shared/widgets/page_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Business owners get a distinct profile (legal details + booking policies);
    // everyone else gets the player profile.
    final user = context.select<AuthBloc, UserModel?>(
      (b) => b.state.maybeMap(authenticated: (s) => s.user, orElse: () => null),
    );
    if (user != null && user.role == UserRole.business && user.businessId != null) {
      return BusinessProfileScreen(user: user, businessId: user.businessId!);
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
                  title: 'Profile',
                  trailing: _EditButton(),
                ),
                Expanded(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return state.maybeMap(
                        authenticated: (s) => PlayerProfileView(
                          user: s.user,
                          extra: [
                            const _ContactLabel(),
                            const SizedBox(height: 10),
                            _ContactCard(user: s.user),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => EditProfileScreen(user: s.user)),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Edit profile'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: TUColors.ink2,
                                side: const BorderSide(color: TUColors.line),
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        orElse: () => const Center(child: Text('Not signed in')),
                      );
                    },
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

/// Boxed edit affordance for the header trailing slot, mirroring the
/// [HeaderBackButton] / [NotificationBell] chrome used elsewhere.
class _EditButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = context.select<AuthBloc, UserModel?>(
      (b) => b.state.maybeMap(authenticated: (s) => s.user, orElse: () => null),
    );
    if (uid == null) return const SizedBox.shrink();
    return Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EditProfileScreen(user: uid)),
        ),
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rMd),
            border: Border.all(color: TUColors.line),
          ),
          child: const Icon(Icons.edit_outlined, size: 20, color: TUColors.ink2),
        ),
      ),
    );
  }
}

class _ContactLabel extends StatelessWidget {
  const _ContactLabel();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'CONTACT',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: TUColors.ink3),
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
        boxShadow: TUColors.shSm,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: TUColors.brandTint, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 18, color: TUColors.brand700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: TUColors.ink)),
          ),
        ],
      ),
    );
  }
}
