import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/notification_type.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/auth/data/auth_service.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/notifications/data/notification_service.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

final _log = Logger();

const _weekdayKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

class _Slot {
  const _Slot({required this.start, required this.end, required this.available});
  final DateTime start;
  final DateTime end;
  final bool available;
}

class PitchBookingScreen extends StatefulWidget {
  const PitchBookingScreen({super.key, required this.venue, required this.pitch});

  final VenueModel venue;
  final PitchModel pitch;

  @override
  State<PitchBookingScreen> createState() => _PitchBookingScreenState();
}

class _PitchBookingScreenState extends State<PitchBookingScreen> {
  final _bookingService = BookingService();
  final _authService = AuthService();
  final _notificationService = NotificationService();

  late DateTime _selectedDay = _stripTime(DateTime.now());
  bool _booking = false;

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  List<_Slot> _slotsFor(DateTime day, List<BookingModel> bookings) {
    final dayKey = _weekdayKeys[day.weekday - 1];
    final hours = widget.venue.openingHours[dayKey];
    if (hours == null || hours.closed) return const [];

    final openH = int.tryParse(hours.open.split(':').first) ?? 9;
    final closeH = int.tryParse(hours.close.split(':').first) ?? 22;
    if (closeH <= openH) return const [];

    final now = DateTime.now();
    final result = <_Slot>[];
    for (var h = openH; h < closeH; h++) {
      final start = DateTime(day.year, day.month, day.day, h);
      final end = DateTime(day.year, day.month, day.day, h + 1);
      final isPast = start.isBefore(now);
      final isBooked = bookings.any((b) => b.status != BookingStatus.cancelled && b.startTime.isBefore(end) && b.endTime.isAfter(start));
      result.add(_Slot(start: start, end: end, available: !isPast && !isBooked));
    }
    return result;
  }

  Future<void> _book(_Slot slot, String userId) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm booking'),
        content: Text(
          '${widget.pitch.name}\n'
          '${_formatDate(slot.start)} • '
          '${_formatTime(slot.start)} – ${_formatTime(slot.end)}\n'
          '${(widget.pitch.pricePerHour / 100).toStringAsFixed(0)} ${widget.pitch.currency}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Book')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _booking = true);
    try {
      final booking = await _bookingService.createBooking(
        BookingModel(
          id: '',
          pitchId: widget.pitch.id,
          venueId: widget.venue.id,
          businessId: widget.venue.businessId,
          bookerId: userId,
          startTime: slot.start,
          endTime: slot.end,
          pricePaid: widget.pitch.pricePerHour,
          currency: widget.pitch.currency,
          createdAt: DateTime.now(),
        ),
      );

      // Notify the business owner.
      try {
        final business = await _authService.getBusiness(widget.venue.businessId);
        await _notificationService.create(
          NotificationModel(
            id: '',
            recipientId: business.ownerUid,
            type: NotificationType.newBooking,
            title: 'New booking request',
            body: '${widget.pitch.name} • ${_formatDate(slot.start)} ${_formatTime(slot.start)}',
            bookingId: booking.id,
            createdAt: DateTime.now(),
          ),
        );
      } catch (e, st) {
        // Don't fail the booking if the notification write fails.
        _log.w('Failed to write newBooking notification: ${_describeError(e)}', stackTrace: st);
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: booking.id)));
    } on BookingConflictException catch (e, st) {
      _log.w('Booking conflict on create', error: e, stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e, st) {
      final detail = _describeError(e);
      _log.e('Booking creation failed: $detail', stackTrace: st);
      messenger.showSnackBar(SnackBar(content: Text(detail)));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  /// Web async errors come through as JS NativeErrors wrapped in a Dart
  /// "converted Future" envelope. The interesting fields live on the inner
  /// JS object (`name`, `code`, `message`). Read them via dynamic dispatch
  /// (which JS interop translates to property reads) so we get a useful
  /// string instead of the opaque wrapper text.
  String _describeError(Object e) {
    final dynamic d = e;
    dynamic inner;
    try {
      inner = d.error;
    } catch (_) {}
    inner ??= d;

    String? safe(dynamic Function() get) {
      try {
        final v = get();
        return v?.toString();
      } catch (_) {
        return null;
      }
    }

    final name = safe(() => inner.name);
    final code = safe(() => inner.code);
    final message = safe(() => inner.message);
    final parts = <String>[if (name != null) 'name=$name', if (code != null) 'code=$code', if (message != null) 'message=$message'];
    return parts.isEmpty ? e.toString() : parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceAmount = (widget.pitch.pricePerHour / 100).toStringAsFixed(0);

    final userId = context.select<AuthBloc, String?>((b) => b.state.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null));

    return Scaffold(
      appBar: AppBar(title: Text(widget.pitch.name)),
      body: Column(
        children: [
          // ── Pitch summary header ──
          Container(
            color: colors.primary.withAlpha(8),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Image.asset(widget.pitch.sport.iconPath, width: 22, height: 22, color: colors.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.pitch.sport.label} • ${widget.venue.name}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(widget.venue.city, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(150))),
                    ],
                  ),
                ),
                Text(
                  '$priceAmount ${widget.pitch.currency}/h',
                  style: theme.textTheme.titleSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          // ── Date strip ──
          _DateStrip(selected: _selectedDay, onSelected: (d) => setState(() => _selectedDay = d)),
          const Divider(height: 1),

          // ── Slot grid ──
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: _bookingService.streamPitchBookingsForDay(widget.pitch.id, _selectedDay),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final slots = _slotsFor(_selectedDay, snap.data ?? const []);
                if (slots.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Closed on this day', style: TextStyle(color: colors.onSurface.withAlpha(140))),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (_, i) => _SlotTile(slot: slots[i], onTap: (userId != null && !_booking) ? () => _book(slots[i], userId) : null),
                );
              },
            ),
          ),
          if (userId == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colors.error.withAlpha(15),
              child: Text(
                'Sign in to book a slot',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selected, required this.onSelected});

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: 14,
        itemBuilder: (context, i) {
          final day = start.add(Duration(days: i));
          final isSelected = day == selected;
          final colors = Theme.of(context).colorScheme;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isSelected ? colors.primary : colors.onSurface.withAlpha(8),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => onSelected(day),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _weekdayLabels[day.weekday - 1],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white.withAlpha(220) : colors.onSurface.withAlpha(140),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : colors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot, required this.onTap});

  final _Slot slot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final available = slot.available && onTap != null;
    return Material(
      color: available ? colors.primary.withAlpha(15) : colors.onSurface.withAlpha(10),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: available ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: available ? colors.primary.withAlpha(60) : colors.onSurface.withAlpha(20)),
          ),
          child: Text(
            _formatTime(slot.start),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: available ? colors.primary : colors.onSurface.withAlpha(80),
              decoration: slot.available ? TextDecoration.none : TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]}';
}

String _formatTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
