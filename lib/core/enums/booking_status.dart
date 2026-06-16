enum BookingStatus {
  pending(1, 'Awaiting payment'),
  confirmed(2, 'Confirmed'),
  cancelled(3, 'Cancelled');

  const BookingStatus(this.value, this.label);
  final int value;
  final String label;
}
