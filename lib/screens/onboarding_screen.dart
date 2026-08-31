import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'main_navigation_screen.dart';

/// Uma regiao de bairros exibida na lista do Onboarding (ex: "ABC Paulista").
class BairroRegiao {
  const BairroRegiao({required this.nome, required this.bairros});

  final String nome;
  final List<String> bairros;
}

/// Primeira tela do app: o usuario escolhe o bairro que quer acompanhar.
///
/// A escolha define o `bairroPreferido` salvo em `users` e filtra os dados
/// de estabelecimentos e feed exibidos na Home. Tambem e reaberta a partir
/// do Perfil quando o usuario quer trocar de bairro.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.currentBairro});

  /// Bairro atualmente selecionado, se houver (fluxo de "trocar bairro").
  final String? currentBairro;

  static const List<BairroRegiao> regioes = [
    BairroRegiao(
      nome: 'ABC Paulista',
      bairros: ['São Bernardo do Campo', 'Santo André', 'São Caetano do Sul'],
    ),
    BairroRegiao(
      nome: 'São Paulo - Zona Sul',
      bairros: ['Moema', 'Vila Olímpia', 'Itaim Bibi'],
    ),
    BairroRegiao(
      nome: 'São Paulo - Zona Oeste',
      bairros: ['Pinheiros', 'Vila Madalena'],
    ),
    BairroRegiao(
      nome: 'Rio de Janeiro - Zona Sul',
      bairros: ['Copacabana', 'Ipanema'],
    ),
  ];

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _authService = AuthService();
  final _userService = UserService();

  late String? _selectedBairro = widget.currentBairro;
  bool _loading = false;

  Future<void> _confirmarBairro() async {
    final bairro = _selectedBairro;
    if (bairro == null) return;

    setState(() => _loading = true);
    try {
      final user = await _authService.ensureSignedIn();
      await _userService.createIfMissing(
        uid: user.uid,
        displayName: 'Explorador iVibe',
      );
      await _userService.updateBairroPreferido(user.uid, bairro);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(bairro: bairro),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Bem-vindo ao iVibe',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha o bairro que você quer acompanhar: vida noturna, '
                'restaurantes, rotas seguras e as novidades em tempo real.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    for (final regiao in OnboardingScreen.regioes) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          regiao.nome,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      for (final bairro in regiao.bairros)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            color: bairro == _selectedBairro
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            child: ListTile(
                              title: Text(bairro),
                              trailing: bairro == _selectedBairro
                                  ? const Icon(Icons.check_circle)
                                  : null,
                              onTap: () => setState(() => _selectedBairro = bairro),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedBairro == null || _loading
                      ? null
                      : _confirmarBairro,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
