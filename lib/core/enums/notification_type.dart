enum NotificationType {
  newBooking(1, 'New booking'),
  bookingConfirmed(2, 'Booking confirmed'),
  bookingCancelled(3, 'Booking cancelled'),
  newMessage(4, 'New message'),
  joinRequest(5, 'Join request'),
  joinApproved(6, 'Request approved'),
  joinDeclined(7, 'Request declined');

  const NotificationType(this.value, this.label);
  final int value;
  final String label;
}
