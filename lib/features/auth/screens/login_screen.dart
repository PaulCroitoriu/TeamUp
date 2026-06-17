import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/screens/signup_screen.dart';

final _log = Logger();

const _wideBreakpoint = 900.0;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthEvent.signInRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TUColors.bg,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.mapOrNull(
            error: (e) {
              _log.e('Sign in failed: ${e.message}');
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
                  const Expanded(child: _BrandPanel()),
                  Expanded(
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 40,
                          ),
                          child: _formCard(),
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
                    vertical: 40,
                  ),
                  child: _formCard(showLogo: true),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _formCard({bool showLogo = false}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Brand ──
            if (showLogo) ...[
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [TUColors.brand, TUColors.brand900],
                    ),
                    borderRadius: BorderRadius.circular(TUColors.rLg),
                    boxShadow: TUColors.shSm,
                  ),
                  child: const Icon(
                    Icons.sports_soccer_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              'Welcome back',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: TUColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sign in to find your next game',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TUColors.ink2,
              ),
            ),
            const SizedBox(height: 36),

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
              autofillHints: const [AutofillHints.password],
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
                if (v == null || v.isEmpty) return 'Enter your password';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 6),

            // ── Forgot password ──
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: forgot password flow
                },
                style: TextButton.styleFrom(
                  foregroundColor: TUColors.brand700,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 14),

            // ── Sign in button ──
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
                      : const Text('Sign in'),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Divider ──
            Row(
              children: [
                const Expanded(child: Divider(color: TUColors.line)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.6,
                      color: TUColors.ink3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: TUColors.line)),
              ],
            ),
            const SizedBox(height: 24),

            // ── Sign up link ──
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: TUColors.ink2,
                side: const BorderSide(color: TUColors.line),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TUColors.rMd),
                ),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              child: const Text('Create an account'),
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
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: TUColors.ink3),
    labelStyle: const TextStyle(color: TUColors.ink3),
    prefixIcon: Icon(icon, color: TUColors.ink3),
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
  const _BrandPanel();

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
              const Icon(Icons.sports_soccer_rounded,
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
