import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'main_navigation_screen.dart';

/// Primeira tela do app: o usuario escolhe o bairro que quer acompanhar.
///
/// A escolha define o `bairroPreferido` salvo em `users` e filtra os dados
/// de estabelecimentos e feed exibidos na Home.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const List<String> bairrosDisponiveis = [
    'Pinheiros',
    'Vila Madalena',
    'Itaim Bibi',
    'Moema',
    'Vila Olímpia',
    'Copacabana',
    'Ipanema',
    'Savassi',
  ];

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _authService = AuthService();
  final _userService = UserService();

  String? _selectedBairro;
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
                child: ListView.separated(
                  itemCount: OnboardingScreen.bairrosDisponiveis.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final bairro = OnboardingScreen.bairrosDisponiveis[index];
                    final selected = bairro == _selectedBairro;
                    return Card(
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        title: Text(bairro),
                        trailing: selected ? const Icon(Icons.check_circle) : null,
                        onTap: () => setState(() => _selectedBairro = bairro),
                      ),
                    );
                  },
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
