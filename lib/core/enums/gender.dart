/// Optional self-declared gender shown on the player profile.
enum Gender {
  male(1, 'Male'),
  female(2, 'Female'),
  other(3, 'Other'),
  preferNotToSay(4, 'Prefer not to say');

  const Gender(this.value, this.label);
  final int value;
  final String label;
}
