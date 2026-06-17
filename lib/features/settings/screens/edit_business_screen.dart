import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/business_model.dart';
import 'package:teamup/shared/widgets/page_header.dart';

/// Edit the business identity (name + legal/contact details). Booking policies
/// are managed inline on the profile, not here.
class EditBusinessScreen extends StatefulWidget {
  const EditBusinessScreen({super.key, required this.business});
  final BusinessModel business;

  @override
  State<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  final _auth = AuthService();
  final _log = Logger();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name = TextEditingController(text: widget.business.name);
  late final TextEditingController _phone = TextEditingController(text: widget.business.phone ?? '');
  late final TextEditingController _email = TextEditingController(text: widget.business.email ?? '');
  late final TextEditingController _address = TextEditingController(text: widget.business.address ?? '');
  late final TextEditingController _website = TextEditingController(text: widget.business.website ?? '');
  late final TextEditingController _vat = TextEditingController(text: widget.business.vatNumber ?? '');
  late final TextEditingController _reg = TextEditingController(text: widget.business.registrationNumber ?? '');

  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _address, _website, _vat, _reg]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _orNull(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await _auth.updateBusiness(
        id: widget.business.id,
        name: _name.text.trim(),
        phone: _orNull(_phone),
        email: _orNull(_email),
        address: _orNull(_address),
        website: _orNull(_website),
        vatNumber: _orNull(_vat),
        registrationNumber: _orNull(_reg),
      );
      navigator.pop(updated);
    } catch (e, st) {
      _log.e('Update business failed', error: e, stackTrace: st);
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const PageHeader(leading: HeaderBackButton(), title: 'Edit business'),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        const _GroupLabel('Identity'),
                        const SizedBox(height: 10),
                        _Field(controller: _name, label: 'Business name', icon: Icons.storefront_rounded, validator: (v) => (v == null || v.trim().isEmpty) ? 'Business name is required' : null, textInputAction: TextInputAction.next),
                        const SizedBox(height: 12),
                        _Field(controller: _vat, label: 'VAT number', icon: Icons.receipt_long_outlined, textInputAction: TextInputAction.next),
                        const SizedBox(height: 12),
                        _Field(controller: _reg, label: 'Registration no.', icon: Icons.badge_outlined, textInputAction: TextInputAction.next),
                        const SizedBox(height: 22),
                        const _GroupLabel('Contact'),
                        const SizedBox(height: 10),
                        _Field(controller: _phone, label: 'Phone', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next),
                        const SizedBox(height: 12),
                        _Field(controller: _email, label: 'Email', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return null;
                          return t.contains('@') ? null : 'Enter a valid email';
                        }),
                        const SizedBox(height: 12),
                        _Field(controller: _address, label: 'Address', icon: Icons.location_on_outlined, textInputAction: TextInputAction.next),
                        const SizedBox(height: 12),
                        _Field(controller: _website, label: 'Website', icon: Icons.language_rounded, keyboardType: TextInputType.url, textInputAction: TextInputAction.done),
                        const SizedBox(height: 24),
                        FilledButton(
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
                      ],
                    ),
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

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: TUColors.ink3));
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(fontSize: 15, color: TUColors.ink, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: TUColors.ink3, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, size: 20, color: TUColors.ink3),
        filled: true,
        fillColor: TUColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(TUColors.rMd), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TUColors.rMd), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TUColors.rMd), borderSide: const BorderSide(color: TUColors.brand, width: 1.4)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TUColors.rMd), borderSide: const BorderSide(color: Color(0xFFB23B2E), width: 1.4)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TUColors.rMd), borderSide: const BorderSide(color: Color(0xFFB23B2E), width: 1.4)),
      ),
    );
  }
}
