import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/shared/widgets/page_header.dart';
import 'package:teamup/features/venues/data/venue_service.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/dashboard/schedule_view.dart';
import 'package:teamup/features/venues/screens/dashboard/shared.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/empty_venues.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/manual_book_sheet.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/venue_filter_button.dart';

/// Owner-facing dashboard. Always scoped to one venue at a time — each
/// venue has its own KPIs, revenue, hero card, and EPG schedule.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _venueService = VenueService();
  final _bookingService = BookingService();
  late DateTime _selectedDay = _today();
  String? _selectedVenueId;

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final businessId = authState.maybeMap(
          authenticated: (s) => s.user.businessId,
          orElse: () => null,
        );
        if (businessId == null) {
          return const Scaffold(
            body: Center(child: Text('No business linked to this account')),
          );
        }
        return StreamBuilder<List<VenueModel>>(
          stream: _venueService.streamBusinessVenues(businessId),
          builder: (context, vSnap) {
            if (vSnap.connectionState == ConnectionState.waiting) {
              return _shell(
                venues: const [],
                body: const Center(child: CircularProgressIndicator()),
              );
            }
            final venues = vSnap.data ?? const <VenueModel>[];
            if (venues.isEmpty) {
              return _shell(venues: const [], body: const EmptyVenues());
            }

            final venuesById = {for (final v in venues) v.id: v};
            final activeVenueId =
                _selectedVenueId != null &&
                    venuesById.containsKey(_selectedVenueId)
                ? _selectedVenueId!
                : venues.first.id;

            return _shell(
              venues: venues,
              activeVenueId: activeVenueId,
              body: StreamBuilder<List<PitchModel>>(
                stream: _venueService.streamPitchesAcrossVenues(),
                builder: (context, pSnap) {
                  if (pSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final venuePitches =
                      (pSnap.data ?? const <PitchModel>[])
                          .where((p) => p.active && p.venueId == activeVenueId)
                          .toList()
                        ..sort((a, b) => a.sport.value - b.sport.value);

                  return StreamBuilder<List<BookingModel>>(
                    stream: _bookingService.streamBusinessBookings(businessId),
                    builder: (context, bSnap) {
                      final allBookings = bSnap.data ?? const <BookingModel>[];
                      final venueDayBookings = allBookings
                          .where(
                            (b) =>
                                sameDay(b.startTime, _selectedDay) &&
                                b.status != BookingStatus.cancelled &&
                                b.venueId == activeVenueId,
                          )
                          .toList();

                      return ScheduleView(
                        selectedDay: _selectedDay,
                        onDaySelected: (d) => setState(
                          () => _selectedDay = DateTime(d.year, d.month, d.day),
                        ),
                        venuesById: venuesById,
                        venuePitches: venuePitches,
                        venueDayBookings: venueDayBookings,
                        bookingsLoading:
                            bSnap.connectionState == ConnectionState.waiting,
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _shell({
    required List<VenueModel> venues,
    String? activeVenueId,
    required Widget body,
  }) {
    final showVenueFilter = venues.length > 1 && activeVenueId != null;
    return Scaffold(
      backgroundColor: TUColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Dashboard',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (ctx) => IconButton.filledTonal(
                      tooltip: 'New booking',
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () => openManualBookFromAppBar(
                        ctx,
                        selectedDay: _selectedDay,
                      ),
                    ),
                  ),
                  if (showVenueFilter) ...[
                    const SizedBox(width: 8),
                    VenueFilterButton(
                      venues: venues,
                      selectedId: activeVenueId,
                      onSelected: (id) => setState(() => _selectedVenueId = id),
                    ),
                  ],
                  const SizedBox(width: 8),
                  const NotificationBell(),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
