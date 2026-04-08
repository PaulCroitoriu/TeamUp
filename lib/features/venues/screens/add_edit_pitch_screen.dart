import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';

class AddEditPitchScreen extends StatefulWidget {
  const AddEditPitchScreen({
    super.key,
    required this.venueId,
    this.pitch,
  });

  final String venueId;
  final PitchModel? pitch;

  @override
  State<AddEditPitchScreen> createState() => _AddEditPitchScreenState();
}

class _AddEditPitchScreenState extends State<AddEditPitchScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _maxPlayersCtrl;
  late final TextEditingController _priceCtrl;
  late Sport _sport;
  late String? _surface;
  late bool _indoor;

  bool get _isEditing => widget.pitch != null;

  final _venueService = VenueService();

  static const _surfaces = [
    'Grass',
    'Artificial turf',
    'Clay',
    'Hard court',
    'Parquet',
    'Concrete',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.pitch;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _maxPlayersCtrl =
        TextEditingController(text: p?.maxPlayers.toString() ?? '');
    _priceCtrl = TextEditingController(
      text: p != null ? (p.pricePerHour / 100).toStringAsFixed(0) : '',
    );
    _sport = p?.sport ?? Sport.football;
    _surface = p?.surface;
    _indoor = p?.indoor ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _maxPlayersCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final pitch = PitchModel(
      id: widget.pitch?.id ?? '',
      venueId: widget.venueId,
      name: _nameCtrl.text.trim(),
      sport: _sport,
      maxPlayers: int.parse(_maxPlayersCtrl.text.trim()),
      pricePerHour: int.parse(_priceCtrl.text.trim()) * 100,
      surface: _surface,
      indoor: _indoor,
      createdAt: widget.pitch?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await _venueService.updatePitch(widget.venueId, pitch);
    } else {
      await _venueService.createPitch(widget.venueId, pitch);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Pitch' : 'New Pitch'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Name ──
                  TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Pitch name (e.g. "Pitch A")',
                      prefixIcon: Icon(Icons.label_outline_rounded),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Sport ──
                  DropdownButtonFormField<Sport>(
                    initialValue: _sport,
                    decoration: const InputDecoration(
                      hintText: 'Sport',
                      prefixIcon: Icon(Icons.sports_rounded),
                    ),
                    items: Sport.values
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s.label)))
                        .toList(),
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Max players',
                            prefixIcon: Icon(Icons.group_outlined),
                          ),
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Price / hour',
                            prefixIcon: Icon(Icons.payments_outlined),
                            suffixText: 'RON',
                          ),
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
                    decoration: const InputDecoration(
                      hintText: 'Surface (optional)',
                      prefixIcon: Icon(Icons.grass_outlined),
                    ),
                    items: _surfaces
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _surface = v),
                  ),
                  const SizedBox(height: 16),

                  // ── Indoor toggle ──
                  SwitchListTile.adaptive(
                    title: const Text('Indoor / covered'),
                    value: _indoor,
                    activeTrackColor: colors.secondary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onChanged: (v) => setState(() => _indoor = v),
                  ),
                  const SizedBox(height: 32),

                  // ── Submit ──
                  ElevatedButton(
                    onPressed: _submit,
                    child:
                        Text(_isEditing ? 'Save changes' : 'Add pitch'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
