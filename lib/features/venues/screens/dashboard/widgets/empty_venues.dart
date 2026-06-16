import 'package:flutter/material.dart';

class EmptyVenues extends StatelessWidget {
  const EmptyVenues({super.key});

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
            Icon(Icons.calendar_view_day_outlined, size: 48, color: colors.onSurface.withAlpha(60)),
            const SizedBox(height: 16),
            Text('No venues yet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Add a venue and pitches to see\ntoday\'s schedule here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }
}
