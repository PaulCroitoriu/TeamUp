import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/bookings/bloc/booking_bloc.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/notifications/screens/notifications_screen.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final businessId = authState.maybeMap(authenticated: (s) => s.user.businessId, orElse: () => null);

        if (businessId == null) {
          return const Scaffold(body: Center(child: Text('No business linked to this account')));
        }

        return BlocProvider(
          create: (_) => BookingBloc(bookingService: BookingService())..add(BookingEvent.loadBusinessBookings(businessId)),
          child: const _BookingsBody(),
        );
      },
    );
  }
}

class _BookingsBody extends StatelessWidget {
  const _BookingsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings'), actions: const [NotificationsBell(), SizedBox(width: 4)]),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          return state.maybeMap(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            loaded: (s) {
              if (s.bookings.isEmpty) return const _EmptyState();
              return _BookingsList(bookings: s.bookings, showBooker: true);
            },
            error: (e) => Center(child: Text(e.message)),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: colors.onSurface.withAlpha(60)),
            const SizedBox(height: 16),
            Text('No bookings yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Bookings made on your pitches will appear here',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(128)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  const _BookingsList({required this.bookings, required this.showBooker});
  final List<BookingModel> bookings;
  final bool showBooker;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => BookingCard(booking: bookings[i], showBooker: showBooker),
    );
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking, this.showBooker = false});

  final BookingModel booking;
  final bool showBooker;

  String _formatDate(DateTime d) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceAmount = (booking.pricePaid / 100).toStringAsFixed(0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: booking.id))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(_formatDate(booking.startTime), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  _StatusChip(status: booking.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${_formatTime(booking.startTime)} – ${_formatTime(booking.endTime)}',
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(180)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '$priceAmount ${booking.currency}',
                    style: theme.textTheme.titleSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
                  ),
                  if (showBooker) ...[
                    const SizedBox(width: 12),
                    Text('· ${booking.bookerId.substring(0, 6)}', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(120))),
                  ],
                ],
              ),
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(booking.notes!, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(150))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (status) {
      BookingStatus.confirmed => const Color(0xFF34A853),
      BookingStatus.pending => colors.secondary,
      BookingStatus.cancelled => colors.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
