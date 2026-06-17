import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamup/core/enums/booking_status.dart';
import 'package:teamup/features/auth/bloc/auth_bloc.dart';
import 'package:teamup/features/bookings/bloc/booking_bloc.dart';
import 'package:teamup/features/bookings/data/booking_service.dart';
import 'package:teamup/features/bookings/models/booking_model.dart';
import 'package:teamup/features/bookings/screens/booking_detail_screen.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/shared/widgets/page_header.dart';

const _mobileBreakpoint = 600.0;

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

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

        return BlocProvider(
          create: (_) =>
              BookingBloc(bookingService: BookingService())
                ..add(BookingEvent.loadBusinessBookings(businessId)),
          child: const _BookingsShell(),
        );
      },
    );
  }
}

class _BookingsShell extends StatefulWidget {
  const _BookingsShell();

  @override
  State<_BookingsShell> createState() => _BookingsShellState();
}

class _BookingsShellState extends State<_BookingsShell> {
  final Set<BookingStatus> _statusFilter = {};
  String _query = '';

  void _toggleStatus(BookingStatus s) {
    setState(() {
      if (_statusFilter.contains(s)) {
        _statusFilter.remove(s);
      } else {
        _statusFilter.add(s);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _statusFilter.clear();
      _query = '';
    });
  }

  void _setQuery(String q) {
    setState(() => _query = q);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: TUColors.bg,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TUColors.pageMaxWidth),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(title: 'Bookings'),
            Expanded(
              child: SelectionArea(
                child: BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, state) {
                    return state.maybeMap(
                      loading: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      loaded: (s) {
                        if (s.bookings.isEmpty) return const _EmptyState();
                        return _BookingsBody(
                          bookings: s.bookings,
                          statusFilter: _statusFilter,
                          query: _query,
                          onQuery: _setQuery,
                          onToggleStatus: _toggleStatus,
                          onClearFilters: _clearFilters,
                        );
                      },
                      error: (e) => Center(
                        child: Text(
                          e.message,
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Body ───────────────────────────────────────────────────

class _BookingsBody extends StatelessWidget {
  const _BookingsBody({
    required this.bookings,
    required this.statusFilter,
    required this.query,
    required this.onQuery,
    required this.onToggleStatus,
    required this.onClearFilters,
  });

  final List<BookingModel> bookings;
  final Set<BookingStatus> statusFilter;
  final String query;
  final ValueChanged<String> onQuery;
  final ValueChanged<BookingStatus> onToggleStatus;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < _mobileBreakpoint;
    final hPad = isMobile ? 20.0 : 32.0;

    final counts = _StatusCounts.from(bookings);
    final q = query.trim().toLowerCase();
    final filtered = bookings.where((b) {
      if (statusFilter.isNotEmpty && !statusFilter.contains(b.status)) {
        return false;
      }
      if (q.isEmpty) return true;
      // Match on booking number prefix (the first 6 chars we display).
      return b.id.toLowerCase().contains(q);
    }).toList();

    final groups = _groupByDate(filtered);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: TUColors.pageMaxWidth),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            hPad,
            isMobile ? 14 : 28,
            hPad,
            isMobile ? 24 : 40,
          ),
          children: [
            _Header(count: bookings.length),
            const SizedBox(height: 12),
            _BookingsSearch(initial: query, onChanged: onQuery),
            const SizedBox(height: 12),
            _StatusChipsRow(
              counts: counts,
              selected: statusFilter,
              onToggle: onToggleStatus,
              onClear: onClearFilters,
            ),
            const SizedBox(height: 22),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'No bookings match this filter',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                ),
              ),
            for (final group in groups) ...[
              _GroupHeader(label: group.label),
              const SizedBox(height: 10),
              for (final b in group.bookings) ...[
                BookingCard(booking: b, showBooker: true, actionNeeded: b.status == BookingStatus.pending),
                const SizedBox(height: 10),
              ],
              SizedBox(height: isMobile ? 18 : 28),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Text(
          'Bookings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: colors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Debounced search by booking number ───────────────────

class _BookingsSearch extends StatefulWidget {
  const _BookingsSearch({required this.initial, required this.onChanged});
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_BookingsSearch> createState() => _BookingsSearchState();
}

class _BookingsSearchState extends State<_BookingsSearch> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      widget.onChanged(value);
    });
    setState(() {});
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 36,
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search booking #…',
          hintStyle: TextStyle(
            fontSize: 13,
            color: colors.onSurface.withAlpha(110),
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 16),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: _clear,
                ),
          isDense: true,
          filled: true,
          fillColor: colors.onSurface.withAlpha(8),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─── Status filter chips ────────────────────────────────────

class _StatusCounts {
  const _StatusCounts({
    required this.pending,
    required this.confirmed,
    required this.cancelled,
  });
  final int pending;
  final int confirmed;
  final int cancelled;

  factory _StatusCounts.from(List<BookingModel> bookings) {
    var p = 0, c = 0, x = 0;
    for (final b in bookings) {
      switch (b.status) {
        case BookingStatus.pending:
          p++;
          break;
        case BookingStatus.confirmed:
          c++;
          break;
        case BookingStatus.cancelled:
          x++;
          break;
      }
    }
    return _StatusCounts(pending: p, confirmed: c, cancelled: x);
  }
}

class _StatusChipsRow extends StatelessWidget {
  const _StatusChipsRow({
    required this.counts,
    required this.selected,
    required this.onToggle,
    required this.onClear,
  });

  final _StatusCounts counts;
  final Set<BookingStatus> selected;
  final ValueChanged<BookingStatus> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusFilterChip(
            label: 'Pending',
            count: counts.pending,
            color: const Color(0xFFE6A100),
            selected: selected.contains(BookingStatus.pending),
            onTap: () => onToggle(BookingStatus.pending),
          ),
          const SizedBox(width: 8),
          _StatusFilterChip(
            label: 'Confirmed',
            count: counts.confirmed,
            color: const Color(0xFF1E7E3F),
            selected: selected.contains(BookingStatus.confirmed),
            onTap: () => onToggle(BookingStatus.confirmed),
          ),
          const SizedBox(width: 8),
          _StatusFilterChip(
            label: 'Cancelled',
            count: counts.cancelled,
            color: Theme.of(context).colorScheme.error,
            selected: selected.contains(BookingStatus.cancelled),
            onTap: () => onToggle(BookingStatus.cancelled),
          ),
          if (selected.isNotEmpty) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = selected ? Colors.white : colors.onSurface.withAlpha(170);
    return Material(
      color: selected ? color : colors.onSurface.withAlpha(10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withAlpha(48)
                      : colors.onSurface.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Date grouping ──────────────────────────────────────────

class _BookingGroup {
  const _BookingGroup({
    required this.label,
    required this.bookings,
    required this.order,
  });
  final String label;
  final List<BookingModel> bookings;
  final int order; // For sorting groups
}

List<_BookingGroup> _groupByDate(List<BookingModel> bookings) {
  final now = DateTime.now();
  final today0 = DateTime(now.year, now.month, now.day);
  final tomorrow0 = today0.add(const Duration(days: 1));
  final weekEnd = today0.add(const Duration(days: 7));
  final yesterday0 = today0.subtract(const Duration(days: 1));

  final buckets = <String, List<BookingModel>>{};
  final order = <String, int>{};

  for (final b in bookings) {
    final d = DateTime(b.startTime.year, b.startTime.month, b.startTime.day);
    String label;
    int rank;
    if (d == today0) {
      label = 'Today';
      rank = 0;
    } else if (d == tomorrow0) {
      label = 'Tomorrow';
      rank = 1;
    } else if (d.isAfter(tomorrow0) && d.isBefore(weekEnd)) {
      label = 'This week';
      rank = 2;
    } else if (d.isAtSameMomentAs(weekEnd) || d.isAfter(weekEnd)) {
      label = 'Later';
      rank = 3;
    } else if (d == yesterday0) {
      label = 'Yesterday';
      rank = 4;
    } else {
      label = 'Earlier';
      rank = 5;
    }
    buckets.putIfAbsent(label, () => []).add(b);
    order[label] = rank;
  }

  final groups = buckets.entries.map((e) {
    final list = [...e.value];
    final rank = order[e.key]!;
    list.sort((a, b) {
      // Upcoming groups: earliest first. Past groups: most recent first.
      if (rank <= 3) return a.startTime.compareTo(b.startTime);
      return b.startTime.compareTo(a.startTime);
    });
    return _BookingGroup(label: e.key, bookings: list, order: rank);
  }).toList()..sort((a, b) => a.order - b.order);

  return groups;
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(height: 1, color: colors.onSurface.withAlpha(20)),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────

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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 36,
                color: colors.primary.withAlpha(140),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No bookings yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookings made on your pitches will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BookingCard (exported, also used in MyGames) ───────────

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.showBooker = false,
    this.actionNeeded = false,
  });

  final BookingModel booking;
  final bool showBooker;

  /// Highlights the card when the viewer must act on it (e.g. an owner with a
  /// pending booking to confirm).
  final bool actionNeeded;

  static const _amber = Color(0xFFC9881A);

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceAmount = (booking.pricePaid / 100).toStringAsFixed(0);
    final start = booking.startTime;
    final dimmed = booking.status == BookingStatus.cancelled;
    final now = DateTime.now();
    final isLive =
        booking.status != BookingStatus.cancelled &&
        !start.isAfter(now) &&
        booking.endTime.isAfter(now);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookingDetailScreen(bookingId: booking.id),
          ),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: actionNeeded ? _amber.withAlpha(12) : null,
            border: Border.all(
              color: actionNeeded
                  ? _amber.withAlpha(170)
                  : isLive
                  ? colors.primary.withAlpha(140)
                  : colors.onSurface.withAlpha(20),
              width: actionNeeded || isLive ? 1.5 : 1,
            ),
          ),
          child: Opacity(
            opacity: dimmed ? 0.6 : 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateBlock(date: start),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_time(start)} – ${_time(booking.endTime)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (actionNeeded) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: _amber, borderRadius: BorderRadius.circular(999)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flag_rounded, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('Action', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                          ] else if (isLive) ...[
                            const _LivePill(),
                            const SizedBox(width: 6),
                          ],
                          _StatusPill(status: booking.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$priceAmount ${booking.currency}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (showBooker) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.person_outline_rounded,
                              size: 13,
                              color: colors.onSurface.withAlpha(120),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '#${booking.bookerId.substring(0, 6)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withAlpha(140),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colors.onSurface.withAlpha(140),
                          ),
                        ],
                      ),
                      if (booking.notes != null &&
                          booking.notes!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          booking.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withAlpha(150),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            BookingCard._weekdays[date.weekday - 1],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.primary.withAlpha(180),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colors.primary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            BookingCard._months[date.month - 1],
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.primary.withAlpha(160),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (status) {
      BookingStatus.confirmed => const Color(0xFF1E7E3F),
      BookingStatus.pending => const Color(0xFFE6A100),
      BookingStatus.cancelled => colors.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
