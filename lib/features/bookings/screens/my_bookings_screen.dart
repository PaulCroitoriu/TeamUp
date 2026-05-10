import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/bookings/bloc/booking_bloc.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/screens/manage_bookings_screen.dart' show BookingCard;

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userId = authState.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null);

        if (userId == null) {
          return const Scaffold(body: Center(child: Text('Sign in to see your bookings')));
        }

        return BlocProvider(
          create: (_) => BookingBloc(bookingService: BookingService())..add(BookingEvent.loadUserBookings(userId)),
          child: const _MyBookingsBody(),
        );
      },
    );
  }
}

class _MyBookingsBody extends StatelessWidget {
  const _MyBookingsBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My bookings')),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          return state.maybeMap(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            loaded: (s) {
              if (s.bookings.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available_outlined, size: 48, color: colors.onSurface.withAlpha(60)),
                        const SizedBox(height: 16),
                        Text('No bookings yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          'Book a pitch or join a game to see it here',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(128)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: s.bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => BookingCard(booking: s.bookings[i]),
              );
            },
            error: (e) => Center(child: Text(e.message)),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
