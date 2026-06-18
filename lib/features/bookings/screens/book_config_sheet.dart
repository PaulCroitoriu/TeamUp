import 'package:flutter/material.dart';
import 'package:teamup/core/enums/payment_method.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/games/models/game_model.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/shared/widgets/adaptive_sheet.dart';

/// Result of configuring a booking in [BookConfigSheet].
class BookConfig {
  const BookConfig({
    required this.open,
    required this.players,
    required this.method,
    required this.youPay,
    this.gameSize = 0,
    this.confirmed = 1,
    this.requiresApproval = false,
    this.recurring = false,
  });

  /// Open game (leave spots for others) vs private (your group only).
  final bool open;

  /// Open: spots still needed (game size minus the host). Private: group size.
  final int players;

  /// Open game only — the total number of players for this game (the chosen
  /// team size, which can be smaller than the court's max).
  final int gameSize;

  /// Open game only — how many are already confirmed (the host's group),
  /// i.e. the game's initial spotsFilled.
  final int confirmed;
  final PaymentMethod method;

  /// Amount this user pays, in whole currency units (the full court for the
  /// organiser; a per-player share is only shown for info).
  final int youPay;

  /// Open game only — host approves each joiner vs anyone can join.
  final bool requiresApproval;

  /// Private only — repeat this booking weekly (same day & time).
  final bool recurring;
}

class _PayMethod {
  const _PayMethod(this.id, this.label, this.sub, this.icon, this.method);
  final String id;
  final String label;
  final String sub;
  final IconData icon;
  final PaymentMethod method;
}

// How the organiser settles the court with the venue. The per-player split is
// shown for info only — the organiser collects from the team (cash/transfer).
const _payMethods = [
  _PayMethod(
    'cash',
    'Cash on premises',
    'Pay the venue on arrival',
    Icons.payments_outlined,
    PaymentMethod.cash,
  ),
  _PayMethod(
    'transfer',
    'Bank transfer',
    'Pay the venue by transfer',
    Icons.account_balance_outlined,
    PaymentMethod.transfer,
  ),
  _PayMethod(
    'card',
    'Online by card',
    'Pay online by card',
    Icons.credit_card_rounded,
    PaymentMethod.card,
  ),
];

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
String _fmt(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Configure & confirm a booking — game type, players, and payment — ending in
/// a confirmation receipt. Shown via [showAdaptiveSheet] (dialog on desktop,
/// bottom sheet on mobile). [onSubmit] creates the booking and returns its id
/// (or null on failure); the sheet pops `true` once the user finishes.
class BookConfigSheet extends StatefulWidget {
  const BookConfigSheet({
    super.key,
    required this.venue,
    required this.pitch,
    required this.slotStart,
    required this.slotEnd,
    required this.day,
    required this.onSubmit,
    this.joinGame,
    this.payOnly = false,
  });

  final VenueModel venue;
  final PitchModel pitch;
  final DateTime slotStart;
  final DateTime slotEnd;
  final DateTime day;
  final Future<String?> Function(BookConfig cfg) onSubmit;

  /// When set, the sheet is in *join* mode for this existing open game.
  final GameModel? joinGame;

  /// Pay-after-approval mode: the request is already approved; just collect
  /// payment and confirm the spot.
  final bool payOnly;

  @override
  State<BookConfigSheet> createState() => _BookConfigSheetState();
}

class _BookConfigSheetState extends State<BookConfigSheet> {
  bool _open = false; // private by default
  late int _bring = 1; // private group size
  // Total players for an open game (defaults to the court's full size). The
  // host can shrink it, e.g. a 4-player padel court played 1v1.
  late int _gameSize = widget.pitch.maxPlayers;
  bool _requiresApproval = false; // open-game create: require host approval
  bool _recurring = false; // private booking: repeat weekly
  String _methodId = 'cash';
  bool _done = false;
  bool _submitting = false;

  bool get _isJoin => widget.joinGame != null;
  // Approval game, request not yet approved → request (no payment) flow.
  bool get _requestMode =>
      _isJoin &&
      (widget.joinGame?.requiresApproval ?? false) &&
      !widget.payOnly;
  int get _cap {
    if (widget.joinGame != null) return widget.joinGame!.capacity;
    if (_open) return _gameSize;
    return widget.pitch.maxPlayers;
  }

  int get _total =>
      ((widget.joinGame?.pricePerHour ?? widget.pitch.pricePerHour) / 100)
          .round();

  // How many ways the court is split, for the per-player figure shown as info.
  int get _shareCount {
    if (_isJoin) return _cap; // game capacity
    if (_open) return _gameSize; // open-game total team
    return _bring; // private group shares the court
  }

  int get _perShare => _shareCount <= 0 ? _total : (_total / _shareCount).round();

  // The organiser settles the full court; a joiner just sees their share.
  int get _youPay => _isJoin ? _perShare : _total;

  String get _cur => widget.pitch.currency;
  _PayMethod get _method => _payMethods.firstWhere((m) => m.id == _methodId);

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    final id = await widget.onSubmit(
      BookConfig(
        open: _open,
        players: _open ? (_gameSize - _bring) : _bring,
        gameSize: _open ? _gameSize : widget.pitch.maxPlayers,
        confirmed: _open ? _bring : 1,
        method: _method.method,
        youPay: _youPay,
        requiresApproval: _requiresApproval,
        recurring: _recurring && !_open,
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (id != null) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobileWidth(context);
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mobile)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 2),
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: TUColors.line2,
                    borderRadius: BorderRadius.circular(TUColors.rPill),
                  ),
                ),
              ),
            if (_done)
              ..._doneStage(context)
            else if (_isJoin)
              ..._joinStage(context)
            else
              ..._configStage(context),
          ],
        ),
      ),
    );
  }

  // ─── Confirmation receipt ───────────────────────────────────
  List<Widget> _doneStage(BuildContext context) {
    final dow = _weekdays[widget.day.weekday - 1];
    return [
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: TUColors.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 34,
                  color: TUColors.brand700,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _requestMode
                    ? 'Request sent'
                    : _isJoin
                    ? "You're in!"
                    : _open
                    ? 'Open game created'
                    : 'Booking confirmed',
                style: const TextStyle(
                  fontFamily: null,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: TUColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.venue.name} · ${widget.pitch.sport.label}\n$dow ${widget.day.day} · ${_fmt(widget.slotStart)}–${_fmt(widget.slotEnd)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TUColors.ink2,
                  height: 1.5,
                ),
              ),
              if (_requestMode) ...[
                const SizedBox(height: 10),
                const Text(
                  'The host will review your request — you’ll be notified. Your share is only charged once approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: TUColors.ink3,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: TUColors.surface2,
                  borderRadius: BorderRadius.circular(TUColors.rMd),
                  border: Border.all(color: TUColors.line),
                ),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  children: [
                    if (_isJoin) ...[
                      _receiptRow('Your share', '$_perShare $_cur', strong: true),
                      const SizedBox(height: 8),
                      _receiptRow('How to pay', 'Cash or transfer to the organiser'),
                    ] else ...[
                      _receiptRow('Court total', '$_total $_cur', strong: true),
                      const SizedBox(height: 8),
                      _receiptRow('Paying by', _method.label),
                      const SizedBox(height: 8),
                      _receiptRow('Per player', '$_perShare $_cur'),
                      if (_open) ...[
                        const SizedBox(height: 8),
                        _receiptRow(
                          'Looking for',
                          '${_gameSize - _bring} ${_gameSize - _bring == 1 ? 'player' : 'players'}',
                        ),
                      ],
                      if (_recurring && !_open) ...[
                        const SizedBox(height: 8),
                        _receiptRow('Repeats', 'Weekly · same day & time'),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: _PrimaryButton(
          label: _isJoin
              ? 'Done'
              : _open
              ? 'View open game'
              : 'Go to my games',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
    ];
  }

  Widget _receiptRow(String label, String value, {bool strong = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: strong ? 15 : 12.5,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              color: strong ? TUColors.ink : TUColors.ink3,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: strong ? 17 : 12.5,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            color: strong ? TUColors.brand700 : TUColors.ink3,
          ),
        ),
      ],
    );
  }

  // ─── Config form ────────────────────────────────────────────
  List<Widget> _configStage(BuildContext context) {
    final dow = _weekdays[widget.day.weekday - 1];
    return [
      // header
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confirm booking',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: TUColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${widget.venue.name} · $dow ${widget.day.day} · ${_fmt(widget.slotStart)}–${_fmt(widget.slotEnd)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TUColors.ink2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CloseButton(onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
      // body
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Label('Game type'),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: _SegCard(
                      icon: Icons.group_outlined,
                      title: 'Private',
                      sub: 'Just my group — court fully booked',
                      selected: !_open,
                      onTap: () => setState(() => _open = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SegCard(
                      icon: Icons.bolt_rounded,
                      title: 'Open game',
                      sub: 'Let others join to fill the team',
                      selected: _open,
                      onTap: () => setState(() => _open = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // players
              if (_open) ...[
                const _Label('Game size', hint: 'total players'),
                const SizedBox(height: 11),
                _ToggleRow(
                  title: '$_gameSize ${_gameSize == 1 ? 'player' : 'players'}',
                  sub:
                      'Total on the court · up to ${widget.pitch.maxPlayers} fit',
                  trailing: _Stepper(
                    value: _gameSize,
                    min: 2,
                    max: widget.pitch.maxPlayers,
                    onChange: (v) => setState(() {
                      _gameSize = v;
                      if (_bring > _gameSize - 1) _bring = _gameSize - 1;
                    }),
                  ),
                ),
                const SizedBox(height: 14),
                const _Label('Your group', hint: 'how many are you already'),
                const SizedBox(height: 11),
                _ToggleRow(
                  title: '$_bring ${_bring == 1 ? 'player' : 'players'}',
                  sub: 'Leaves ${_gameSize - _bring} open to join',
                  trailing: _Stepper(
                    value: _bring,
                    min: 1,
                    max: _gameSize - 1,
                    onChange: (v) => setState(() => _bring = v),
                  ),
                ),
                const SizedBox(height: 12),
                _CapDots(filled: _bring, total: _gameSize),
                const SizedBox(height: 12),
                _ToggleRow(
                  title: 'Approve who joins',
                  sub: _requiresApproval
                      ? 'Players request — you approve each one'
                      : 'Anyone can join instantly',
                  trailing: _MiniSwitch(
                    value: _requiresApproval,
                    onChanged: (v) => setState(() => _requiresApproval = v),
                  ),
                ),
              ] else ...[
                const _Label('Your group', hint: 'how many are playing'),
                const SizedBox(height: 11),
                _ToggleRow(
                  title: '$_bring ${_bring == 1 ? 'player' : 'players'}',
                  sub: 'Up to $_cap fit on this court',
                  trailing: _Stepper(
                    value: _bring,
                    min: 1,
                    max: _cap,
                    onChange: (v) => setState(() => _bring = v),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // payment — organiser settles the whole court; per-player is info
              const _Label('Payment', hint: 'you settle the court'),
              const SizedBox(height: 11),
              _ShareCard(
                title: 'Per player',
                amount: '$_perShare $_cur',
                sub: _shareCount > 1
                    ? 'Court total $_total $_cur · split $_shareCount ways — you collect from the team'
                    : 'You pay the full court',
              ),
              const SizedBox(height: 12),
              for (final m in _payMethods) ...[
                _PayOption(
                  method: m,
                  selected: _methodId == m.id,
                  onTap: () => setState(() => _methodId = m.id),
                ),
                if (m != _payMethods.last) const SizedBox(height: 9),
              ],
              if (!_open) ...[
                const SizedBox(height: 20),
                const _Label('Repeat'),
                const SizedBox(height: 11),
                _ToggleRow(
                  title: 'Repeats weekly',
                  sub: _recurring
                      ? 'Books the same slot every week'
                      : 'One-off booking',
                  trailing: _MiniSwitch(
                    value: _recurring,
                    onChanged: (v) => setState(() => _recurring = v),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      // footer
      Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: TUColors.line)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COURT TOTAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: TUColors.ink3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text.rich(
                    TextSpan(
                      text: '$_total $_cur',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: TUColors.brand700,
                      ),
                      children: [
                        TextSpan(
                          text: ' · $_perShare/player',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: TUColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _PrimaryButton(
              label: _open ? 'Create open game' : 'Confirm booking',
              busy: _submitting,
              compact: true,
              onPressed: _submitting ? null : _confirm,
            ),
          ],
        ),
      ),
    ];
  }

  // ─── Join an existing open game ────────────────────────────
  List<Widget> _joinStage(BuildContext context) {
    final g = widget.joinGame!;
    final dow = _weekdays[widget.day.weekday - 1];
    final needs = g.spotsOpen;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.payOnly
                        ? 'Confirm your spot'
                        : _requestMode
                        ? 'Request to join'
                        : 'Join this game',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: TUColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${widget.venue.name} · $dow ${widget.day.day} · ${_fmt(widget.slotStart)}–${_fmt(widget.slotEnd)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TUColors.ink2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CloseButton(onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Label('The team'),
              const SizedBox(height: 11),
              _ToggleRow(
                title: '${g.spotsFilled}/$_cap players in',
                sub: needs == 1
                    ? 'Needs 1 more to fill the team'
                    : 'Needs $needs more to fill the team',
                trailing: const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              _CapDots(filled: g.spotsFilled, total: _cap),
              const SizedBox(height: 20),
              if (_requestMode) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TUColors.brandTint,
                    borderRadius: BorderRadius.circular(TUColors.rMd),
                    border: Border.all(color: TUColors.brandSoft),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: TUColors.brand700,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The host approves who joins. Once you\u2019re in, settle your $_perShare $_cur share with the organiser \u2014 cash or transfer.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: TUColors.ink2,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const _Label('Your share'),
                const SizedBox(height: 11),
                _ShareCard(
                  title: 'Your share',
                  amount: '$_perShare $_cur',
                  sub: 'Settle with the organiser — cash or transfer. No payment in the app.',
                ),
              ],
            ],
          ),
        ),
      ),
      Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: TUColors.line)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR SHARE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: TUColors.ink3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text.rich(
                    TextSpan(
                      text: '$_perShare $_cur',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: TUColors.brand700,
                      ),
                      children: [
                        TextSpan(
                          text: ' / $_total court',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: TUColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _PrimaryButton(
              label: widget.payOnly
                  ? 'Confirm spot'
                  : _requestMode
                  ? 'Request to join'
                  : 'Join game',
              busy: _submitting,
              compact: true,
              onPressed: _submitting ? null : _confirm,
            ),
          ],
        ),
      ),
    ];
  }
}

// ─── Pieces ───────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.label, {this.hint});
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: TUColors.ink,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(width: 8),
          Text(
            hint!,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: TUColors.ink3,
            ),
          ),
        ],
      ],
    );
  }
}

class _SegCard extends StatelessWidget {
  const _SegCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String sub;
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
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rMd),
            border: Border.all(
              color: selected ? TUColors.brand : TUColors.line2,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? TUColors.brand : TUColors.surface2,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: selected ? TUColors.brand : TUColors.line,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected ? Colors.white : TUColors.ink2,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: TUColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: TUColors.ink2,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChange,
  });
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TUColors.surface,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        border: Border.all(color: TUColors.line2, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn('–', value > min ? () => onChange(value - 1) : null),
          Container(
            constraints: const BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: TUColors.ink,
              ),
            ),
          ),
          _stepBtn('+', value < max ? () => onChange(value + 1) : null),
        ],
      ),
    );
  }

  Widget _stepBtn(String label, VoidCallback? onTap) {
    return Material(
      color: TUColors.surface2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: onTap == null ? TUColors.ink3 : TUColors.brand700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CapDots extends StatelessWidget {
  const _CapDots({required this.filled, required this.total});
  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    final show = total.clamp(0, 12);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < show; i++)
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: i < filled ? TUColors.brand : TUColors.surface2,
              borderRadius: BorderRadius.circular(8),
              border: i < filled
                  ? null
                  : Border.all(
                      color: TUColors.line2,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
            ),
          ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.sub,
    required this.trailing,
  });
  final String title;
  final String sub;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TUColors.surface2,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        border: Border.all(color: TUColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: TUColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: TUColors.ink3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          trailing,
        ],
      ),
    );
  }
}

/// Info card showing a headline amount (per-player or your share) with context.
/// No payment is taken here — it tells the player what to settle and with whom.
class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.title, required this.amount, required this.sub});
  final String title;
  final String amount;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: TUColors.brandTint,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        border: Border.all(color: TUColors.brandSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink2, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            amount,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: TUColors.brand700, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  const _PayOption({
    required this.method,
    required this.selected,
    required this.onTap,
  });
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rMd),
            border: Border.all(
              color: selected ? TUColors.brand : TUColors.line2,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : TUColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? TUColors.brandSoft : TUColors.line,
                  ),
                ),
                child: Icon(
                  method.icon,
                  size: 20,
                  color: selected ? TUColors.brand700 : TUColors.ink,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.label,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: TUColors.ink,
                      ),
                    ),
                    Text(
                      method.sub,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: TUColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? TUColors.brand : Colors.transparent,
                  border: Border.all(
                    color: selected ? TUColors.brand : TUColors.line2,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Center(
                        child: SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 50,
        height: 29,
        decoration: BoxDecoration(
          color: value ? TUColors.brand : TUColors.line2,
          borderRadius: BorderRadius.circular(99),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              width: 23,
              height: 23,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(Icons.close_rounded, size: 18, color: TUColors.ink2),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.busy = false,
    this.compact = false,
  });
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: TUColors.brand,
        foregroundColor: Colors.white,
        minimumSize: Size(compact ? 0 : double.infinity, 52),
        padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TUColors.rMd),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 18),
                ],
              ],
            ),
    );
  }
}
