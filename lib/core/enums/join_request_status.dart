enum JoinRequestStatus {
  pending(1, 'Pending'),

  /// Host approved — waiting for the player to pay and confirm their spot.
  approved(2, 'Approved'),
  declined(3, 'Declined'),

  /// Player paid after approval and is now in the game.
  confirmed(4, 'Confirmed');

  const JoinRequestStatus(this.value, this.label);
  final int value;
  final String label;
}
