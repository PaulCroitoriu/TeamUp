import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:logger/logger.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';

final _log = Logger();

class AddEditPitchDialog extends StatefulWidget {
  const AddEditPitchDialog({super.key, required this.venueId, this.pitch});

  final String venueId;
  final PitchModel? pitch;

  static Future<void> show(BuildContext context, {required String venueId, PitchModel? pitch}) {
    return showDialog<void>(
      context: context,
      builder: (_) => AddEditPitchDialog(venueId: venueId, pitch: pitch),
    );
  }

  @override
  State<AddEditPitchDialog> createState() => _AddEditPitchDialogState();
}

class _AddEditPitchDialogState extends State<AddEditPitchDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _maxPlayersCtrl;
  late final TextEditingController _priceCtrl;
  late Sport _sport;
  late String? _surface;
  late bool _indoor;
  late bool _active;

  /// Already-uploaded URLs (from existing pitch).
  late List<String> _existingUrls;

  /// Newly picked local files to upload on submit.
  final List<XFile> _newPhotos = [];

  bool _uploading = false;

  bool get _isEditing => widget.pitch != null;
  int get _totalPhotos => _existingUrls.length + _newPhotos.length;
  static const _maxPhotos = 3;

  final _venueService = VenueService();
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  static const _surfaces = ['Grass', 'Artificial turf', 'Clay', 'Hard court', 'Parquet', 'Concrete'];

  @override
  void initState() {
    super.initState();
    final p = widget.pitch;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _maxPlayersCtrl = TextEditingController(text: p?.maxPlayers.toString() ?? '');
    _priceCtrl = TextEditingController(text: p != null ? (p.pricePerHour / 100).toStringAsFixed(0) : '');
    _sport = p?.sport ?? Sport.football;
    _surface = p?.surface;
    _indoor = p?.indoor ?? false;
    _active = p?.active ?? true;
    _existingUrls = List<String>.from(p?.imageUrls ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _maxPlayersCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── Photo helpers ──────────────────────────────────────────

  Future<void> _pickPhotos() async {
    final remaining = _maxPhotos - _totalPhotos;
    if (remaining <= 0) return;
    _log.d('Opening image picker (remaining slots: $remaining)');
    final picked = await _picker.pickMultiImage(maxWidth: 1200, imageQuality: 80);
    if (picked.isNotEmpty) {
      final toAdd = picked.take(remaining).toList();
      _log.d('Picked ${toAdd.length} image(s): ${toAdd.map((f) => f.name).join(', ')}');
      setState(() => _newPhotos.addAll(toAdd));
    } else {
      _log.d('Image picker cancelled');
    }
  }

  void _removeExisting(int index) {
    setState(() => _existingUrls.removeAt(index));
  }

  void _removeNew(int index) {
    setState(() => _newPhotos.removeAt(index));
  }

  Future<List<String>> _uploadNewPhotos(String pitchId) async {
    _log.d('Uploading ${_newPhotos.length} photo(s) for pitch $pitchId');
    final urls = <String>[];
    for (final file in _newPhotos) {
      final ext = file.name.split('.').last;
      final ts = DateTime.now().millisecondsSinceEpoch;
      final path = 'pitches/$pitchId/${ts}_${urls.length}.$ext';
      final ref = _storage.ref(path);
      _log.d('Uploading ${file.name} → $path');
      final sw = Stopwatch()..start();
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        _log.d('Read ${bytes.length} bytes from file');
        await ref.putData(bytes);
      } else {
        await ref.putFile(File(file.path));
      }
      _log.d('Upload done in ${sw.elapsedMilliseconds}ms');
      final url = await ref.getDownloadURL();
      _log.d('Download URL obtained: ${url.substring(0, 80)}…');
      urls.add(url);
    }
    return urls;
  }

  // ── Submit ────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uploading = true);
    _log.d('Submit started (editing=$_isEditing)');

    try {
      var pitchId = widget.pitch?.id ?? '';

      if (!_isEditing) {
        final created = await _venueService.createPitch(
          widget.venueId,
          PitchModel(
            id: '',
            venueId: widget.venueId,
            name: _nameCtrl.text.trim(),
            sport: _sport,
            maxPlayers: int.parse(_maxPlayersCtrl.text.trim()),
            pricePerHour: int.parse(_priceCtrl.text.trim()) * 100,
            surface: _surface,
            indoor: _indoor,
            active: _active,
            imageUrls: [],
            createdAt: DateTime.now(),
          ),
        );
        pitchId = created.id;
      }

      // Upload new photos.
      final uploadedUrls = await _uploadNewPhotos(pitchId);
      final allUrls = [..._existingUrls, ...uploadedUrls];

      // Update with final image URLs.
      await _venueService.updatePitch(
        widget.venueId,
        PitchModel(
          id: pitchId,
          venueId: widget.venueId,
          name: _nameCtrl.text.trim(),
          sport: _sport,
          maxPlayers: int.parse(_maxPlayersCtrl.text.trim()),
          pricePerHour: int.parse(_priceCtrl.text.trim()) * 100,
          surface: _surface,
          indoor: _indoor,
          active: _active,
          imageUrls: allUrls,
          createdAt: widget.pitch?.createdAt ?? DateTime.now(),
        ),
      );

      _log.i('Pitch saved successfully (id=$pitchId, urls=$allUrls)');
      if (mounted) Navigator.of(context).pop();
    } catch (e, stack) {
      _log.e('Submit failed', error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Title ──
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 28, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_isEditing ? 'Edit Pitch' : 'New Pitch', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  IconButton(onPressed: _uploading ? null : () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Form ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(40, 28, 40, 40),
                child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Photos ──
                    Text('Photos', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('$_totalPhotos / $_maxPhotos', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(100))),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Existing remote images
                          for (var i = 0; i < _existingUrls.length; i++)
                            _PhotoThumb(
                              key: ValueKey('existing_$i'),
                              child: Image.network(_existingUrls[i], fit: BoxFit.cover),
                              onRemove: () => _removeExisting(i),
                            ),
                          // Newly picked local files
                          for (var i = 0; i < _newPhotos.length; i++)
                            _PhotoThumb(
                              key: ValueKey('new_$i'),
                              child: kIsWeb
                                  ? Image.network(_newPhotos[i].path, fit: BoxFit.cover)
                                  : Image.file(File(_newPhotos[i].path), fit: BoxFit.cover),
                              onRemove: () => _removeNew(i),
                            ),
                          // Add button
                          if (_totalPhotos < _maxPhotos)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: _pickPhotos,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colors.onSurface.withAlpha(30)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 28, color: colors.onSurface.withAlpha(80)),
                                      const SizedBox(height: 4),
                                      Text('Add photo', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(80))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Name ──
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(hintText: 'Pitch name (e.g. "Pitch A")', prefixIcon: Icon(Icons.label_outline_rounded)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Sport ──
                    DropdownButtonFormField<Sport>(
                      initialValue: _sport,
                      decoration: const InputDecoration(hintText: 'Sport', prefixIcon: Icon(Icons.sports_rounded)),
                      items: Sport.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _sport = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Max players + Price row ──
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _maxPlayersCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(hintText: 'Max players', prefixIcon: Icon(Icons.group_outlined)),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              final n = int.tryParse(v);
                              if (n == null || n < 1) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(hintText: 'Price / hour', prefixIcon: Icon(Icons.payments_outlined), suffixText: 'RON'),
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

                    // ── Surface ──
                    DropdownButtonFormField<String>(
                      initialValue: _surface,
                      decoration: const InputDecoration(hintText: 'Surface (optional)', prefixIcon: Icon(Icons.grass_outlined)),
                      items: _surfaces.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _surface = v),
                    ),
                    const SizedBox(height: 16),

                    // ── Indoor toggle ──
                    SwitchListTile.adaptive(
                      title: const Text('Indoor / covered'),
                      value: _indoor,
                      activeTrackColor: colors.secondary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onChanged: (v) => setState(() => _indoor = v),
                    ),
                    const SizedBox(height: 4),

                    // ── Active toggle ──
                    SwitchListTile.adaptive(
                      title: const Text('Active'),
                      subtitle: Text(
                        _active ? 'Visible to players' : 'Hidden from players',
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(100)),
                      ),
                      value: _active,
                      activeTrackColor: colors.secondary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onChanged: (v) => setState(() => _active = v),
                    ),
                    const SizedBox(height: 32),

                    // ── Submit ──
                    ElevatedButton(
                      onPressed: _uploading ? null : _submit,
                      child: _uploading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isEditing ? 'Save changes' : 'Add pitch'),
                    ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photo thumbnail with remove button ──────────────────────

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({super.key, required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 100, height: 100, child: child),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, size: 14, color: colors.onError),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
