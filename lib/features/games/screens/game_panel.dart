import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/game_status.dart';
import 'package:teamup/core/enums/join_request_status.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/auth/screens/player_profile_screen.dart';
import 'package:teamup/features/games/data/game_service.dart';
import 'package:teamup/features/games/models/game_model.dart';
import 'package:teamup/features/games/models/join_request_model.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/shared/widgets/adaptive_sheet.dart';

final _log = Logger();


/// The open-game / team layer for a slot, embedded inside the unified booking
/// detail page when the booking has a game. Renders status, the join/request
/// action (non-members), host edit, the roster, leave, and join requests — the
/// reservation info and chat are provided by the host page.
class GamePanel extends StatelessWidget {
  const GamePanel({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context) {
    final service = GameService();
    // The venue owner manages the booking but isn't a player, so player-only
    // actions (join / leave) are gated to player accounts.
    final auth = context.select<AuthBloc, (String?, bool)>(
      (b) => b.state.maybeMap(
        authenticated: (s) => (s.user.uid, s.user.role == UserRole.player),
        orElse: () => (null, false),
      ),
    );
    final userId = auth.$1;
    final isPlayer = auth.$2;

    return StreamBuilder<GameModel>(
      stream: service.streamGame(gameId),
      builder: (context, snap) {
        if (snap.hasError) {
          return Padding(padding: const EdgeInsets.all(16), child: Text('Failed to load game: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
        }

        final game = snap.data!;
        final isHost = game.hostId == userId;
        final isMember = userId != null && game.playerIds.contains(userId);
        final perPlayer = (game.pricePerHour / 100 / game.capacity).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _GameStatusCard(game: game, perPlayer: perPlayer),
            // ── join / request action + your request status (non-members) ──
            if (isPlayer && !isHost && !isMember && userId != null) ...[
              const SizedBox(height: 14),
              _JoinSection(game: game, userId: userId, service: service, perPlayer: perPlayer),
            ],
            if (isHost) ...[
              const SizedBox(height: 12),
              _EditGameButton(game: game, service: service),
            ],
            const SizedBox(height: 16),
            _RosterCard(game: game, isHost: isHost, service: service),
            if (isPlayer && isMember && !isHost) ...[
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
    );
  }
}

/// Compact "Open game" status card for the unified page — the slot's date,
/// price and pitch are already shown by the booking header, so this focuses on
/// the game-specific status and the per-player share.
class _GameStatusCard extends StatelessWidget {
  const _GameStatusCard({required this.game, required this.perPlayer});
  final GameModel game;
  final int perPlayer;

  @override
  Widget build(BuildContext context) {
    final full = game.spotsOpen <= 0 || game.status != GameStatus.open;
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: TUColors.brandTint, borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.bolt_rounded, size: 24, color: TUColors.brand700),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Open game', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: TUColors.ink)),
                    const SizedBox(width: 8),
                    if (game.status == GameStatus.private)
                      const _Pill(label: 'Private', bg: TUColors.surface2, fg: TUColors.ink2)
                    else if (full)
                      const _Pill(label: 'Full', bg: TUColors.busyBg, fg: TUColors.ink3)
                    else
                      const _Pill(label: 'Open', bg: TUColors.lime, fg: TUColors.brand900),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  game.spotsOpen > 0 ? 'Needs ${game.spotsOpen} more to fill the team' : 'Team complete',
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

/// Roster with the real players who've joined (avatar + name, host badged) and
/// a chip for each remaining open spot. Names are looked up once per roster
/// change so the card doesn't refetch on every game snapshot.
class _RosterCard extends StatefulWidget {
  const _RosterCard({required this.game, required this.isHost, required this.service});
  final GameModel game;
  final bool isHost;
  final GameService service;

  @override
  State<_RosterCard> createState() => _RosterCardState();
}

class _RosterCardState extends State<_RosterCard> {
  final _authService = AuthService();
  late Future<List<UserModel>> _players;

  @override
  void initState() {
    super.initState();
    _players = _authService.getUsersByIds(widget.game.playerIds);
  }

  @override
  void didUpdateWidget(covariant _RosterCard old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.game.playerIds, widget.game.playerIds)) {
      _players = _authService.getUsersByIds(widget.game.playerIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final needs = game.spotsOpen;
    // Spots the host reserved for friends joining off-app (filled beyond the
    // players actually in the app).
    final guests = (game.spotsFilled - game.playerIds.length).clamp(0, game.capacity);
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
          const SizedBox(height: 13),
          FutureBuilder<List<UserModel>>(
            future: _players,
            builder: (context, snap) {
              final byId = {for (final u in snap.data ?? const <UserModel>[]) u.uid: u};
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in game.playerIds)
                    _PlayerChip(
                      user: byId[id],
                      isHost: id == game.hostId,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerProfileScreen(
                            userId: id,
                            // Host can remove any joined player except themselves.
                            onRemove: (widget.isHost && id != game.hostId)
                                ? () => widget.service.removePlayer(gameId: game.id, hostId: game.hostId, userId: id)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  for (var i = 0; i < guests; i++) const _GuestChip(),
                  for (var i = 0; i < needs; i++) const _OpenSlotChip(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A joined player: avatar (photo or initials) + short name, with a Host badge
/// for the organiser. Falls back to a neutral chip while the name loads.
class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.user, required this.isHost, this.onTap});
  final UserModel? user;
  final bool isHost;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = user?.shortName ?? 'Player';
    final photo = user?.photoUrl;
    return Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        child: Container(
          padding: const EdgeInsets.fromLTRB(5, 5, 11, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rPill),
            border: Border.all(color: TUColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: TUColors.brandSoft,
                foregroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
                child: Text(
                  user?.initials ?? '·',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: TUColors.brand700),
                ),
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: TUColors.ink)),
              if (isHost) ...[
                const SizedBox(width: 7),
                const _Pill(label: 'Host', bg: TUColors.brand, fg: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A spot the host reserved for a friend joining off-app (no profile to show).
class _GuestChip extends StatelessWidget {
  const _GuestChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 11, 5),
      decoration: BoxDecoration(
        color: TUColors.surface2,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        border: Border.all(color: TUColors.line),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: TUColors.brandSoft,
            child: Icon(Icons.person_rounded, size: 15, color: TUColors.brand700),
          ),
          SizedBox(width: 8),
          Text('Guest', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: TUColors.ink)),
        ],
      ),
    );
  }
}

/// Dashed-look placeholder for an unfilled spot.
class _OpenSlotChip extends StatelessWidget {
  const _OpenSlotChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 11, 5),
      decoration: BoxDecoration(
        color: TUColors.surface,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        border: Border.all(color: TUColors.line2, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: TUColors.surface2,
            child: Icon(Icons.person_add_alt_1_rounded, size: 14, color: TUColors.ink3),
          ),
          SizedBox(width: 8),
          Text('Open', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: TUColors.ink3)),
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
  late final Future<UserModel> _requester = AuthService().getUserProfile(widget.request.userId);

  String get _subtitle => switch (widget.request.status) {
    JoinRequestStatus.pending => 'Wants to join',
    JoinRequestStatus.approved => 'Approved — waiting to confirm',
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

  void _openProfile() {
    final pending = widget.request.status == JoinRequestStatus.pending;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerProfileScreen(
          userId: widget.request.userId,
          onApprove: pending ? () => widget.service.approveRequest(gameId: widget.request.gameId, userId: widget.request.userId) : null,
          onDecline: pending ? () => widget.service.declineRequest(gameId: widget.request.gameId, userId: widget.request.userId) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TUColors.surface,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: _openProfile,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
      child: Row(
        children: [
          FutureBuilder<UserModel>(
            future: _requester,
            builder: (context, snap) {
              final photo = snap.data?.photoUrl;
              return CircleAvatar(
                radius: 20,
                backgroundColor: TUColors.brandSoft,
                foregroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
                child: Text(
                  snap.data?.initials ?? '·',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: TUColors.brand700),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<UserModel>(
                  future: _requester,
                  builder: (context, snap) => Text(
                    snap.data?.shortName ?? 'Player',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: TUColors.ink),
                  ),
                ),
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
            const _Pill(label: 'To confirm', bg: TUColors.brandSoft, fg: TUColors.brand700)
          else
            const _Pill(label: 'Declined', bg: Color(0xFFFBEEE9), fg: Color(0xFFB23B2E)),
        ],
      ),
        ),
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

/// Drives a non-member's path into a game: a primary Join (instant games) or
/// Request-to-join (approval games) action when they have no request yet, and
/// otherwise the live status of their request — including a Pay-to-confirm
/// action once the host has approved.
class _JoinSection extends StatefulWidget {
  const _JoinSection({required this.game, required this.userId, required this.service, required this.perPlayer});
  final GameModel game;
  final String userId;
  final GameService service;
  final int perPlayer;

  @override
  State<_JoinSection> createState() => _JoinSectionState();
}

class _JoinSectionState extends State<_JoinSection> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String success) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
    } catch (e, st) {
      _log.e('Join action failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Could not join: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await widget.service.confirmJoin(gameId: widget.game.id, userId: widget.userId);
      messenger.showSnackBar(const SnackBar(content: Text("You're in! Settle your share with the organiser.")));
    } catch (e, st) {
      _log.e('Confirm spot failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Could not confirm: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return StreamBuilder<JoinRequestModel?>(
      stream: widget.service.streamMyRequest(game.id, widget.userId),
      builder: (context, snap) {
        final r = snap.data;

        // No active request → show the primary entry action.
        if (r == null || r.status == JoinRequestStatus.confirmed) {
          if (game.status == GameStatus.private) {
            return const _Banner(
              icon: Icons.lock_outline_rounded,
              bg: TUColors.surface2,
              fg: TUColors.ink2,
              title: 'Not accepting players',
              sub: 'The host has set this game to private.',
            );
          }
          final full = game.spotsOpen <= 0 || game.status != GameStatus.open;
          if (full) {
            return const _Banner(
              icon: Icons.lock_clock_rounded,
              bg: TUColors.surface2,
              fg: TUColors.ink2,
              title: 'Game full',
              sub: 'This game already has a full team — check back if a spot reopens.',
            );
          }
          final approval = game.requiresApproval;
          return _PrimaryButton(
            label: approval ? 'Request to join' : 'Join game',
            icon: approval ? Icons.how_to_reg_rounded : Icons.add_rounded,
            busy: _busy,
            onTap: approval
                ? () => _run(() => widget.service.requestToJoin(gameId: game.id, userId: widget.userId), 'Request sent — the host will review it.')
                : () => _run(() => widget.service.joinGame(game.id, widget.userId), "You're in!"),
          );
        }

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
              sub: 'Confirm to lock your spot — your ${widget.perPlayer} ${game.currency} share is settled with the organiser (cash or transfer).',
              action: ('Confirm spot', _confirm),
            );
          case JoinRequestStatus.confirmed:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Full-width brand action button with a busy spinner, used for the primary
/// Join / Request-to-join action.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.icon, required this.busy, required this.onTap});
  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: busy ? null : onTap,
      icon: busy
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(icon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: TUColors.brand,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }
}

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

/// Host-only entry point to the edit sheet.
class _EditGameButton extends StatelessWidget {
  const _EditGameButton({required this.game, required this.service});
  final GameModel game;
  final GameService service;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => showAdaptiveSheet<void>(context, builder: (_) => _EditGameSheet(game: game, service: service)),
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('Edit game'),
      style: OutlinedButton.styleFrom(
        foregroundColor: TUColors.brand700,
        side: const BorderSide(color: TUColors.line2, width: 1.5),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Host edits team size, approval, and open/private state. Capacity is bounded
/// below by the players already in and above by the pitch's max players.
class _EditGameSheet extends StatefulWidget {
  const _EditGameSheet({required this.game, required this.service});
  final GameModel game;
  final GameService service;

  @override
  State<_EditGameSheet> createState() => _EditGameSheetState();
}

class _EditGameSheetState extends State<_EditGameSheet> {
  late bool _isOpen = widget.game.status != GameStatus.private;
  late bool _requiresApproval = widget.game.requiresApproval;
  late int _capacity = widget.game.capacity;
  late int _filled = widget.game.spotsFilled;
  late int _maxCapacity = widget.game.capacity;
  bool _saving = false;

  // Confirmed spots can't fall below the players actually joined in-app.
  int get _minFilled => widget.game.playerIds.isEmpty ? 1 : widget.game.playerIds.length;

  @override
  void initState() {
    super.initState();
    VenueService().getPitch(widget.game.venueId, widget.game.pitchId).then((p) {
      if (mounted) setState(() => _maxCapacity = p.maxPlayers < _capacity ? _capacity : p.maxPlayers);
    }).catchError((Object e, StackTrace st) {
      _log.w('Could not load pitch capacity', error: e, stackTrace: st);
      if (mounted) setState(() => _maxCapacity = _capacity > 30 ? _capacity : 30);
    });
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await widget.service.updateGame(
        gameId: widget.game.id,
        capacity: _capacity,
        spotsFilled: _filled,
        requiresApproval: _requiresApproval,
        isOpen: _isOpen,
      );
      messenger.showSnackBar(const SnackBar(content: Text('Game updated')));
      nav.pop();
    } catch (e, st) {
      _log.e('Game update failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Could not update game: $e')));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobileWidth(context);
    final perPlayer = (widget.game.pricePerHour / 100 / _capacity).round();
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mobile)
            Center(child: Container(margin: const EdgeInsets.only(top: 10, bottom: 2), width: 42, height: 5, decoration: BoxDecoration(color: TUColors.line2, borderRadius: BorderRadius.circular(TUColors.rPill)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 16, 12),
            child: Row(
              children: [
                const Expanded(child: Text('Edit game', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: TUColors.ink))),
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
                  // ── Team size + spots filled ──
                  Container(
                    decoration: BoxDecoration(color: TUColors.surface, borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
                    child: Column(
                      children: [
                        _StepperRow(
                          title: 'Team size',
                          sub: 'Total spots on the court',
                          value: _capacity,
                          onMinus: _capacity > _filled ? () => setState(() => _capacity--) : null,
                          onPlus: _capacity < _maxCapacity ? () => setState(() => _capacity++) : null,
                        ),
                        const Divider(height: 1, thickness: 1, color: TUColors.line),
                        _StepperRow(
                          title: 'Spots filled',
                          sub: 'Bump up for friends joining off-app',
                          value: _filled,
                          onMinus: _filled > _minFilled ? () => setState(() => _filled--) : null,
                          onPlus: _filled < _capacity ? () => setState(() => _filled++) : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _capacity - _filled > 0
                          ? 'Needs ${_capacity - _filled} more · $perPlayer ${widget.game.currency} per player'
                          : 'Team complete · $perPlayer ${widget.game.currency} per player',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: TUColors.ink3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Open to players ──
                  _ToggleRow(
                    title: 'Open to players',
                    sub: _isOpen ? 'Anyone can find and join this game.' : 'Private — closed to new players, your team stays.',
                    value: _isOpen,
                    onChanged: (v) => setState(() => _isOpen = v),
                  ),
                  const SizedBox(height: 12),
                  // ── Require approval ──
                  Opacity(
                    opacity: _isOpen ? 1 : 0.5,
                    child: _ToggleRow(
                      title: 'Approve who joins',
                      sub: 'Review each request before a player is added.',
                      value: _requiresApproval,
                      onChanged: _isOpen ? (v) => setState(() => _requiresApproval = v) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: TUColors.line))),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: TUColors.brand,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.title, required this.sub, required this.value, required this.onMinus, required this.onPlus});
  final String title;
  final String sub;
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
              ],
            ),
          ),
          _StepButton(icon: Icons.remove_rounded, onTap: onMinus),
          SizedBox(width: 40, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: TUColors.ink))),
          _StepButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? TUColors.brandSoft : TUColors.surface2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 20, color: enabled ? TUColors.brand700 : TUColors.ink3)),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.title, required this.sub, required this.value, required this.onChanged});
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
      decoration: BoxDecoration(color: TUColors.surface, borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3, height: 1.3)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
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
