enum NotificationType {
  newBooking(1, 'New booking'),
  bookingConfirmed(2, 'Booking confirmed'),
  bookingCancelled(3, 'Booking cancelled'),
  newMessage(4, 'New message');

  const NotificationType(this.value, this.label);
  final int value;
  final String label;
}
