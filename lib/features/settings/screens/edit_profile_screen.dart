import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/gender.dart';
import 'package:teamup/core/enums/skill_level.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/theme/sport_tile.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/auth/models/user_model.dart';

final _log = Logger();

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _lastName = TextEditingController(text: widget.user.lastName);
  late final _phone = TextEditingController(text: widget.user.phone ?? '');
  late final _bio = TextEditingController(text: widget.user.bio ?? '');

  late Gender? _gender = widget.user.gender;
  late DateTime? _birthDate = widget.user.birthDate;
  late final Map<Sport, SkillLevel> _levels = {...widget.user.levels};

  late final String? _photoUrl = widget.user.photoUrl;
  XFile? _newPhoto;
  bool _saving = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (picked != null) setState(() => _newPhoto = picked);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<String?> _uploadPhotoIfNeeded(String uid) async {
    if (_newPhoto == null) return _photoUrl;
    final ext = _newPhoto!.name.contains('.') ? _newPhoto!.name.split('.').last : 'jpg';
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref('users/$uid/avatar_$ts.$ext');
    if (kIsWeb) {
      await ref.putData(await _newPhoto!.readAsBytes());
    } else {
      await ref.putFile(File(_newPhoto!.path));
    }
    return ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final authBloc = context.read<AuthBloc>();
    setState(() => _saving = true);
    try {
      final url = await _uploadPhotoIfNeeded(widget.user.uid);
      final updated = await _authService.updateProfile(
        uid: widget.user.uid,
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        photoUrl: url,
        gender: _gender,
        birthDate: _birthDate,
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        levels: _levels,
      );
      authBloc.add(AuthEvent.profileUpdated(updated));
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
      nav.pop();
    } catch (e, st) {
      _log.e('Profile update failed', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text('Could not save profile: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    return Scaffold(
      backgroundColor: TUColors.bg,
      appBar: AppBar(
        backgroundColor: TUColors.bg,
        foregroundColor: TUColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4)),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20, vertical: 24),
              children: [
                Center(child: _PhotoPicker(photoUrl: _photoUrl, newPhoto: _newPhoto, initials: widget.user.initials, onTap: _pickPhoto)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _Field(label: 'First name', controller: _firstName, validator: _required)),
                    const SizedBox(width: 12),
                    Expanded(child: _Field(label: 'Last name', controller: _lastName, validator: _required)),
                  ],
                ),
                const SizedBox(height: 16),
                _Field(label: 'Phone', controller: _phone, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _Field(label: 'Bio', controller: _bio, maxLines: 3, hint: 'A line about how you play'),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _GenderField(value: _gender, onChanged: (g) => setState(() => _gender = g))),
                    const SizedBox(width: 12),
                    Expanded(child: _BirthDateField(value: _birthDate, onTap: _pickBirthDate)),
                  ],
                ),
                const SizedBox(height: 24),
                const _Label('Sports & level'),
                const SizedBox(height: 4),
                const Text('Add the sports you play and your level in each.', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: TUColors.ink3)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: TUColors.surface,
                    borderRadius: BorderRadius.circular(TUColors.rLg),
                    border: Border.all(color: TUColors.line),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < Sport.values.length; i++) ...[
                        if (i > 0) const Divider(height: 1, thickness: 1, color: TUColors.line),
                        _SportLevelEditRow(
                          sport: Sport.values[i],
                          level: _levels[Sport.values[i]],
                          onToggle: () => setState(() {
                            final s = Sport.values[i];
                            if (_levels.containsKey(s)) {
                              _levels.remove(s);
                            } else {
                              _levels[s] = SkillLevel.beginner;
                            }
                          }),
                          onLevelChanged: (lvl) => setState(() => _levels[Sport.values[i]] = lvl),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
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
      ),
    );
  }

  static String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photoUrl, required this.newPhoto, required this.initials, required this.onTap});
  final String? photoUrl;
  final XFile? newPhoto;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    ImageProvider? img;
    if (newPhoto != null) {
      img = kIsWeb ? NetworkImage(newPhoto!.path) : FileImage(File(newPhoto!.path)) as ImageProvider;
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      img = NetworkImage(photoUrl!);
    }
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: TUColors.brandSoft,
            foregroundImage: img,
            child: Text(initials, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: TUColors.brand700)),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: TUColors.brand, shape: BoxShape.circle, border: Border.all(color: TUColors.bg, width: 2)),
              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SportLevelEditRow extends StatelessWidget {
  const _SportLevelEditRow({required this.sport, required this.level, required this.onToggle, required this.onLevelChanged});
  final Sport sport;
  final SkillLevel? level;
  final VoidCallback onToggle;
  final ValueChanged<SkillLevel> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    final active = level != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: active ? sport.color : TUColors.surface2,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(child: SportGlyph(sport: sport, size: 19, color: active ? Colors.white : TUColors.ink3)),
                ),
                const SizedBox(width: 11),
                Text(sport.label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: TUColors.ink)),
              ],
            ),
          ),
          const Spacer(),
          if (active)
            DropdownButton<SkillLevel>(
              value: level,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(TUColors.rMd),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: TUColors.ink),
              items: [for (final l in SkillLevel.values) DropdownMenuItem(value: l, child: Text(l.label))],
              onChanged: (l) => l == null ? null : onLevelChanged(l),
            )
          else
            TextButton.icon(
              onPressed: onToggle,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(foregroundColor: TUColors.brand, textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
            ),
          if (active)
            IconButton(
              onPressed: onToggle,
              icon: const Icon(Icons.close_rounded, size: 18, color: TUColors.ink3),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.value, required this.onChanged});
  final Gender? value;
  final ValueChanged<Gender?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Gender'),
        const SizedBox(height: 8),
        DropdownButtonFormField<Gender?>(
          initialValue: value,
          isExpanded: true,
          decoration: _fieldDecoration(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: TUColors.ink3),
          items: [
            const DropdownMenuItem<Gender?>(value: null, child: Text('—')),
            for (final g in Gender.values) DropdownMenuItem(value: g, child: Text(g.label)),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({required this.value, required this.onTap});
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = value == null ? 'Add' : '${value!.day} ${_months[value!.month - 1]} ${value!.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Date of birth'),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TUColors.rMd),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: TUColors.surface,
              borderRadius: BorderRadius.circular(TUColors.rMd),
              border: Border.all(color: TUColors.line2, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, size: 18, color: TUColors.ink3),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: value == null ? TUColors.ink3 : TUColors.ink),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, this.validator, this.keyboardType, this.maxLines = 1, this.hint});
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: TUColors.ink),
          decoration: _fieldDecoration(hint: hint),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: TUColors.ink));
  }
}

InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
      isDense: true,
      filled: true,
      fillColor: TUColors.surface,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: TUColors.ink3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TUColors.rMd),
        borderSide: const BorderSide(color: TUColors.line2, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TUColors.rMd),
        borderSide: const BorderSide(color: TUColors.brand, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TUColors.rMd),
        borderSide: const BorderSide(color: Color(0xFFB23B2E), width: 1.5),
      ),
    );
