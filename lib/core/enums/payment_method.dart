enum PaymentMethod {
  cash(1, 'Cash on premises'),
  card(2, 'Online by card'),
  transfer(3, 'Bank transfer');

  const PaymentMethod(this.value, this.label);
  final int value;
  final String label;
}
