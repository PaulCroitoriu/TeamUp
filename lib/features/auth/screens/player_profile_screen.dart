import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/auth/widgets/player_profile_view.dart';
import 'package:teamup/shared/widgets/page_header.dart';

final _log = Logger();

/// Shows another player's profile, loaded by id. When [onApprove]/[onDecline]
/// are provided (e.g. a host reviewing a join request) a bottom action bar lets
/// them decide right from the profile; the screen pops on a successful action.
class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key, required this.userId, this.onApprove, this.onDecline, this.onRemove});

  final String userId;
  final Future<void> Function()? onApprove;
  final Future<void> Function()? onDecline;

  /// Host-only: remove this already-joined player from the game. Shown as a
  /// destructive action (with confirmation) when no approve/decline is set.
  final Future<void> Function()? onRemove;

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  late final Future<UserModel> _user = AuthService().getUserProfile(widget.userId);
  bool _busy = false;

  Future<void> _act(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await action();
      nav.pop();
    } catch (e, st) {
      _log.e('Request decision failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Could not update request: $e')));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmRemove() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this player?'),
        content: const Text('They’ll be removed from the game and their spot reopens.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove', style: TextStyle(color: Color(0xFFB23B2E)))),
        ],
      ),
    );
    if (ok == true) await _act(widget.onRemove!);
  }

  @override
  Widget build(BuildContext context) {
    final hasActions = widget.onApprove != null || widget.onDecline != null || widget.onRemove != null;
    return Scaffold(
      backgroundColor: TUColors.bg,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TUColors.pageMaxWidth),
            child: FutureBuilder<UserModel>(
              future: _user,
              builder: (context, snap) {
                if (snap.hasError) {
                  _log.e('Load player profile failed', error: snap.error, stackTrace: snap.stackTrace);
                }
                final user = snap.data;
                final name = user == null ? '' : '${user.firstName} ${user.lastName}'.trim();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PageHeader(
                      leading: const HeaderBackButton(),
                      title: name.isEmpty ? 'Profile' : name,
                      subtitle: user?.role.label,
                    ),
                    Expanded(
                      child: snap.hasError
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Could not load this player: ${snap.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: TUColors.ink2),
                                ),
                              ),
                            )
                          : user == null
                              ? const Center(child: CircularProgressIndicator())
                              : PlayerProfileView(user: user),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: hasActions
          ? _ActionBar(busy: _busy, onApprove: widget.onApprove, onDecline: widget.onDecline, onRemove: widget.onRemove, act: _act, onConfirmRemove: _confirmRemove)
          : null,
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.busy, required this.onApprove, required this.onDecline, required this.onRemove, required this.act, required this.onConfirmRemove});
  final bool busy;
  final Future<void> Function()? onApprove;
  final Future<void> Function()? onDecline;
  final Future<void> Function()? onRemove;
  final Future<void> Function(Future<void> Function()) act;
  final VoidCallback onConfirmRemove;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: TUColors.bg,
          border: Border(top: BorderSide(color: TUColors.line)),
        ),
        child: onRemove != null && onApprove == null && onDecline == null
            ? OutlinedButton.icon(
                onPressed: busy ? null : onConfirmRemove,
                icon: busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB23B2E)))
                    : const Icon(Icons.person_remove_outlined, size: 18),
                label: const Text('Remove from game'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB23B2E),
                  side: const BorderSide(color: Color(0xFFE7C3BC)),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              )
            : Row(
          children: [
            if (onDecline != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => act(onDecline!),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB23B2E),
                    side: const BorderSide(color: Color(0xFFE7C3BC)),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Decline'),
                ),
              ),
            if (onDecline != null && onApprove != null) const SizedBox(width: 12),
            if (onApprove != null)
              Expanded(
                child: FilledButton(
                  onPressed: busy ? null : () => act(onApprove!),
                  style: FilledButton.styleFrom(
                    backgroundColor: TUColors.brand,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  child: busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Approve'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
