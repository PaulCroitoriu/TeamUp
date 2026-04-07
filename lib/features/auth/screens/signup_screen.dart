import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/models/user_model.dart';

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final isBusiness = _role == UserRole.business;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.mapOrNull(
            authenticated: (_) {
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            error: (e) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(e.message),
                  backgroundColor: colors.error,
                ));
            },
          );
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 24,
                vertical: 40,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Back ──
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: colors.onSurface.withAlpha(13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Header ──
                      Text(
                        'Create account',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isBusiness
                            ? 'List your venues and manage bookings'
                            : 'Join the pitch — play with anyone, anywhere',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withAlpha(153),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Role picker ──
                      Text(
                        'I am a',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
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
                              onTap: () =>
                                  setState(() => _role = UserRole.player),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoleCard(
                              icon: Icons.storefront_rounded,
                              label: 'Business',
                              selected: isBusiness,
                              onTap: () =>
                                  setState(() => _role = UserRole.business),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Business name (only for business) ──
                      if (isBusiness) ...[
                        TextFormField(
                          controller: _businessNameCtrl,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Business name',
                            prefixIcon:
                                Icon(Icons.business_center_outlined),
                          ),
                          validator: (v) {
                            if (_role == UserRole.business &&
                                (v == null || v.trim().isEmpty)) {
                              return 'Enter your business name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
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
                              decoration: const InputDecoration(
                                hintText: 'First name',
                                prefixIcon:
                                    Icon(Icons.person_outline_rounded),
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
                              decoration: const InputDecoration(
                                hintText: 'Last name',
                              ),
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
                      const SizedBox(height: 16),

                      // ── Email ──
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter your email';
                          }
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Password ──
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
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
                      const SizedBox(height: 32),

                      // ── Submit ──
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final loading = state.maybeMap(
                            loading: (_) => true,
                            orElse: () => false,
                          );
                          return ElevatedButton(
                            onPressed: loading ? null : _submit,
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
                      const SizedBox(height: 16),

                      // ── Already have account ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withAlpha(153),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withAlpha(20)
              : colors.onSurface.withAlpha(8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.primary : colors.onSurface.withAlpha(26),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28,
                color: selected
                    ? colors.primary
                    : colors.onSurface.withAlpha(128)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? colors.primary
                    : colors.onSurface.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
