import 'package:flutter/material.dart';
import 'package:teamup/features/venues/screens/dashboard/stats.dart';

class KpiCardsRow extends StatelessWidget {
  const KpiCardsRow({super.key, required this.stats, this.scopeLabel = 'today'});
  final DayStats stats;

  /// "today" / "this month" / "this year" — used in card footnotes.
  final String scopeLabel;

  @override
  Widget build(BuildContext context) {
    final confirmed = (stats.bookedCount - stats.pendingCount).clamp(0, stats.bookedCount);
    final cards = <Widget>[
      _KpiCard(
        label: 'Occupancy',
        value: '${(stats.occupancy * 100).toStringAsFixed(0)}%',
        icon: Icons.donut_large_rounded,
        progress: stats.occupancy,
        footnote: '${stats.bookedHours}h / ${stats.openHours}h booked',
      ),
      _KpiCard(
        label: 'Revenue',
        value: '${stats.revenueRon} RON',
        icon: Icons.payments_rounded,
        footnote: 'Confirmed · $scopeLabel',
      ),
      _KpiCard(
        label: 'Bookings',
        value: '${stats.bookedCount}',
        icon: Icons.event_available_rounded,
        footnote: '$confirmed confirmed · ${stats.pendingCount} pending',
      ),
      _KpiCard(
        label: 'Pending',
        value: '${stats.pendingCount}',
        icon: Icons.hourglass_top_rounded,
        highlight: stats.pendingCount > 0,
        footnote: stats.pendingCount > 0 ? 'Awaiting payment' : 'All clear',
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 920
            ? 4
            : w >= 520
            ? 2
            : 2;
        const gap = 12.0;
        final cardW = (w - (cols - 1) * gap) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: cardW, child: card),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
    this.progress,
    this.footnote,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  final double? progress;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = highlight ? const Color(0xFFE6A100) : colors.primary;
    // Every card renders the same vertical slots (header / value /
    // progress / footnote) so they all settle at the same height,
    // even when some slots are empty.
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.onSurface.withAlpha(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: accent.withAlpha(28), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.onSurface.withAlpha(160), letterSpacing: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(color: accent, fontWeight: FontWeight.w900, height: 1.0),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 5,
            child: progress == null
                ? null
                : ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress!.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: colors.onSurface.withAlpha(15),
                      color: accent,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            // Non-breaking space reserves the line height even when there's
            // no caption to show — keeps card heights perfectly aligned.
            footnote ?? ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(140), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
