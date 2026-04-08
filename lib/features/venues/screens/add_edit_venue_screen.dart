import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/features/venues/bloc/venue_bloc.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

class AddEditVenueScreen extends StatefulWidget {
  const AddEditVenueScreen({
    super.key,
    required this.businessId,
    this.venue,
  });

  final String businessId;
  final VenueModel? venue;

  @override
  State<AddEditVenueScreen> createState() => _AddEditVenueScreenState();
}

class _AddEditVenueScreenState extends State<AddEditVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _descriptionCtrl;
  late List<Sport> _selectedSports;

  bool get _isEditing => widget.venue != null;

  @override
  void initState() {
    super.initState();
    final v = widget.venue;
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _addressCtrl = TextEditingController(text: v?.address ?? '');
    _cityCtrl = TextEditingController(text: v?.city ?? '');
    _phoneCtrl = TextEditingController(text: v?.phone ?? '');
    _descriptionCtrl = TextEditingController(text: v?.description ?? '');
    _selectedSports = List<Sport>.from(v?.sports ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final venue = VenueModel(
      id: widget.venue?.id ?? '',
      businessId: widget.businessId,
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      location: widget.venue?.location ?? const GeoPoint(0, 0),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      sports: _selectedSports,
      createdAt: widget.venue?.createdAt ?? DateTime.now(),
    );

    final bloc = context.read<VenueBloc>();
    if (_isEditing) {
      bloc.add(VenueEvent.updateVenue(venue));
    } else {
      bloc.add(VenueEvent.createVenue(venue));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Venue' : 'New Venue'),
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
                      hintText: 'Venue name',
                      prefixIcon: Icon(Icons.store_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Address ──
                  TextFormField(
                    controller: _addressCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── City ──
                  TextFormField(
                    controller: _cityCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'City',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Phone ──
                  TextFormField(
                    controller: _phoneCtrl,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Phone (optional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Description ──
                  TextFormField(
                    controller: _descriptionCtrl,
                    textInputAction: TextInputAction.newline,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Description (optional)',
                      prefixIcon: Icon(Icons.notes_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Sports ──
                  Text(
                    'Sports offered',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Sport.values.map((sport) {
                      final selected = _selectedSports.contains(sport);
                      return FilterChip(
                        label: Text(sport.label),
                        selected: selected,
                        selectedColor: colors.secondary.withAlpha(30),
                        checkmarkColor: colors.secondary,
                        onSelected: (on) {
                          setState(() {
                            if (on) {
                              _selectedSports.add(sport);
                            } else {
                              _selectedSports.remove(sport);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // ── Submit ──
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isEditing ? 'Save changes' : 'Create venue'),
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
