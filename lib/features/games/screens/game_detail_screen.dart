import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/game_status.dart';
import 'package:teamup/core/enums/join_request_status.dart';
import 'package:teamup/core/enums/payment_method.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/theme/sport_tile.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/features/games/models/game_model.dart';
import 'package:teamup/features/games/models/join_request_model.dart';
import 'package:teamup/features/messaging/screens/game_chat_screen.dart';
import 'package:teamup/shared/widgets/adaptive_sheet.dart';

final _log = Logger();

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
String _t(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context) {
    final service = GameService();
    final userId = context.select<AuthBloc, String?>((b) => b.state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null));

    return Scaffold(
      backgroundColor: TUColors.bg,
      appBar: AppBar(
        backgroundColor: TUColors.bg,
        foregroundColor: TUColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Game', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4, color: TUColors.ink)),
      ),
      body: StreamBuilder<GameModel>(
        stream: service.streamGame(gameId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Failed to load: ${snap.error}', textAlign: TextAlign.center)));
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final game = snap.data!;
          final isHost = game.hostId == userId;
          final isMember = userId != null && game.playerIds.contains(userId);
          final perPlayer = (game.pricePerHour / 100 / game.capacity).round();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _HeaderCard(game: game, perPlayer: perPlayer),
              // ── your request status (non-members who requested) ──
              if (!isHost && !isMember && userId != null) ...[
                const SizedBox(height: 14),
                _MyRequestBanner(game: game, userId: userId, service: service, perPlayer: perPlayer),
              ],
              const SizedBox(height: 14),
              // ── actions: message the team · manage booking ──
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Message team',
                      onTap: game.bookingId == null
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GameChatScreen(
                                  bookingId: game.bookingId!,
                                  participantIds: game.playerIds,
                                  userId: userId ?? '',
                                  title: '${game.sport.label} team',
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (isHost && game.bookingId != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.tune_rounded,
                        label: 'Manage booking',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: game.bookingId!))),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              _RosterCard(game: game),
              if (isMember && !isHost) ...[
                const SizedBox(height: 14),
                _LeaveButton(gameId: game.id, userId: userId, service: service),
              ],
              if (isHost && game.requiresApproval) ...[
                const SizedBox(height: 20),
                const Text('Join requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: TUColors.ink)),
                const SizedBox(height: 12),
                _RequestsSection(gameId: gameId, service: service),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.game, required this.perPlayer});
  final GameModel game;
  final int perPlayer;

  @override
  Widget build(BuildContext context) {
    final full = game.spotsOpen <= 0 || game.status != GameStatus.open;
    final start = game.startTime;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TUColors.surface,
        borderRadius: BorderRadius.circular(TUColors.rLg),
        border: Border.all(color: TUColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: game.sport.color, borderRadius: BorderRadius.circular(14)),
            child: Center(child: SportGlyph(sport: game.sport, size: 28, color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(game.sport.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: TUColors.ink)),
                    const SizedBox(width: 8),
                    if (full)
                      const _Pill(label: 'Full', bg: TUColors.busyBg, fg: TUColors.ink3)
                    else
                      const _Pill(label: 'Open', bg: TUColors.lime, fg: TUColors.brand900),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${_weekdays[start.weekday - 1]} ${start.day} · ${_t(start)}–${_t(game.endTime)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: TUColors.ink2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$perPlayer ${game.currency}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: TUColors.brand700)),
              const Text('per player', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TUColors.ink3)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RosterCard extends StatelessWidget {
  const _RosterCard({required this.game});
  final GameModel game;

  @override
  Widget build(BuildContext context) {
    final needs = game.spotsOpen;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TUColors.surface,
        borderRadius: BorderRadius.circular(TUColors.rLg),
        border: Border.all(color: TUColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${game.spotsFilled}/${game.capacity} players', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
              const Spacer(),
              Text(
                needs > 0 ? 'Needs $needs more' : 'Team complete',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: needs > 0 ? TUColors.brand700 : TUColors.ink3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (var i = 0; i < game.capacity; i++)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: i < game.spotsFilled ? TUColors.brand : TUColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                    border: i < game.spotsFilled ? null : Border.all(color: TUColors.line2, width: 1.5),
                  ),
                  child: i < game.spotsFilled ? const Icon(Icons.person, size: 14, color: Colors.white) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestsSection extends StatelessWidget {
  const _RequestsSection({required this.gameId, required this.service});
  final String gameId;
  final GameService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JoinRequestModel>>(
      stream: service.streamGameRequests(gameId),
      builder: (context, snap) {
        // Confirmed players already appear in the roster; show everything else
        // (pending to act on, approved awaiting payment, declined).
        final visible = (snap.data ?? const <JoinRequestModel>[]).where((r) => r.status != JoinRequestStatus.confirmed).toList();
        if (visible.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: TUColors.surface2, borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
            child: const Text('No requests yet', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
          );
        }
        return Column(
          children: [for (final r in visible) Padding(padding: const EdgeInsets.only(bottom: 10), child: _RequestTile(request: r, service: service))],
        );
      },
    );
  }
}

class _RequestTile extends StatefulWidget {
  const _RequestTile({required this.request, required this.service});
  final JoinRequestModel request;
  final GameService service;

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile> {
  bool _busy = false;

  String get _subtitle => switch (widget.request.status) {
    JoinRequestStatus.pending => 'Wants to join',
    JoinRequestStatus.approved => 'Approved — waiting for payment',
    JoinRequestStatus.declined => 'Request declined',
    JoinRequestStatus.confirmed => 'Joined the game',
  };

  Future<void> _decide(bool approve) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      if (approve) {
        await widget.service.approveRequest(gameId: widget.request.gameId, userId: widget.request.userId);
      } else {
        await widget.service.declineRequest(gameId: widget.request.gameId, userId: widget.request.userId);
      }
    } catch (e, st) {
      _log.e('Request decision failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Could not update request: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final short = widget.request.userId.length > 6 ? widget.request.userId.substring(0, 6) : widget.request.userId;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: TUColors.surface, borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: TUColors.brandSoft, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline_rounded, size: 20, color: TUColors.brand700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Player · $short', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: TUColors.ink)),
                Text(_subtitle, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
              ],
            ),
          ),
          if (widget.request.status == JoinRequestStatus.pending) ...[
            if (_busy)
              const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
            else ...[
              _IconAction(icon: Icons.close_rounded, color: TUColors.ink3, onTap: () => _decide(false)),
              const SizedBox(width: 8),
              _IconAction(icon: Icons.check_rounded, color: Colors.white, bg: TUColors.brand, onTap: () => _decide(true)),
            ],
          ] else if (widget.request.status == JoinRequestStatus.approved)
            const _Pill(label: 'Awaiting pay', bg: TUColors.brandSoft, fg: TUColors.brand700)
          else
            const _Pill(label: 'Declined', bg: Color(0xFFFBEEE9), fg: Color(0xFFB23B2E)),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.color, required this.onTap, this.bg});
  final IconData icon;
  final Color color;
  final Color? bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg ?? TUColors.surface2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 20, color: color)),
      ),
    );
  }
}

/// Shows the current user's join-request status, with a Pay-to-confirm action
/// once the host has approved.
class _MyRequestBanner extends StatelessWidget {
  const _MyRequestBanner({required this.game, required this.userId, required this.service, required this.perPlayer});
  final GameModel game;
  final String userId;
  final GameService service;
  final int perPlayer;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<JoinRequestModel?>(
      stream: service.streamMyRequest(game.id, userId),
      builder: (context, snap) {
        final r = snap.data;
        if (r == null || r.status == JoinRequestStatus.confirmed) return const SizedBox.shrink();

        switch (r.status) {
          case JoinRequestStatus.pending:
            return const _Banner(
              icon: Icons.hourglass_top_rounded,
              bg: TUColors.surface2,
              fg: TUColors.ink2,
              title: 'Request pending',
              sub: 'The host will review your request — you’ll be notified.',
            );
          case JoinRequestStatus.declined:
            return const _Banner(
              icon: Icons.person_off_outlined,
              bg: Color(0xFFFBEEE9),
              fg: Color(0xFFB23B2E),
              title: 'Request declined',
              sub: 'The host declined your request to join this game.',
            );
          case JoinRequestStatus.approved:
            return _Banner(
              icon: Icons.verified_outlined,
              bg: TUColors.brandTint,
              fg: TUColors.brand700,
              title: "You're approved!",
              sub: 'Pay your $perPlayer ${game.currency} share to confirm your spot.',
              action: ('Pay & join', () => _pay(context)),
            );
          case JoinRequestStatus.confirmed:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Future<void> _pay(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showAdaptiveSheet<bool>(context, builder: (_) => _PaySheet(game: game, perPlayer: perPlayer));
    if (ok != true) return;
    try {
      await service.confirmJoin(gameId: game.id, userId: userId, method: ok == true ? _lastMethod : PaymentMethod.card);
    } catch (e, st) {
      _log.e('Confirm join failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text("You're in!")));
  }
}

// The pay sheet returns the chosen method via this; simple module-level handoff
// keeps the sheet decoupled from the banner.
PaymentMethod _lastMethod = PaymentMethod.card;

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.bg, required this.fg, required this.title, required this.sub, this.action});
  final IconData icon;
  final Color bg;
  final Color fg;
  final String title;
  final String sub;
  final (String, VoidCallback)? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(TUColors.rLg), border: Border.all(color: TUColors.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg)),
                    const SizedBox(height: 2),
                    Text(sub, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: TUColors.ink2, height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: action!.$2,
                style: FilledButton.styleFrom(
                  backgroundColor: TUColors.brand,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                child: Text(action!.$1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PayMethod {
  const _PayMethod(this.id, this.label, this.sub, this.icon, this.method);
  final String id;
  final String label;
  final String sub;
  final IconData icon;
  final PaymentMethod method;
}

const _payMethods = [
  _PayMethod('visa', 'Visa', '•••• 4242', Icons.credit_card_rounded, PaymentMethod.card),
  _PayMethod('apple', 'Apple Pay', 'Default', Icons.apple_rounded, PaymentMethod.card),
  _PayMethod('cash', 'Cash at venue', 'Pay on arrival', Icons.payments_outlined, PaymentMethod.cash),
];

/// Pay-after-approval sheet: per-player share + method, returns true on confirm
/// (the chosen method is handed back via [_lastMethod]).
class _PaySheet extends StatefulWidget {
  const _PaySheet({required this.game, required this.perPlayer});
  final GameModel game;
  final int perPlayer;

  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  String _methodId = 'visa';

  @override
  Widget build(BuildContext context) {
    final mobile = isMobileWidth(context);
    final cur = widget.game.currency;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mobile)
            Container(margin: const EdgeInsets.only(top: 10, bottom: 2), width: 42, height: 5, decoration: BoxDecoration(color: TUColors.line2, borderRadius: BorderRadius.circular(TUColors.rPill))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 16, 12),
            child: Row(
              children: [
                const Expanded(child: Text('Pay to confirm', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: TUColors.ink))),
                _IconAction(icon: Icons.close_rounded, color: TUColors.ink2, onTap: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(color: TUColors.brandTint, borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.brandSoft)),
                    child: Row(
                      children: [
                        const Expanded(child: Text('Your spot', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink))),
                        Text('${widget.perPlayer} $cur', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: TUColors.brand700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final m in _payMethods) ...[
                    _PayOptionRow(method: m, selected: _methodId == m.id, onTap: () => setState(() => _methodId = m.id)),
                    if (m != _payMethods.last) const SizedBox(height: 9),
                  ],
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: TUColors.line))),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
            child: FilledButton(
              onPressed: () {
                _lastMethod = _payMethods.firstWhere((m) => m.id == _methodId).method;
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: TUColors.brand,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              child: Text('Pay ${widget.perPlayer} $cur & join'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayOptionRow extends StatelessWidget {
  const _PayOptionRow({required this.method, required this.selected, required this.onTap});
  final _PayMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TUColors.brandTint : TUColors.surface,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: selected ? TUColors.brand : TUColors.line2, width: 1.5)),
          child: Row(
            children: [
              Icon(method.icon, size: 22, color: selected ? TUColors.brand700 : TUColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: TUColors.ink)),
                    Text(method.sub, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? TUColors.brand : Colors.transparent, border: Border.all(color: selected ? TUColors.brand : TUColors.line2, width: 2)),
                child: selected ? const Center(child: SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)))) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveButton extends StatefulWidget {
  const _LeaveButton({required this.gameId, required this.userId, required this.service});
  final String gameId;
  final String userId;
  final GameService service;

  @override
  State<_LeaveButton> createState() => _LeaveButtonState();
}

class _LeaveButtonState extends State<_LeaveButton> {
  bool _busy = false;

  Future<void> _leave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave this game?'),
        content: const Text('Your spot reopens for someone else.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Stay')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Leave', style: TextStyle(color: Color(0xFFB23B2E)))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.service.leaveGame(gameId: widget.gameId, userId: widget.userId);
      if (mounted) nav.pop();
    } catch (e, st) {
      _log.e('Leave game failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Could not leave: $e')));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _busy ? null : _leave,
      icon: _busy
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.logout_rounded, size: 18),
      label: const Text('Leave game'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFB23B2E),
        side: const BorderSide(color: Color(0xFFE7C3BC)),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: TUColors.surface,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 19, color: TUColors.brand700),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: TUColors.ink),
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(TUColors.rPill)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
