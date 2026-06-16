import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/enums/gender.dart';
import 'package:teamup/core/enums/skill_level.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum UserRole {
  player(1, 'Player'),
  business(2, 'Business');

  const UserRole(this.value, this.label);
  final int value;
  final String label;
}

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required UserRole role,
    String? businessId,
    String? photoUrl,

    /// Optional phone. Used to look up existing players when an owner is
    /// booking on their behalf over the phone.
    String? phone,

    // ── Player profile (helps teammates vet a join request) ──
    Gender? gender,
    @NullableTimestampConverter() DateTime? birthDate,

    /// Short free-text intro shown on the profile.
    String? bio,

    /// Self-declared ability per sport the player plays. The keys double as the
    /// player's "sports I play" list.
    @Default(<Sport, SkillLevel>{}) Map<Sport, SkillLevel> levels,

    /// Aggregate teammate rating (0–5) and how many ratings it averages.
    /// Display-only for now — the post-game rating flow comes later.
    double? rating,
    @Default(0) int ratingCount,

    /// FCM device tokens for sending push notifications. Each device adds
    /// its own token on sign-in and is responsible for cleaning up its own
    /// token on sign-out / when the token rotates.
    @Default(<String>[]) List<String> fcmTokens,
    @TimestampConverter() required DateTime createdAt,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return UserModel.fromJson({'uid': doc.id, ...data});
  }

  /// "Ada L." style short name for rosters and request tiles.
  String get shortName {
    final last = lastName.trim();
    return last.isEmpty ? firstName.trim() : '$firstName ${last[0]}.';
  }

  /// Age in whole years from [birthDate], or null if unset.
  int? get age {
    final dob = birthDate;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years < 0 ? null : years;
  }

  /// Up-to-two-letter initials for avatar placeholders.
  String get initials {
    final f = firstName.trim();
    final l = lastName.trim();
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    final out = '$a$b'.toUpperCase();
    return out.isEmpty ? '?' : out;
  }
}

