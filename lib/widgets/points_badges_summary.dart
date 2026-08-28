import 'package:flutter/material.dart';

import '../models/app_user.dart';
import 'badge_chip.dart';

/// Resumo de pontos e badges exibido na tela de Perfil.
class PointsBadgesSummary extends StatelessWidget {
  const PointsBadgesSummary({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.stars, color: theme.colorScheme.primary, size: 32),
            const SizedBox(width: 8),
            Text(
              '${user.points} pontos',
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Badges', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (user.badges.isEmpty)
          Text(
            'Ainda sem badges. Envie reports para conquistar!',
            style: theme.textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.badges.map((b) => BadgeChip(label: b)).toList(),
          ),
      ],
    );
  }
}
