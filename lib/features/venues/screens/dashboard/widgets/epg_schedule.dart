import 'package:flutter/material.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/features/venues/models/pitch_model.dart';
import 'package:teamup/features/venues/models/venue_model.dart';
import 'package:teamup/features/venues/screens/dashboard/shared.dart';
import 'package:teamup/features/venues/screens/dashboard/widgets/manual_book_sheet.dart';

const _kCellWidth = 60.0;
const _kRowHeight = 52.0;
const _kAxisHeight = 30.0;
const _kSportHeaderHeight = 34.0;
const _kLabelWidthMobile = 134.0;
const _kLabelWidthDesktop = 160.0;

const _kConfirmedColor = Color(0xFF1E7E3F);
const _kPendingColor = Color(0xFFE6A100);

class EpgSchedule extends StatefulWidget {
  const EpgSchedule({super.key, required this.pitches, required this.venues, required this.bookings, required this.day});

  final List<PitchModel> pitches;
  final Map<String, VenueModel> venues;
  final List<BookingModel> bookings;
  final DateTime day;

  @override
  State<EpgSchedule> createState() => _EpgScheduleState();
}

class _EpgScheduleState extends State<EpgSchedule> {
  final _scroll = ScrollController();
  bool _initialScrollDone = false;

  @override
  void didUpdateWidget(EpgSchedule old) {
    super.didUpdateWidget(old);
    if (!sameDay(old.day, widget.day)) {
      _initialScrollDone = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocusHour());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToFocusHour() {
    if (!_scroll.hasClients) return;
    final isToday = sameDay(widget.day, DateTime.now());
    final hour = isToday ? DateTime.now().hour : _firstOpenHour();
    final target = ((hour - 1) * _kCellWidth).clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.jumpTo(target);
  }

  int _firstOpenHour() {
    for (final p in widget.pitches) {
      final win = openingWindow(widget.venues[p.venueId], widget.day);
      if (!win.closed) return win.openH;
    }
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < kMobileBreakpoint;
    final labelW = isMobile ? _kLabelWidthMobile : _kLabelWidthDesktop;
    final colors = Theme.of(context).colorScheme;

    if (!_initialScrollDone) {
      _initialScrollDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocusHour());
    }

    final groups = <Sport, List<PitchModel>>{};
    for (final p in widget.pitches) {
      groups.putIfAbsent(p.sport, () => []).add(p);
    }
    final sortedSports = groups.keys.toList()..sort((a, b) => a.value - b.value);

    final orderedPitches = <_PitchSlot>[];
    for (final sport in sortedSports) {
      orderedPitches.add(_PitchSlot.sportHeader(sport, groups[sport]!.length));
      for (final p in groups[sport]!) {
        orderedPitches.add(_PitchSlot.pitch(p));
      }
    }

    final totalContentWidth = kHourCount * _kCellWidth;
    final timelineHeight = _kAxisHeight + orderedPitches.fold<double>(0, (acc, slot) => acc + slot.height);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.onSurface.withAlpha(20)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed left "channels" column
          Container(
            width: labelW,
            decoration: BoxDecoration(
              color: colors.onSurface.withAlpha(8),
              border: Border(right: BorderSide(color: colors.onSurface.withAlpha(20))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: _kAxisHeight,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(Icons.tv_rounded, size: 14, color: colors.onSurface.withAlpha(150)),
                      const SizedBox(width: 6),
                      Text(
                        'Pitch',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.onSurface.withAlpha(160), letterSpacing: 0.4),
                      ),
                    ],
                  ),
                ),
                for (final slot in orderedPitches) _LeftSlot(slot: slot),
              ],
            ),
          ),
          // Scrollable timeline area
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: totalContentWidth,
                height: timelineHeight,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HourAxis(cellWidth: _kCellWidth),
                        for (final slot in orderedPitches)
                          slot.isSport
                              ? SizedBox(
                                  height: _kSportHeaderHeight,
                                  child: Container(color: colors.onSurface.withAlpha(6)),
                                )
                              : _EpgRow(
                                  pitch: slot.pitch!,
                                  venue: widget.venues[slot.pitch!.venueId],
                                  bookings: widget.bookings.where((b) => b.pitchId == slot.pitch!.id).toList(),
                                  day: widget.day,
                                ),
                      ],
                    ),
                    if (sameDay(widget.day, DateTime.now()))
                      _NowIndicator(cellWidth: _kCellWidth, topOffset: _kAxisHeight),
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

class _PitchSlot {
  _PitchSlot.sportHeader(this.sport, this.sportCount)
    : pitch = null,
      isSport = true;
  _PitchSlot.pitch(this.pitch)
    : sport = null,
      sportCount = 0,
      isSport = false;

  final bool isSport;
  final Sport? sport;
  final int sportCount;
  final PitchModel? pitch;

  double get height => isSport ? _kSportHeaderHeight : _kRowHeight;
}

class _LeftSlot extends StatelessWidget {
  const _LeftSlot({required this.slot});
  final _PitchSlot slot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    if (slot.isSport) {
      return Container(
        height: _kSportHeaderHeight,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(color: colors.onSurface.withAlpha(8), border: Border(top: BorderSide(color: colors.onSurface.withAlpha(15)))),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: colors.secondary.withAlpha(28), shape: BoxShape.circle),
              child: Center(child: Image.asset(slot.sport!.iconPath, width: 11, height: 11, color: colors.secondary)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                slot.sport!.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.onSurface.withAlpha(180), letterSpacing: 0.4),
              ),
            ),
            Text(
              '${slot.sportCount}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.onSurface.withAlpha(140)),
            ),
          ],
        ),
      );
    }
    final p = slot.pitch!;
    return Container(
      height: _kRowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.onSurface.withAlpha(15)))),
      child: Text(
        p.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
          height: 1.15,
        ),
      ),
    );
  }
}

class _HourAxis extends StatelessWidget {
  const _HourAxis({required this.cellWidth});
  final double cellWidth;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: _kAxisHeight,
      decoration: BoxDecoration(color: colors.onSurface.withAlpha(8), border: Border(bottom: BorderSide(color: colors.onSurface.withAlpha(15)))),
      child: Row(
        children: [
          for (var h = 0; h < kHourCount; h++)
            Container(
              width: cellWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border(left: BorderSide(color: colors.onSurface.withAlpha(h % 6 == 0 ? 30 : 12)))),
              child: Text(
                '${two(h)}:00',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.onSurface.withAlpha(160)),
              ),
            ),
        ],
      ),
    );
  }
}

class _EpgRow extends StatelessWidget {
  const _EpgRow({required this.pitch, required this.venue, required this.bookings, required this.day});

  final PitchModel pitch;
  final VenueModel? venue;
  final List<BookingModel> bookings;
  final DateTime day;

  bool _hourOccupied(int hour) {
    final cellStart = DateTime(day.year, day.month, day.day, hour);
    final cellEnd = cellStart.add(const Duration(hours: 1));
    return bookings.any(
      (b) => b.status != BookingStatus.cancelled && b.startTime.isBefore(cellEnd) && b.endTime.isAfter(cellStart),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final win = openingWindow(venue, day);

    return SizedBox(
      height: _kRowHeight,
      child: Stack(
        children: [
          Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.onSurface.withAlpha(15))))),
          for (var h = 0; h < kHourCount; h++)
            Positioned(
              left: h * _kCellWidth,
              top: 0,
              bottom: 0,
              width: _kCellWidth,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(border: Border(left: BorderSide(color: colors.onSurface.withAlpha(h % 6 == 0 ? 30 : 10)))),
                ),
              ),
            ),
          if (win.closed)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: colors.onSurface.withAlpha(20),
                  alignment: Alignment.center,
                  child: Text(
                    'Closed',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.onSurface.withAlpha(150), letterSpacing: 0.6),
                  ),
                ),
              ),
            )
          else ...[
            if (win.openH > 0)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: win.openH * _kCellWidth,
                child: IgnorePointer(child: Container(color: colors.onSurface.withAlpha(22))),
              ),
            if (win.closeH < kHourCount)
              Positioned(
                left: win.closeH * _kCellWidth,
                top: 0,
                bottom: 0,
                width: (kHourCount - win.closeH) * _kCellWidth,
                child: IgnorePointer(child: Container(color: colors.onSurface.withAlpha(22))),
              ),
          ],
          // Cells (hover + tap)
          for (var h = 0; h < kHourCount; h++)
            if (!win.closed && h >= win.openH && h < win.closeH && !_hourOccupied(h))
              _EpgCell(
                left: h * _kCellWidth,
                width: _kCellWidth,
                onTap: () => openManualBookForPitch(context, pitch: pitch, venue: venue, day: day, hour: h),
              ),
          // Bookings
          for (final b in bookings) ..._bookingBlock(context, b),
        ],
      ),
    );
  }

  List<Widget> _bookingBlock(BuildContext context, BookingModel b) {
    if (b.status == BookingStatus.cancelled) return const [];
    final startFrac = (b.startTime.hour + b.startTime.minute / 60).clamp(0.0, kHourCount.toDouble());
    final endFrac = (b.endTime.hour + b.endTime.minute / 60).clamp(0.0, kHourCount.toDouble());
    if (endFrac <= startFrac) return const [];
    final left = startFrac * _kCellWidth;
    final width = (endFrac - startFrac) * _kCellWidth;
    final color = b.status == BookingStatus.confirmed ? _kConfirmedColor : _kPendingColor;
    final label = '${two(b.startTime.hour)}:${two(b.startTime.minute)}–${two(b.endTime.hour)}:${two(b.endTime.minute)}';

    return [
      Positioned(
        left: left + 2,
        top: 4,
        bottom: 4,
        width: width - 4,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: b.id))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Icon(
                    b.status == BookingStatus.confirmed ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  if (width >= 80) ...[
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _EpgCell extends StatefulWidget {
  const _EpgCell({required this.left, required this.width, required this.onTap});
  final double left;
  final double width;
  final VoidCallback onTap;

  @override
  State<_EpgCell> createState() => _EpgCellState();
}

class _EpgCellState extends State<_EpgCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Positioned(
      left: widget.left,
      top: 4,
      bottom: 4,
      width: widget.width,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _hovered ? colors.primary.withAlpha(30) : Colors.transparent,
              border: _hovered ? Border.all(color: colors.primary.withAlpha(120), width: 1.2) : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: _hovered
                ? Center(
                    child: Icon(Icons.add_rounded, size: 14, color: colors.primary.withAlpha(220)),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _NowIndicator extends StatelessWidget {
  const _NowIndicator({required this.cellWidth, required this.topOffset});
  final double cellWidth;
  final double topOffset;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final frac = now.hour + now.minute / 60;
    final colors = Theme.of(context).colorScheme;
    return Positioned(
      left: frac * cellWidth - 1,
      top: topOffset - 4,
      bottom: 0,
      width: 2,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: Container(color: colors.error)),
            Positioned(
              top: 0,
              left: -3,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
