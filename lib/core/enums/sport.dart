enum Sport {
  football(1, 'Football', 'assets/icons/football.png'),
  padel(2, 'Padel', 'assets/icons/padel.png'),
  tennis(3, 'Tennis', 'assets/icons/tennis.png'),
  squash(4, 'Squash', 'assets/icons/squash.png'),
  tableTennis(5, 'Table Tennis', 'assets/icons/table_tennis.png'),
  basketball(6, 'Basketball', 'assets/icons/basketball.png'),
  volleyball(7, 'Volleyball', 'assets/icons/volleyball.png'),
  badminton(8, 'Badminton', 'assets/icons/badminton.png'),
  handball(9, 'Handball', 'assets/icons/handball.png');

  const Sport(this.value, this.label, this.iconPath);
  final int value;
  final String label;
  final String iconPath;
}
