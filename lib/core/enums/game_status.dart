enum GameStatus {
  open(1, 'Open'),
  full(2, 'Full'),
  cancelled(3, 'Cancelled'),
  completed(4, 'Completed');

  const GameStatus(this.value, this.label);
  final int value;
  final String label;
}
