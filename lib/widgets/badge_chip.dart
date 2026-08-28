import 'package:flutter/material.dart';

/// Exibe uma badge conquistada pelo usuario (perfil).
class BadgeChip extends StatelessWidget {
  const BadgeChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.emoji_events, size: 18),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}
