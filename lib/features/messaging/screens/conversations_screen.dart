import 'package:flutter/material.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/shared/widgets/page_header.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TUColors.bg,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TUColors.pageMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHeader(title: 'Messages'),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Your conversations',
                      style: TextStyle(color: TUColors.ink3, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
