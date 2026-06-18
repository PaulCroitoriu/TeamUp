enum GameStatus {
  open(1, 'Open'),
  full(2, 'Full'),
  cancelled(3, 'Cancelled'),
  completed(4, 'Completed'),

  /// Host closed the game to new players. The booking and current team are
  /// kept, but it no longer appears in discovery and can't be joined.
  private(5, 'Private');

  const GameStatus(this.value, this.label);
  final int value;
  final String label;
}
