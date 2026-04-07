import 'package:flutter/material.dart';

class MyGamesScreen extends StatelessWidget {
  const MyGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Games')),
      body: Center(
        child: Text(
          'Your upcoming and past games',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(128),
          ),
        ),
      ),
    );
  }
}
