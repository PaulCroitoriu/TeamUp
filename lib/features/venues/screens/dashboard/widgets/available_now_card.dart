import 'package:flutter/material.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/venues/screens/dashboard/shared.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/manual_book_sheet.dart';

class AvailableNowCard extends StatelessWidget {
  const AvailableNowCard({super.key, required this.pitches, required this.venues, required this.bookings, required this.day});

  final List<PitchModel> pitches;
  final Map<String, VenueModel> venues;
  final List<BookingModel> bookings;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Bookings start on the hour, so surface the next sharp hour (the current
    // one if we're exactly on it).
    final targetHour = now.minute == 0 ? now.hour : now.hour + 1;
    final hasUpcoming = targetHour < kHourCount;
    final slotStart = DateTime(day.year, day.month, day.day, hasUpcoming ? targetHour : 0);
    final slotEnd = slotStart.add(const Duration(hours: 1));

    final freeNow = <PitchModel>[];
    if (hasUpcoming) {
      for (final p in pitches) {
        final venue = venues[p.venueId];
        if (venue == null) continue;
        final win = openingWindow(venue, day);
        if (win.closed) continue;
        if (targetHour < win.openH || targetHour >= win.closeH) continue;
        final occupied = bookings.any(
          (b) => b.pitchId == p.id && b.status != BookingStatus.cancelled && b.startTime.isBefore(slotEnd) && b.endTime.isAfter(slotStart),
        );
        if (occupied) continue;
        freeNow.add(p);
      }
    }

    final slotStr = '${two(targetHour)}:00';
    final showVenueName = venues.length > 1;

    return Container(
      decoration: BoxDecoration(
        color: TUColors.surface,
        borderRadius: BorderRadius.circular(TUColors.rLg),
        border: Border.all(color: TUColors.line),
        boxShadow: TUColors.shSm,
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: TUColors.brandTint, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.bolt_rounded, color: TUColors.brand700, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available right now',
                      style: TextStyle(color: TUColors.ink, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pitches.isEmpty
                          ? 'No pitches on this view'
                          : !hasUpcoming
                          ? 'No more slots today'
                          : '${freeNow.length} of ${pitches.length} pitch${pitches.length == 1 ? '' : 'es'} free · from $slotStr',
                      style: const TextStyle(color: TUColors.ink3, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (freeNow.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(color: TUColors.surface2, borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
              child: Center(
                child: Text(
                  hasUpcoming ? 'Every pitch is booked at $slotStr — nice problem to have.' : 'The venue is done for today.',
                  style: const TextStyle(color: TUColors.ink2, fontSize: 13, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 880
                    ? 3
                    : c.maxWidth >= 520
                    ? 2
                    : 1;
                const gap = 10.0;
                final tileW = (c.maxWidth - (cols - 1) * gap) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final p in freeNow)
                      SizedBox(
                        width: tileW,
                        child: _FreePitchTile(
                          pitch: p,
                          venue: venues[p.venueId],
                          day: day,
                          hour: targetHour,
                          showVenueName: showVenueName,
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FreePitchTile extends StatelessWidget {
  const _FreePitchTile({required this.pitch, required this.venue, required this.day, required this.hour, required this.showVenueName});

  final PitchModel pitch;
  final VenueModel? venue;
  final DateTime day;
  final int hour;
  final bool showVenueName;

  @override
  Widget build(BuildContext context) {
    final price = (pitch.pricePerHour / 100).toStringAsFixed(0);
    return Material(
      color: TUColors.surface2,
      borderRadius: BorderRadius.circular(TUColors.rMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(TUColors.rMd),
        onTap: () => openManualBookForPitch(context, pitch: pitch, venue: venue, day: day, hour: hour),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(TUColors.rMd), border: Border.all(color: TUColors.line)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: pitch.sport.color.withAlpha(28), shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(pitch.sport.iconPath, width: 14, height: 14, color: pitch.sport.color),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pitch.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: TUColors.ink),
                        ),
                        if (showVenueName && venue != null)
                          Text(
                            venue!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: TUColors.ink3, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$price ${pitch.currency}/hr',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: TUColors.brand700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: TUColors.brand, borderRadius: BorderRadius.circular(TUColors.rSm)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Book ${two(hour)}:00',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
