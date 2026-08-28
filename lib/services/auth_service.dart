import 'package:firebase_auth/firebase_auth.dart';

/// Encapsula a autenticacao do app.
///
/// O iVibe usa login anonimo para permitir que qualquer pessoa contribua com
/// reports sem fricção, atribuindo um `uid` estavel a cada usuario.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  User? get currentUser => _firebaseAuth.currentUser;

  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Garante que exista um usuario autenticado, criando uma sessao anonima
  /// caso ainda nao exista nenhuma.
  Future<User> ensureSignedIn() async {
    final existing = _firebaseAuth.currentUser;
    if (existing != null) return existing;

    final credential = await _firebaseAuth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('Falha ao autenticar usuario anonimo.');
    }
    return user;
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
