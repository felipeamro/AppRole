import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import 'firestore_paths.dart';

/// Operacoes sobre a colecao `users`.
class UserService {
  UserService({FirebaseFirestore? firestore}) : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.users);

  Stream<AppUser?> watchUser(String uid) {
    return _collection.doc(uid).snapshots().map(
      (doc) => doc.exists ? AppUser.fromFirestore(doc) : null,
    );
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _collection.doc(uid).get();
    return doc.exists ? AppUser.fromFirestore(doc) : null;
  }

  /// Cria o documento do usuario se ele ainda nao existir.
  Future<AppUser> createIfMissing({
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    final docRef = _collection.doc(uid);
    final doc = await docRef.get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }

    final user = AppUser(
      id: uid,
      displayName: displayName,
      photoUrl: photoUrl,
      points: 0,
      badges: const [],
      createdAt: DateTime.now(),
    );
    await docRef.set(user.toMap());
    return user;
  }

  Future<void> updateBairroPreferido(String uid, String bairro) {
    return _collection.doc(uid).update({'bairroPreferido': bairro});
  }

  Future<void> addPoints(String uid, int amount) {
    return _collection.doc(uid).update({'points': FieldValue.increment(amount)});
  }

  Future<void> addBadge(String uid, String badge) {
    return _collection.doc(uid).update({
      'badges': FieldValue.arrayUnion([badge]),
    });
  }
}
