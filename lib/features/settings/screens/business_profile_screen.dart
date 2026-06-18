import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/business_model.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/settings/screens/edit_business_screen.dart';
import 'package:teamup/shared/widgets/page_header.dart';

/// Owner-facing profile: the legal/contact identity of the business plus the
/// booking policies (auto-confirm, cancellation notice). Distinct from the
/// player profile, which is about the person.
class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key, required this.user, required this.businessId});

  final UserModel user;
  final String businessId;

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _auth = AuthService();
  final _log = Logger();

  BusinessModel? _business;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final b = await _auth.getBusiness(widget.businessId);
      if (mounted) {
        setState(() {
          _business = b;
          _error = null;
        });
      }
    } catch (e, st) {
      _log.e('Load business failed', error: e, stackTrace: st);
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _setAutoConfirm(bool v) async {
    final prev = _business!;
    setState(() => _business = prev.copyWith(autoConfirmBookings: v));
    try {
      await _auth.setAutoConfirmBookings(widget.businessId, v);
    } catch (e, st) {
      _log.e('Set auto-confirm failed', error: e, stackTrace: st);
      if (mounted) {
        setState(() => _business = prev);
        _snack('Could not update auto-confirm');
      }
    }
  }

  Future<void> _setNotice(int hours) async {
    final prev = _business!;
    setState(() => _business = prev.copyWith(cancellationNoticeHours: hours));
    try {
      await _auth.setCancellationNoticeHours(widget.businessId, hours);
    } catch (e, st) {
      _log.e('Set cancellation notice failed', error: e, stackTrace: st);
      if (mounted) {
        setState(() => _business = prev);
        _snack('Could not update cancellation policy');
      }
    }
  }

  Future<void> _openEdit() async {
    final b = _business;
    if (b == null) return;
    final updated = await Navigator.of(context).push<BusinessModel>(
      MaterialPageRoute(builder: (_) => EditBusinessScreen(business: b)),
    );
    if (updated != null && mounted) setState(() => _business = updated);
  }

  @override
  Widget build(BuildContext context) {
    final b = _business;
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
                  title: 'Business profile',
                  trailing: b == null ? null : _HeaderIconButton(icon: Icons.edit_outlined, onTap: _openEdit),
                ),
                Expanded(child: _body(b)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BusinessModel? b) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: TUColors.ink2)),
        ),
      );
    }
    if (b == null) return const Center(child: CircularProgressIndicator());

    final ownerName = '${widget.user.firstName} ${widget.user.lastName}'.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _Hero(name: b.name, ownerName: ownerName),
        const SizedBox(height: 20),
        const _SectionLabel('Business details'),
        const SizedBox(height: 10),
        _DetailsCard(business: b),
        const SizedBox(height: 22),
        const _SectionLabel('Booking policies'),
        const SizedBox(height: 10),
        _PoliciesCard(
          business: b,
          onAutoConfirm: _setAutoConfirm,
          onNotice: _setNotice,
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: _openEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit business details'),
          style: OutlinedButton.styleFrom(
            foregroundColor: TUColors.ink2,
            side: const BorderSide(color: TUColors.line),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rMd)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

// ─── Hero ───────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.name, required this.ownerName});
  final String name;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TUColors.surface,
        borderRadius: BorderRadius.circular(TUColors.rLg),
        border: Border.all(color: TUColors.line),
        boxShadow: TUColors.shSm,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [TUColors.brand, TUColors.brand900]),
              borderRadius: BorderRadius.circular(TUColors.rMd),
            ),
            child: const Icon(Icons.storefront_rounded, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: TUColors.ink)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(color: TUColors.brandSoft, borderRadius: BorderRadius.circular(TUColors.rPill)),
                      child: const Text('Business account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: TUColors.brand700)),
                    ),
                  ],
                ),
                if (ownerName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Managed by $ownerName', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Details card ───────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.business});
  final BusinessModel business;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _DetailRow(icon: Icons.receipt_long_outlined, label: 'VAT number', value: business.vatNumber),
      _DetailRow(icon: Icons.badge_outlined, label: 'Registration no.', value: business.registrationNumber),
      _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: business.phone),
      _DetailRow(icon: Icons.mail_outline_rounded, label: 'Email', value: business.email),
      _DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: business.address),
      _DetailRow(icon: Icons.language_rounded, label: 'Website', value: business.website),
    ];
    return Container(
      decoration: BoxDecoration(
        color: TUColors.surface,
        borderRadius: BorderRadius.circular(TUColors.rLg),
        border: Border.all(color: TUColors.line),
        boxShadow: TUColors.shSm,
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: TUColors.line),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final has = value != null && value!.trim().isNotEmpty;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: TUColors.ink3, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(
                  has ? value!.trim() : 'Not set',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: has ? TUColors.ink : TUColors.ink3, fontStyle: has ? FontStyle.normal : FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Policies card ──────────────────────────────────────────

class _PoliciesCard extends StatelessWidget {
  const _PoliciesCard({required this.business, required this.onAutoConfirm, required this.onNotice});
  final BusinessModel business;
  final ValueChanged<bool> onAutoConfirm;
  final ValueChanged<int> onNotice;

  static const _noticeOptions = [
    (0, 'Anytime'),
    (6, '6 hours'),
    (12, '12 hours'),
    (24, '24 hours'),
    (48, '48 hours'),
  ];

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
          // Auto-confirm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: TUColors.brandTint, borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.task_alt_rounded, size: 18, color: TUColors.brand700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Auto-confirm bookings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
                      const SizedBox(height: 2),
                      Text(
                        business.autoConfirmBookings ? 'Player bookings confirm automatically' : 'You review and confirm each booking',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(value: business.autoConfirmBookings, onChanged: onAutoConfirm),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: TUColors.line),
          // Cancellation notice
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: TUColors.brandTint, borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.event_busy_outlined, size: 18, color: TUColors.brand700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cancellation policy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: TUColors.ink)),
                          const SizedBox(height: 2),
                          Text(
                            business.cancellationNoticeHours <= 0
                                ? 'Players can cancel any time before start'
                                : 'Players must cancel at least ${business.cancellationNoticeHours}h before start',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (h, label) in _noticeOptions)
                      _NoticeChip(
                        label: label,
                        selected: business.cancellationNoticeHours == h,
                        onTap: () => onNotice(h),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeChip extends StatelessWidget {
  const _NoticeChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TUColors.brand : TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TUColors.rPill),
            border: Border.all(color: selected ? TUColors.brand : TUColors.line),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : TUColors.ink2),
          ),
        ),
      ),
    );
  }
}

// ─── Shared bits ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: TUColors.ink3));
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TUColors.rMd),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
          child: Icon(icon, size: 20, color: TUColors.ink2),
        ),
      ),
    );
  }
}
