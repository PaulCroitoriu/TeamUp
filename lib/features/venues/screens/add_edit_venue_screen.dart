import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/features/venues/bloc/venue_bloc.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

const _weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class AddEditVenueDialog extends StatefulWidget {
  const AddEditVenueDialog({super.key, required this.businessId, this.venue});

  final String businessId;
  final VenueModel? venue;

  static Future<void> show(BuildContext context, {required String businessId, required VenueBloc bloc, VenueModel? venue}) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final widget = BlocProvider.value(
      value: bloc,
      child: AddEditVenueDialog(businessId: businessId, venue: venue),
    );
    if (isMobile) {
      return showModalBottomSheet<void>(
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
    }
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600, maxHeight: 760), child: widget),
      ),
    );
  }

  @override
  State<AddEditVenueDialog> createState() => _AddEditVenueDialogState();
}

class _AddEditVenueDialogState extends State<AddEditVenueDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _descriptionCtrl;
  late List<Sport> _selectedSports;
  late Map<String, DayHours> _openingHours;
  late bool _hasCafe;
  late bool _hasParking;
  late bool _hasWifi;
  late bool _hasShower;
  late bool _hasChangingRoom;

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
    _openingHours = {for (final day in _weekdays) day: v?.openingHours[day] ?? const DayHours()};
    _hasCafe = v?.hasCafe ?? false;
    _hasParking = v?.hasParking ?? false;
    _hasWifi = v?.hasWifi ?? false;
    _hasShower = v?.hasShower ?? true;
    _hasChangingRoom = v?.hasChangingRoom ?? true;
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
      description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
      sports: _selectedSports,
      openingHours: _openingHours,
      hasCafe: _hasCafe,
      hasParking: _hasParking,
      hasWifi: _hasWifi,
      hasShower: _hasShower,
      hasChangingRoom: _hasChangingRoom,
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
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final hPad = isMobile ? 20.0 : 40.0;

    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title ──
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, isMobile ? 4 : 28, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(_isEditing ? 'Edit Venue' : 'New Venue', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Form ──
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 28),
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
                      decoration: const InputDecoration(hintText: 'Venue name', prefixIcon: Icon(Icons.store_outlined)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Address ──
                    TextFormField(
                      controller: _addressCtrl,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(hintText: 'Address', prefixIcon: Icon(Icons.location_on_outlined)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── City ──
                    TextFormField(
                      controller: _cityCtrl,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(hintText: 'City', prefixIcon: Icon(Icons.location_city_outlined)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Phone ──
                    TextFormField(
                      controller: _phoneCtrl,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: 'Phone (optional)', prefixIcon: Icon(Icons.phone_outlined)),
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
                    Text('Sports offered', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Sport.values.map((sport) {
                        final selected = _selectedSports.contains(sport);
                        return FilterChip(
                          label: Text(sport.label),
                          selected: selected,
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
                    const SizedBox(height: 28),

                    // ── Venue amenities ──
                    Text('Amenities', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    SwitchListTile.adaptive(
                      title: const Text('Café'),
                      value: _hasCafe,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onChanged: (v) => setState(() => _hasCafe = v),
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Parking'),
                      value: _hasParking,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onChanged: (v) => setState(() => _hasParking = v),
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Wi-Fi'),
                      value: _hasWifi,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onChanged: (v) => setState(() => _hasWifi = v),
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Showers'),
                      value: _hasShower,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onChanged: (v) => setState(() => _hasShower = v),
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Changing room'),
                      value: _hasChangingRoom,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onChanged: (v) => setState(() => _hasChangingRoom = v),
                    ),
                    const SizedBox(height: 24),

                    // ── Opening hours ──
                    Text('Opening hours', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ..._weekdays.map((day) {
                      final hours = _openingHours[day]!;
                      return _DayHoursRow(day: day, hours: hours, onChanged: (updated) => setState(() => _openingHours[day] = updated));
                    }),
                    const SizedBox(height: 32),

                    // ── Submit ──
                    ElevatedButton(onPressed: _submit, child: Text(_isEditing ? 'Save changes' : 'Create venue')),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHoursRow extends StatelessWidget {
  const _DayHoursRow({required this.day, required this.hours, required this.onChanged});
  final String day;
  final DayHours hours;
  final ValueChanged<DayHours> onChanged;

  Future<TimeOfDay?> _pickTime(BuildContext context, String initial) async {
    final parts = initial.split(':');
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Day label
          SizedBox(
            width: 90,
            child: Text(_capitalize(day), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
          // Closed toggle
          SizedBox(
            width: 70,
            child: TextButton(
              onPressed: () => onChanged(hours.copyWith(closed: !hours.closed)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
                foregroundColor: hours.closed ? colors.error : colors.onSurface.withAlpha(100),
              ),
              child: Text(hours.closed ? 'Closed' : 'Open', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          // Time pickers
          if (!hours.closed) ...[
            _TimeChip(
              label: hours.open,
              onTap: () async {
                final t = await _pickTime(context, hours.open);
                if (t != null) onChanged(hours.copyWith(open: _fmt(t)));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('–', style: TextStyle(color: colors.onSurface.withAlpha(100))),
            ),
            _TimeChip(
              label: hours.close,
              onTap: () async {
                final t = await _pickTime(context, hours.close);
                if (t != null) onChanged(hours.copyWith(close: _fmt(t)));
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colors.onSurface.withAlpha(30)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
      ),
    );
  }
}
