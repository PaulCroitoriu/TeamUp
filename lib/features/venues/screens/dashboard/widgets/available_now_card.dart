import 'package:flutter/material.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
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

    final freeNow = <PitchModel>[];
    for (final p in pitches) {
      final venue = venues[p.venueId];
      if (venue == null) continue;
      final win = openingWindow(venue, day);
      if (win.closed) continue;
      if (now.hour < win.openH || now.hour >= win.closeH) continue;
      final occupied = bookings.any(
        (b) => b.pitchId == p.id && b.status != BookingStatus.cancelled && !b.startTime.isAfter(now) && b.endTime.isAfter(now),
      );
      if (occupied) continue;
      freeNow.add(p);
    }

    final colors = Theme.of(context).colorScheme;
    final timeStr = '${two(now.hour)}:${two(now.minute)}';
    final showVenueName = venues.length > 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, Color.lerp(colors.primary, Colors.black, 0.22)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: colors.primary.withAlpha(50), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: Colors.white.withAlpha(45), shape: BoxShape.circle),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available right now',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pitches.isEmpty
                          ? 'No pitches on this view'
                          : '${freeNow.length} of ${pitches.length} pitch${pitches.length == 1 ? '' : 'es'} free · $timeStr',
                      style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (freeNow.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Text(
                  'Every pitch is booked right now — nice problem to have.',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
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
                          hour: now.hour,
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
    final theme = Theme.of(context);
    final price = (pitch.pricePerHour / 100).toStringAsFixed(0);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => openManualBookForPitch(context, pitch: pitch, venue: venue, day: day, hour: hour),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: const Color(0xFF1E7E3F).withAlpha(28), shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(pitch.sport.iconPath, width: 14, height: 14, color: const Color(0xFF1E7E3F)),
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
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black),
                        ),
                        if (showVenueName && venue != null)
                          Text(
                            venue!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black.withAlpha(140), fontSize: 11, fontWeight: FontWeight.w600),
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
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E7E3F)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(8)),
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
