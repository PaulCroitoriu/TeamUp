import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/payment_method.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/dashboard/shared.dart';

/// How many weeks ahead to materialise when the owner picks "until
/// cancelled" — a recurring series is stored as concrete bookings so
/// existing schedule queries work unchanged.
const _kRecurringWeeks = 52;

/// Opens the booking sheet from the AppBar "+ New booking" button.
Future<void> openManualBookFromAppBar(BuildContext context, {required DateTime selectedDay}) async {
  final businessId = context.read<AuthBloc>().state.maybeMap(authenticated: (s) => s.user.businessId, orElse: () => null);
  if (businessId == null) return;
  final venueService = VenueService();

  final venues = await venueService.streamBusinessVenues(businessId).first;
  if (venues.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a venue and pitches first')));
    return;
  }
  final venuesById = {for (final v in venues) v.id: v};
  final allPitches = await venueService.streamPitchesAcrossVenues().first;
  final pitches = allPitches.where((p) => venuesById.containsKey(p.venueId) && p.active).toList()
    ..sort((a, b) => a.sport.value - b.sport.value);
  if (pitches.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active pitches available')));
    return;
  }

  if (!context.mounted) return;
  await _showManualSheet(
    context,
    pitches: pitches,
    venuesById: venuesById,
    initialPitch: null,
    initialDay: selectedDay,
    initialHour: DateTime.now().hour,
  );
}

/// Opens the sheet from a free-cell tap in the timeline. Pitch + day +
/// hour are already known from the cell location.
Future<void> openManualBookForPitch(
  BuildContext context, {
  required PitchModel pitch,
  required VenueModel? venue,
  required DateTime day,
  required int hour,
}) async {
  if (venue == null) return;
  await _showManualSheet(
    context,
    pitches: [pitch],
    venuesById: {venue.id: venue},
    initialPitch: pitch,
    initialDay: day,
    initialHour: hour,
  );
}

Future<void> _showManualSheet(
  BuildContext context, {
  required List<PitchModel> pitches,
  required Map<String, VenueModel> venuesById,
  required PitchModel? initialPitch,
  required DateTime initialDay,
  required int initialHour,
}) async {
  final isMobile = MediaQuery.sizeOf(context).width < kMobileBreakpoint;
  final widget = _ManualBookSheet(
    pitches: pitches,
    venuesById: venuesById,
    initialPitch: initialPitch,
    initialDay: initialDay,
    initialHour: initialHour,
  );
  if (isMobile) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.92),
          child: widget,
        ),
      ),
    );
  } else {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 580, maxHeight: 820), child: widget),
      ),
    );
  }
}

class _ManualBookSheet extends StatefulWidget {
  const _ManualBookSheet({
    required this.pitches,
    required this.venuesById,
    required this.initialPitch,
    required this.initialDay,
    required this.initialHour,
  });

  final List<PitchModel> pitches;
  final Map<String, VenueModel> venuesById;
  final PitchModel? initialPitch;
  final DateTime initialDay;
  final int initialHour;

  @override
  State<_ManualBookSheet> createState() => _ManualBookSheetState();
}

enum _LookupState { idle, searching, matched, notFound }

class _ManualBookSheetState extends State<_ManualBookSheet> {
  late PitchModel _pitch = widget.initialPitch ?? widget.pitches.first;
  late DateTime _day = widget.initialDay;
  late int _hour = widget.initialHour;
  int _durationHours = 1;
  bool _saving = false;
  String? _error;

  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  UserModel? _matchedUser;
  _LookupState _lookup = _LookupState.idle;
  Timer? _phoneDebounce;

  bool _recurring = false;

  bool get _hasPitchPicker => widget.initialPitch == null;
  VenueModel? get _venue => widget.venuesById[_pitch.venueId];

  DateTime get _start => DateTime(_day.year, _day.month, _day.day, _hour);
  DateTime get _end => _start.add(Duration(hours: _durationHours));

  static const _dayNames = ['Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'];

  @override
  void dispose() {
    _phoneDebounce?.cancel();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    _phoneDebounce?.cancel();
    final v = value.trim();
    if (_matchedUser != null) {
      // The owner is editing — clear the previous match so they're
      // working off fresh state.
      setState(() {
        _matchedUser = null;
        _lookup = _LookupState.idle;
      });
    }
    if (v.length < 4) {
      if (_lookup != _LookupState.idle) setState(() => _lookup = _LookupState.idle);
      return;
    }
    setState(() => _lookup = _LookupState.searching);
    _phoneDebounce = Timer(const Duration(milliseconds: 400), () => _lookupPhone(v));
  }

  Future<void> _lookupPhone(String phone) async {
    try {
      final user = await AuthService().findUserByPhone(phone);
      if (!mounted) return;
      if (_phoneCtrl.text.trim() != phone) return; // stale
      setState(() {
        _matchedUser = user;
        _lookup = user == null ? _LookupState.notFound : _LookupState.matched;
        if (user != null) {
          _nameCtrl.text = '${user.firstName} ${user.lastName}';
          _emailCtrl.text = user.email;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _lookup = _LookupState.idle);
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _save() async {
    final phone = _phoneCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Customer name is required');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _error = 'Phone number is required');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'A valid email is required');
      return;
    }

    final uid = context.read<AuthBloc>().state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null);
    if (uid == null) {
      setState(() => _error = 'Not signed in');
      return;
    }
    final venue = _venue;
    if (venue == null) {
      setState(() => _error = 'Pitch venue not found');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final now = DateTime.now();
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    // Manual bookings are cash on premises → confirmed and paid on creation.
    BookingModel template({required DateTime start, required DateTime end}) => BookingModel(
      id: '',
      pitchId: _pitch.id,
      venueId: venue.id,
      businessId: venue.businessId,
      // The organizer is the customer the booking is for. When the phone
      // lookup matched an account, that account owns the booking; otherwise
      // (off-app customer) we fall back to the owner who entered it.
      bookerId: _matchedUser?.uid ?? uid,
      startTime: start,
      endTime: end,
      pricePaid: _pitch.pricePerHour * _durationHours,
      currency: _pitch.currency,
      status: BookingStatus.confirmed,
      paymentMethod: PaymentMethod.cash,
      customerName: name,
      customerPhone: phone,
      customerEmail: email,
      customerUserId: _matchedUser?.uid,
      notes: notes,
      confirmedAt: now,
      paidAt: now,
      createdAt: now,
    );

    try {
      final service = BookingService();
      if (_recurring) {
        final templates = <BookingModel>[
          for (var w = 0; w < _kRecurringWeeks; w++)
            template(
              start: _start.add(Duration(days: 7 * w)),
              end: _end.add(Duration(days: 7 * w)),
            ),
        ];
        final recurrenceId = 'rec_${now.microsecondsSinceEpoch}_$uid';
        await service.createRecurringBookings(templates, recurrenceId: recurrenceId);
      } else {
        await service.createBooking(template(start: _start, end: _end));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } on BookingConflictException catch (e) {
      setState(() {
        _error = e.message;
        _saving = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceAmount = ((_pitch.pricePerHour * _durationHours) / 100).toStringAsFixed(0);

    final venue = _venue;
    final win = openingWindow(venue, _day);
    final openH = win.closed ? 0 : win.openH;
    final closeH = win.closed ? kHourCount : win.closeH;

    return Material(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text('Manual booking', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                ),
                IconButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasPitchPicker) ...[
                    _sectionLabel(theme, colors, 'Pitch'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _pitch.id,
                      isExpanded: true,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                      items: [
                        for (final p in widget.pitches)
                          DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              widget.venuesById[p.venueId] != null
                                  ? '${p.name} · ${p.sport.label} · ${widget.venuesById[p.venueId]!.name}'
                                  : '${p.name} · ${p.sport.label}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (id) {
                        if (id == null) return;
                        final next = widget.pitches.firstWhere((p) => p.id == id);
                        setState(() => _pitch = next);
                      },
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: colors.primary.withAlpha(15), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_pitch.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          if (venue != null) ...[
                            const SizedBox(height: 2),
                            Text('${venue.name} • ${venue.city}', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(160))),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // ── Customer section ─────────────────────────────────
                  _sectionLabel(theme, colors, 'Customer'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneCtrl,
                    enabled: !_saving,
                    keyboardType: TextInputType.phone,
                    onChanged: _onPhoneChanged,
                    decoration: InputDecoration(
                      labelText: 'Phone number',
                      hintText: 'e.g. 0712 345 678',
                      prefixIcon: const Icon(Icons.phone_rounded, size: 18),
                      suffixIcon: _lookupSuffix(colors),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (_lookup != _LookupState.idle) ...[
                    const SizedBox(height: 6),
                    _LookupBanner(state: _lookup, matched: _matchedUser),
                  ],
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameCtrl,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailCtrl,
                    enabled: !_saving,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded, size: 18),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── When ─────────────────────────────────────────────
                  _sectionLabel(theme, colors, 'Date'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text('${two(_day.day)}.${two(_day.month)}.${_day.year}'),
                    style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft, minimumSize: const Size(double.infinity, 44)),
                  ),
                  const SizedBox(height: 18),
                  _sectionLabel(theme, colors, 'Time'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (var h = openH; h < closeH; h++)
                        _HourChip(label: '${two(h)}:00', selected: _hour == h, onTap: () => setState(() => _hour = h)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _sectionLabel(theme, colors, 'Duration'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final d in const [1, 2, 3])
                        _HourChip(label: '${d}h', selected: _durationHours == d, onTap: () => setState(() => _durationHours = d)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: colors.onSurface.withAlpha(8), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 16, color: colors.onSurface.withAlpha(150)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${two(_start.hour)}:00 – ${two(_end.hour)}:00',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '$priceAmount ${_pitch.currency}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Payment method ───────────────────────────────────
                  _sectionLabel(theme, colors, 'Payment method'),
                  const SizedBox(height: 8),
                  const _PaymentMethodPicker(),
                  const SizedBox(height: 18),

                  // ── Recurring ────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: colors.onSurface.withAlpha(8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: SwitchListTile.adaptive(
                      title: Row(
                        children: [
                          const Icon(Icons.repeat_rounded, size: 18),
                          const SizedBox(width: 8),
                          const Text('Repeat weekly'),
                        ],
                      ),
                      subtitle: Text(
                        _recurring
                            ? 'Every ${_dayNames[_day.weekday - 1]} at ${two(_hour)}:00, until cancelled'
                            : 'One-off booking',
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(150)),
                      ),
                      value: _recurring,
                      contentPadding: EdgeInsets.zero,
                      onChanged: _saving ? null : (v) => setState(() => _recurring = v),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _notesCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: colors.error.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        _error!,
                        style: TextStyle(color: colors.error, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_rounded),
                      label: Text(_saveButtonLabel()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _lookupSuffix(ColorScheme colors) {
    switch (_lookup) {
      case _LookupState.searching:
        return const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      case _LookupState.matched:
        return Icon(Icons.check_circle_rounded, color: colors.primary, size: 20);
      case _LookupState.notFound:
        return Icon(Icons.help_outline_rounded, color: colors.onSurface.withAlpha(160), size: 20);
      case _LookupState.idle:
        return null;
    }
  }

  Widget _sectionLabel(ThemeData theme, ColorScheme colors, String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: colors.onSurface.withAlpha(160),
        letterSpacing: 0.8,
        fontSize: 11,
      ),
    );
  }

  String _saveButtonLabel() => _recurring ? 'Save series · paid in cash' : 'Save · paid in cash';
}

class _LookupBanner extends StatelessWidget {
  const _LookupBanner({required this.state, required this.matched});

  final _LookupState state;
  final UserModel? matched;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    switch (state) {
      case _LookupState.searching:
        return _Banner(
          icon: Icons.search_rounded,
          color: colors.onSurface.withAlpha(160),
          bg: colors.onSurface.withAlpha(12),
          text: 'Looking up phone number…',
        );
      case _LookupState.matched:
        final user = matched;
        final label = user == null
            ? 'Matched a user'
            : 'Matched: ${user.firstName} ${user.lastName} · ${user.email}';
        return _Banner(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF1E7E3F),
          bg: const Color(0xFF1E7E3F).withAlpha(22),
          text: label,
        );
      case _LookupState.notFound:
        return _Banner(
          icon: Icons.info_outline_rounded,
          color: const Color(0xFFE6A100),
          bg: const Color(0xFFE6A100).withAlpha(22),
          text: 'No matching user — fill in the details below.',
        );
      case _LookupState.idle:
        return const SizedBox.shrink();
    }
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.color, required this.bg, required this.text});
  final IconData icon;
  final Color color;
  final Color bg;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodPicker extends StatelessWidget {
  const _PaymentMethodPicker();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _PaymentOption(
            label: 'Cash on premise',
            sub: 'Confirmed & paid on save',
            icon: Icons.payments_rounded,
            selected: true,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _PaymentOption(
            label: 'Send payment link',
            sub: 'Pay online — coming soon',
            icon: Icons.ios_share_rounded,
            selected: false,
            disabled: true,
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({required this.label, required this.sub, required this.icon, required this.selected, this.disabled = false});

  final String label;
  final String sub;
  final IconData icon;
  final bool selected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = colors.primary;
    final fg = disabled ? colors.onSurface.withAlpha(90) : (selected ? accent : colors.onSurface);

    return Opacity(
      opacity: disabled ? 0.7 : 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: disabled ? colors.onSurface.withAlpha(8) : (selected ? accent.withAlpha(20) : colors.surface),
          border: Border.all(color: selected ? accent : colors.onSurface.withAlpha(22), width: selected ? 1.4 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: disabled ? colors.onSurface.withAlpha(120) : (selected ? accent : colors.onSurface.withAlpha(180))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: fg),
                        ),
                      ),
                      if (disabled) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: colors.onSurface.withAlpha(18), borderRadius: BorderRadius.circular(6)),
                          child: Text('Soon', style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, fontWeight: FontWeight.w800, color: colors.onSurface.withAlpha(150))),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(140), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, size: 18, color: accent),
          ],
        ),
      ),
    );
  }
}

class _HourChip extends StatelessWidget {
  const _HourChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primary : colors.onSurface.withAlpha(10),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : colors.onSurface),
          ),
        ),
      ),
    );
  }
}
