import 'package:flutter/material.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: Center(
        child: Text(
          'Manage incoming bookings',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(128),
          ),
        ),
      ),
    );
  }
}
