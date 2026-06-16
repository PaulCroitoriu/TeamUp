import 'package:flutter/material.dart';
import 'package:teamup/features/venues/models/venue_model.dart';

class VenueFilterButton extends StatelessWidget {
  const VenueFilterButton({super.key, required this.venues, required this.selectedId, required this.onSelected});

  final List<VenueModel> venues;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = venues.where((v) => v.id == selectedId).firstOrNull;
    final label = selected?.name ?? 'Select venue';

    return PopupMenuButton<String>(
      tooltip: 'Switch venue',
      position: PopupMenuPosition.under,
      initialValue: selectedId,
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final v in venues)
          PopupMenuItem<String>(
            value: v.id,
            child: Row(
              children: [
                Icon(
                  v.id == selectedId ? Icons.check_circle_rounded : Icons.location_on_outlined,
                  size: 16,
                  color: v.id == selectedId ? colors.primary : colors.onSurface.withAlpha(160),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    v.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: v.id == selectedId ? FontWeight.w800 : FontWeight.w600,
                      color: v.id == selectedId ? colors.primary : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.primary.withAlpha(22),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, size: 16, color: colors.primary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: colors.primary),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.expand_more_rounded, size: 16, color: colors.primary),
          ],
        ),
      ),
    );
  }
}
