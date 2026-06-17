import 'package:flutter/material.dart';
import 'package:teamup/core/enums/sport.dart';

/// TeamUp design tokens — the "bolder, on-brand" pitch-green system from the
/// Explore + Booking redesign. Pitch green + a lime accent + a distinct accent
/// colour per sport. These are intentionally light-surface tokens: the redesign
/// is a confident light theme, so card/slot/tile surfaces use them directly
/// rather than the global (theme-aware) ColorScheme.
class TUColors {
  TUColors._();

  // surfaces
  static const bg = Color(0xFFEEF1EC);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF6F8F4);
  static const line = Color(0xFFE2E7DE);
  static const line2 = Color(0xFFD3DACE);

  // ink
  static const ink = Color(0xFF0E1B14);
  static const ink2 = Color(0xFF5A6B61);
  static const ink3 = Color(0xFF93A097);

  // brand
  static const brand = Color(0xFF0F8A4D);
  static const brand700 = Color(0xFF0A6B3B);
  static const brand900 = Color(0xFF073D22);
  static const brandSoft = Color(0xFFDCF1E4);
  static const brandTint = Color(0xFFEAF7F0);
  static const lime = Color(0xFFC9F24E);

  // tags / status
  static const busyBg = Color(0xFFEDEFEA);

  // shadows
  static final shSm = [
    BoxShadow(color: const Color(0xFF0E1B14).withValues(alpha: .05), blurRadius: 2, offset: const Offset(0, 1)),
    BoxShadow(color: const Color(0xFF0E1B14).withValues(alpha: .04), blurRadius: 6, offset: const Offset(0, 2)),
  ];
  static final shMd = [
    BoxShadow(color: const Color(0xFF0E1B14).withValues(alpha: .07), blurRadius: 14, offset: const Offset(0, 4)),
    BoxShadow(color: const Color(0xFF0E1B14).withValues(alpha: .04), blurRadius: 4, offset: const Offset(0, 2)),
  ];
  static final shLg = [
    BoxShadow(color: const Color(0xFF0E1B14).withValues(alpha: .14), blurRadius: 40, offset: const Offset(0, 16)),
    BoxShadow(color: const Color(0xFF0E1B14).withValues(alpha: .07), blurRadius: 16, offset: const Offset(0, 6)),
  ];

  // radii
  static const rSm = 10.0;
  static const rMd = 16.0;
  static const rLg = 22.0;
  static const rXl = 28.0;
  static const rPill = 999.0;

  // Shared max content width for top-level pages, so every page's header and
  // body align to the same column on desktop instead of each picking its own.
  static const pageMaxWidth = 1120.0;
}

/// Per-sport accent colour, matching the design's sport palette.
extension SportPalette on Sport {
  Color get color {
    switch (this) {
      case Sport.football:
        return const Color(0xFF16A34A);
      case Sport.padel:
        return const Color(0xFF2F73E8);
      case Sport.tennis:
        return const Color(0xFFE2683C);
      case Sport.squash:
        return const Color(0xFF7C5CE6);
      case Sport.tableTennis:
        return const Color(0xFF0EA5A0);
      case Sport.basketball:
        return const Color(0xFFF0851F);
      case Sport.volleyball:
        return const Color(0xFFE0A82E);
      case Sport.badminton:
        return const Color(0xFFD14B8F);
      case Sport.handball:
        return const Color(0xFF4F6BED);
    }
  }

  /// Gradient used behind an illustrated sport tile:
  /// `linear-gradient(150deg, color, mix(color 72%, #06170E))`.
  LinearGradient get tileGradient {
    final c = color;
    final dark = Color.lerp(c, const Color(0xFF06170E), 0.28)!;
    return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c, dark]);
  }
}
