import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/points_badges_summary.dart';
import '../widgets/trocar_bairro_action.dart';

/// Perfil do usuario: pontos acumulados, badges conquistadas e bairro
/// preferido.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: uid == null
          ? const Center(child: Text('Faça onboarding para criar seu perfil.'))
          : StreamBuilder<AppUser?>(
              stream: _userService.watchUser(uid),
              builder: (context, snapshot) {
                final user = snapshot.data;
                if (user == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            child: user.photoUrl == null
                                ? const Icon(Icons.person, size: 32)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (user.bairroPreferido != null)
                                Text('Bairro: ${user.bairroPreferido}'),
                              TextButton.icon(
                                onPressed: () => goToTrocarBairro(context, user.bairroPreferido),
                                icon: const Icon(Icons.sync_alt, size: 18),
                                label: const Text('Trocar bairro'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      PointsBadgesSummary(user: user),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
