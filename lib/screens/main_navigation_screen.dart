import 'package:flutter/material.dart';

import 'feed_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Shell com a barra de navegacao inferior que alterna entre as telas
/// Home, Feed e Perfil, mantendo o bairro escolhido no Onboarding.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.bairro});

  final String bairro;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(bairro: widget.bairro),
      FeedScreen(bairro: widget.bairro),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.dynamic_feed_outlined), selectedIcon: Icon(Icons.dynamic_feed), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
