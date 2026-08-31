import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/establishment.dart';
import 'firestore_paths.dart';

/// Numero de confirmacoes distintas necessarias para um estabelecimento
/// cadastrado pela comunidade passar de `verified: false` para `true`.
const int kVerificationThreshold = 15;

/// Operacoes sobre a colecao `establishments`.
class EstablishmentService {
  EstablishmentService({FirebaseFirestore? firestore}) : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.establishments);

  /// Estabelecimentos de um bairro, usados para popular os pins do mapa.
  Stream<List<Establishment>> watchByBairro(String bairro) {
    return _collection
        .where('bairro', isEqualTo: bairro)
        .snapshots()
        .map((s) => s.docs.map(Establishment.fromFirestore).toList());
  }

  Stream<Establishment?> watchById(String id) {
    return _collection.doc(id).snapshots().map(
      (doc) => doc.exists ? Establishment.fromFirestore(doc) : null,
    );
  }

  Future<String> create(Establishment establishment) async {
    final docRef = await _collection.add(establishment.toMap());
    return docRef.id;
  }

  CollectionReference<Map<String, dynamic>> _confirmations(String establishmentId) =>
      _collection.doc(establishmentId).collection('confirmations');

  /// Numero de confirmacoes distintas (1 por usuario, deduplicado pelo uid
  /// como id do documento) que um estabelecimento ja recebeu.
  Stream<int> watchConfirmationCount(String establishmentId) {
    return _confirmations(establishmentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Registra a confirmacao de um usuario de que o estabelecimento existe.
  ///
  /// Um documento por usuario (id = uid) evita que a mesma pessoa conte mais
  /// de uma vez. Ao atingir [kVerificationThreshold] confirmacoes distintas,
  /// marca o estabelecimento como `verified: true`.
  Future<void> confirmExistence({
    required String establishmentId,
    required String userId,
  }) async {
    await _confirmations(establishmentId).doc(userId).set({
      'confirmedAt': Timestamp.now(),
    });

    final countSnapshot = await _confirmations(establishmentId).count().get();
    if ((countSnapshot.count ?? 0) >= kVerificationThreshold) {
      await _collection.doc(establishmentId).update({'verified': true});
    }
  }
}
