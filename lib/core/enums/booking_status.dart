enum BookingStatus {
  pending(1, 'Pending'),
  confirmed(2, 'Confirmed'),
  cancelled(3, 'Cancelled');

  const BookingStatus(this.value, this.label);
  final int value;
  final String label;
}
