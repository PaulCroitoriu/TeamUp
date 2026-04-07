import 'package:flutter/material.dart';

class ManageVenuesScreen extends StatelessWidget {
  const ManageVenuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Venues')),
      body: Center(
        child: Text(
          'Manage your venues and pitches',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(128),
          ),
        ),
      ),
    );
  }
}
