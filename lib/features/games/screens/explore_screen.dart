import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // TODO: search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // TODO: filters
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Browse nearby games and venues',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(128),
          ),
        ),
      ),
    );
  }
}
