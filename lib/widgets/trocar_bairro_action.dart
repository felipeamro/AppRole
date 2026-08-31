import 'package:flutter/material.dart';

import '../screens/onboarding_screen.dart';

/// Leva de volta ao Onboarding para trocar o bairro ativo, limpando a pilha
/// de navegacao e pre-selecionando o bairro atual. Usado no Perfil e nos
/// headers do Mapa/Feed.
void goToTrocarBairro(BuildContext context, String? bairroAtual) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => OnboardingScreen(currentBairro: bairroAtual),
    ),
    (route) => false,
  );
}

/// Chip compacto para o header do Mapa/Feed, ao lado do bairro atual.
class TrocarBairroChip extends StatelessWidget {
  const TrocarBairroChip({super.key, required this.bairroAtual});

  final String bairroAtual;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ActionChip(
        avatar: const Icon(Icons.sync_alt, size: 18),
        label: const Text('Trocar bairro'),
        onPressed: () => goToTrocarBairro(context, bairroAtual),
      ),
    );
  }
}
