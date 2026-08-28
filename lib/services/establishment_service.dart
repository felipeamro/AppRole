import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/establishment.dart';
import 'firestore_paths.dart';

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
}
