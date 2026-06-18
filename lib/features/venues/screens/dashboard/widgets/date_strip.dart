import 'package:flutter/material.dart';
import 'package:teamup/features/venues/screens/dashboard/shared.dart';

class DateStrip extends StatelessWidget {
  const DateStrip({super.key, required this.selected, required this.onSelected});

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _stripDays = 14;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final inStripRange = !selected.isBefore(start) && selected.difference(start).inDays < _stripDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // 14 day chips + 1 pick chip
            itemCount: _stripDays + 1,
            padding: const EdgeInsets.symmetric(vertical: 6),
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              if (i == _stripDays) {
                return _PickChip(selected: selected, onSelected: onSelected, isCustom: !inStripRange);
              }
              final day = start.add(Duration(days: i));
              return _DateChip(
                day: day,
                isToday: i == 0,
                isSelected: sameDay(day, selected),
                onTap: () => onSelected(day),
                label: i == 0 ? 'Today' : _weekdays[day.weekday - 1],
              );
            },
          ),
        ),
        if (!inStripRange) ...[
          const SizedBox(height: 8),
          _SelectedFarDateBanner(
            selected: selected,
            monthName: _months[selected.month - 1],
            weekdayName: _weekdays[selected.weekday - 1],
            onJumpToday: () => onSelected(start),
          ),
        ],
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
    required this.label,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bg = isSelected
        ? colors.primary
        : isToday
        ? colors.primary.withAlpha(20)
        : colors.onSurface.withAlpha(10);
    final fg = isSelected ? Colors.white : (isToday ? colors.primary : colors.onSurface);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 60,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg.withAlpha(isSelected ? 230 : 200)),
              ),
              const SizedBox(height: 4),
              Text(
                '${day.day}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: fg, height: 1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickChip extends StatelessWidget {
  const _PickChip({required this.selected, required this.onSelected, required this.isCustom});

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  /// Highlight the chip when the active date is outside the 14-day strip.
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE6A100); // amber, distinct from primary teal
    final bg = isCustom ? accent : accent.withAlpha(35);
    final fg = isCustom ? Colors.white : accent;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final today = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: selected,
            firstDate: DateTime(today.year, today.month, today.day),
            lastDate: today.add(const Duration(days: 365)),
            helpText: 'Pick a date',
          );
          if (picked != null) onSelected(DateTime(picked.year, picked.month, picked.day));
        },
        child: Container(
          width: 60,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: accent.withAlpha(isCustom ? 255 : 130), width: 1.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_rounded, size: 16, color: fg),
              const SizedBox(height: 4),
              Text(
                'Pick',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedFarDateBanner extends StatelessWidget {
  const _SelectedFarDateBanner({
    required this.selected,
    required this.monthName,
    required this.weekdayName,
    required this.onJumpToday,
  });

  final DateTime selected;
  final String monthName;
  final String weekdayName;
  final VoidCallback onJumpToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFE6A100).withAlpha(28), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, size: 16, color: Color(0xFFE6A100)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Viewing $weekdayName, ${selected.day} $monthName ${selected.year}',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF7A5500)),
            ),
          ),
          TextButton(
            onPressed: onJumpToday,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: colors.primary,
            ),
            child: const Text('Jump to today', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
