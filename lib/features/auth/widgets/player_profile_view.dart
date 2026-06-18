import 'package:flutter/material.dart';
import 'package:teamup/core/enums/skill_level.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/core/theme/sport_tile.dart';
import 'package:teamup/features/auth/models/user_model.dart';

/// The public-facing player profile: avatar, name, age/gender, teammate rating,
/// bio and per-sport skill levels. Reused by a player's own profile and by the
/// "review a join request" screen, so it takes optional [extra] content (e.g.
/// contact rows or an Edit button) rendered below the standard sections.
class PlayerProfileView extends StatelessWidget {
  const PlayerProfileView({super.key, required this.user, this.extra});

  final UserModel user;
  final List<Widget>? extra;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final levels = user.levels.entries.toList()..sort((a, b) => a.key.value - b.key.value);
    final meta = <String>[
      user.role.label,
      if (user.age != null) '${user.age} yrs',
      if (user.gender != null) user.gender!.label,
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20, vertical: 28),
          children: [
            Center(child: _Avatar(user: user)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${user.firstName} ${user.lastName}'.trim(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: TUColors.ink),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                meta.join('  ·  '),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: TUColors.ink2),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: _RatingPill(rating: user.rating, count: user.ratingCount)),
            const SizedBox(height: 24),

            if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
              const _SectionLabel('About'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TUColors.surface,
                  borderRadius: BorderRadius.circular(TUColors.rLg),
                  border: Border.all(color: TUColors.line),
                ),
                child: Text(
                  user.bio!.trim(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: TUColors.ink, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const _SectionLabel('Plays'),
            const SizedBox(height: 10),
            if (levels.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TUColors.surface2,
                  borderRadius: BorderRadius.circular(TUColors.rLg),
                  border: Border.all(color: TUColors.line),
                ),
                child: const Text(
                  'No sports added yet',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: TUColors.ink3),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: TUColors.surface,
                  borderRadius: BorderRadius.circular(TUColors.rLg),
                  border: Border.all(color: TUColors.line),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < levels.length; i++) ...[
                      if (i > 0) const Divider(height: 1, thickness: 1, color: TUColors.line),
                      _SportLevelRow(sport: levels[i].key, level: levels[i].value),
                    ],
                  ],
                ),
              ),

            if (extra != null) ...[const SizedBox(height: 24), ...extra!],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final photo = user.photoUrl;
    return CircleAvatar(
      radius: 48,
      backgroundColor: TUColors.brandSoft,
      foregroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
      child: Text(
        user.initials,
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: TUColors.brand700),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating, required this.count});
  final double? rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    final hasRating = rating != null && count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasRating ? TUColors.brandTint : TUColors.surface2,
        borderRadius: BorderRadius.circular(TUColors.rPill),
        border: Border.all(color: TUColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 17, color: hasRating ? const Color(0xFFE2A100) : TUColors.ink3),
          const SizedBox(width: 6),
          Text(
            hasRating ? '${rating!.toStringAsFixed(1)} · $count rating${count == 1 ? '' : 's'}' : 'No ratings yet',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: hasRating ? TUColors.brand700 : TUColors.ink3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SportLevelRow extends StatelessWidget {
  const _SportLevelRow({required this.sport, required this.level});
  final Sport sport;
  final SkillLevel level;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: sport.color, borderRadius: BorderRadius.circular(10)),
            child: Center(child: SportGlyph(sport: sport, size: 20, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(sport.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: TUColors.ink)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: TUColors.surface2,
              borderRadius: BorderRadius.circular(TUColors.rPill),
              border: Border.all(color: TUColors.line),
            ),
            child: Text(level.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: TUColors.ink2)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: TUColors.ink3),
    );
  }
}
