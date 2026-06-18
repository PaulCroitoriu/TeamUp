/// A player's self-declared ability in a given sport. Stored per sport on the
/// user profile so a padel pro can still be a football beginner.
enum SkillLevel {
  beginner(1, 'Beginner'),
  intermediate(2, 'Intermediate'),
  advanced(3, 'Advanced'),
  pro(4, 'Pro');

  const SkillLevel(this.value, this.label);
  final int value;
  final String label;
}
