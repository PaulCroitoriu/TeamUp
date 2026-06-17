import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/models/user_model.dart';

final _log = Logger();

const _wideBreakpoint = 900.0;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  bool _obscurePassword = true;
  UserRole _role = UserRole.player;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _businessNameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthEvent.signUpRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          role: _role,
          businessName: _role == UserRole.business
              ? _businessNameCtrl.text.trim()
              : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TUColors.bg,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.mapOrNull(
            authenticated: (_) {
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            error: (e) {
              _log.e('Sign up failed: ${e.message}');
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(e.message),
                  backgroundColor: const Color(0xFFB23B2E),
                ));
            },
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _wideBreakpoint;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: _BrandPanel(isBusiness: _isBusiness)),
                  Expanded(
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 40,
                          ),
                          child: _formCard(showBack: false),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: _formCard(showBack: true),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool get _isBusiness => _role == UserRole.business;

  Widget _formCard({required bool showBack}) {
    final isBusiness = _isBusiness;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Back ──
            if (showBack) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: TUColors.surface,
                  borderRadius: BorderRadius.circular(TUColors.rMd),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(TUColors.rMd),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(TUColors.rMd),
                        border: Border.all(color: TUColors.line),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: TUColors.ink2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Header ──
            const Text(
              'Create account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: TUColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isBusiness
                  ? 'List your venues and manage bookings'
                  : 'Join the pitch — play with anyone, anywhere',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TUColors.ink2,
              ),
            ),
            const SizedBox(height: 28),

            // ── Role picker ──
            const Text(
              'I AM A',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: TUColors.ink3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    icon: Icons.sports_handball_rounded,
                    label: 'Player',
                    selected: _role == UserRole.player,
                    onTap: () => setState(() => _role = UserRole.player),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoleCard(
                    icon: Icons.storefront_rounded,
                    label: 'Business',
                    selected: isBusiness,
                    onTap: () => setState(() => _role = UserRole.business),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Business name (only for business) ──
            if (isBusiness) ...[
              TextFormField(
                controller: _businessNameCtrl,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: TUColors.ink),
                decoration: _inputDecoration(
                  hint: 'Business name',
                  icon: Icons.business_center_outlined,
                ),
                validator: (v) {
                  if (_role == UserRole.business &&
                      (v == null || v.trim().isEmpty)) {
                    return 'Enter your business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
            ],

            // ── Name ──
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.givenName],
                    style: const TextStyle(color: TUColors.ink),
                    decoration: _inputDecoration(
                      hint: 'First name',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.familyName],
                    style: const TextStyle(color: TUColors.ink),
                    decoration: _inputDecoration(hint: 'Last name'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Email ──
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              style: const TextStyle(color: TUColors.ink),
              decoration: _inputDecoration(
                hint: 'Email',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter your email';
                }
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Password ──
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              style: const TextStyle(color: TUColors.ink),
              decoration: _inputDecoration(
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: TUColors.ink3,
                  ),
                  onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 6) {
                  return 'At least 6 characters';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 28),

            // ── Submit ──
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading = state.maybeMap(
                  loading: (_) => true,
                  orElse: () => false,
                );
                return FilledButton(
                  onPressed: loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: TUColors.brand,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TUColors.rMd),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Get started'),
                );
              },
            ),
            const SizedBox(height: 12),

            // ── Already have account ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: TUColors.ink2,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: TUColors.brand700,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared input decoration ────────────────────────────────

InputDecoration _inputDecoration({
  required String hint,
  IconData? icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: TUColors.ink3),
    labelStyle: const TextStyle(color: TUColors.ink3),
    prefixIcon: icon == null ? null : Icon(icon, color: TUColors.ink3),
    suffixIcon: suffix,
    filled: true,
    fillColor: TUColors.surface2,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(TUColors.rMd),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(TUColors.rMd),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(TUColors.rMd),
      borderSide: const BorderSide(color: TUColors.brand, width: 1.4),
    ),
  );
}

// ─── Brand panel (left half on wide screens) ────────────────

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.isBusiness});
  final bool isBusiness;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TUColors.brand, TUColors.brand900],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isBusiness ? Icons.stadium_rounded : Icons.sports_soccer_rounded,
                  size: 56, color: Colors.white),
              const SizedBox(height: 28),
              const Text(
                'TeamUp',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Book a pitch. Fill the spots. Play.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: .85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Role selection card ─────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? TUColors.brandTint : TUColors.surface2,
          borderRadius: BorderRadius.circular(TUColors.rMd),
          border: Border.all(
            color: selected ? TUColors.brand : TUColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28,
                color: selected ? TUColors.brand700 : TUColors.ink3),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? TUColors.brand700 : TUColors.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
