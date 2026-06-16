import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  const Section({super.key, this.title, this.subtitle, this.action, required this.child, this.padding, this.titleIcon});

  final String? title;
  final String? subtitle;
  final IconData? titleIcon;
  final Widget? action;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurface.withAlpha(18)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      padding: padding ?? const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(titleIcon, size: 16, color: colors.onSurface.withAlpha(160)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withAlpha(140), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}
