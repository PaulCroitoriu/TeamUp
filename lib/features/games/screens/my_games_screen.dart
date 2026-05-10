import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/bookings/bloc/booking_bloc.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/bookings/screens/manage_bookings_screen.dart' show BookingCard;
import 'package:teamup/features/notifications/screens/notifications_screen.dart';

class MyGamesScreen extends StatelessWidget {
  const MyGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userId = authState.maybeMap(authenticated: (s) => s.user.uid, orElse: () => null);

        if (userId == null) {
          return const Scaffold(body: Center(child: Text('Sign in to see your games')));
        }

        return BlocProvider(
          create: (_) => BookingBloc(bookingService: BookingService())..add(BookingEvent.loadUserBookings(userId)),
          child: const _MyGamesBody(),
        );
      },
    );
  }
}

class _MyGamesBody extends StatelessWidget {
  const _MyGamesBody();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Games'),
          actions: const [NotificationsBell(), SizedBox(width: 4)],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: SelectionArea(
          child: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              return state.maybeMap(
                loading: (_) => const Center(child: CircularProgressIndicator()),
                loaded: (s) => _Tabs(bookings: s.bookings),
                error: (e) => Center(child: Text(e.message)),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.bookings});
  final List<BookingModel> bookings;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = bookings.where((b) => b.status != BookingStatus.cancelled && b.endTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final past = bookings.where((b) => b.status == BookingStatus.cancelled || !b.endTime.isAfter(now)).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return TabBarView(
      children: [
        _BookingsList(bookings: upcoming, emptyTitle: 'No upcoming games', emptySubtitle: 'Book a pitch from Explore to get started'),
        _BookingsList(bookings: past, emptyTitle: 'No past games yet', emptySubtitle: 'Your history will show up here'),
      ],
    );
  }
}

class _BookingsList extends StatelessWidget {
  const _BookingsList({required this.bookings, required this.emptyTitle, required this.emptySubtitle});
  final List<BookingModel> bookings;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_soccer_outlined, size: 48, color: colors.onSurface.withAlpha(60)),
              const SizedBox(height: 16),
              Text(emptyTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(140)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => BookingCard(booking: bookings[i]),
    );
  }
}
