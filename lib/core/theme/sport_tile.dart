import 'package:flutter/material.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/theme/design_tokens.dart';

/// Renders a sport's icon, optionally tinted to [color]. Used across the
/// redesigned Explore + Booking screens.
class SportGlyph extends StatelessWidget {
  const SportGlyph({super.key, required this.sport, required this.size, this.color});

  final Sport sport;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      sport.iconPath,
      width: size,
      height: size,
      color: color,
      colorBlendMode: color == null ? null : BlendMode.srcIn,
    );
  }
}

/// An illustrated, photo-free venue tile: a per-sport colour gradient, CSS-style
/// court/pitch lines drawn in code, and the sport glyph in white. Mirrors the
/// design's `tileBg` + `TileLines` + `SportGlyph` composition.
class SportTile extends StatelessWidget {
  const SportTile({
    super.key,
    required this.sport,
    this.height = 152,
    this.borderRadius,
    this.glyphSize = 64,
    this.overlay = const [],
  });

  final Sport sport;
  final double height;
  final BorderRadius? borderRadius;
  final double glyphSize;

  /// Positioned overlays (env tag, open-game tag, …) stacked over the tile.
  final List<Widget> overlay;

  @override
  Widget build(BuildContext context) {
    final tile = DecoratedBox(
      decoration: BoxDecoration(gradient: sport.tileGradient),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _CourtLinesPainter(sport)),
            Center(child: SportGlyph(sport: sport, size: glyphSize, color: Colors.white)),
            ...overlay,
          ],
        ),
      ),
    );

    if (borderRadius == null) return tile;
    return ClipRRect(borderRadius: borderRadius!, child: tile);
  }
}

/// A small pill used for the Indoor/Outdoor and "Open game" tags over a tile.
class TilePill extends StatelessWidget {
  const TilePill({super.key, required this.icon, required this.label, this.background, this.foreground});

  final IconData icon;
  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? TUColors.ink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(TUColors.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class _CourtLinesPainter extends CustomPainter {
  _CourtLinesPainter(this.sport);
  final Sport sport;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: .28);

    // Design lines are authored on a 200×120 viewBox, stretched to fill.
    final sx = size.width / 200, sy = size.height / 120;
    Rect r(double x, double y, double w, double h) => Rect.fromLTWH(x * sx, y * sy, w * sx, h * sy);
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    switch (sport) {
      case Sport.football:
        canvas.drawRRect(RRect.fromRectAndRadius(r(6, 6, 188, 108), Radius.circular(3 * sx)), paint);
        canvas.drawLine(p(100, 6), p(100, 114), paint);
        canvas.drawOval(Rect.fromCircle(center: p(100, 60), radius: 22 * sx), paint);
        canvas.drawRect(r(6, 34, 26, 52), paint);
        canvas.drawRect(r(168, 34, 26, 52), paint);
      case Sport.padel:
      case Sport.tennis:
        canvas.drawRRect(RRect.fromRectAndRadius(r(10, 10, 180, 100), Radius.circular(2 * sx)), paint);
        canvas.drawLine(p(100, 10), p(100, 110), paint);
        canvas.drawLine(p(40, 34), p(160, 34), paint);
        canvas.drawLine(p(40, 86), p(160, 86), paint);
        canvas.drawLine(p(40, 34), p(40, 86), paint);
        canvas.drawLine(p(160, 34), p(160, 86), paint);
      default:
        canvas.drawRRect(RRect.fromRectAndRadius(r(10, 10, 180, 100), Radius.circular(2 * sx)), paint);
        canvas.drawOval(Rect.fromCircle(center: p(100, 60), radius: 20 * sx), paint);
        canvas.drawLine(p(100, 10), p(100, 110), paint);
    }
  }

  @override
  bool shouldRepaint(_CourtLinesPainter old) => old.sport != sport;
}
