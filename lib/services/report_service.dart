import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report.dart';
import 'firestore_paths.dart';

/// Operacoes sobre a colecao `reports`.
class ReportService {
  ReportService({FirebaseFirestore? firestore}) : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.reports);

  /// Reports recentes de um estabelecimento, do mais novo para o mais antigo.
  Stream<List<Report>> watchByEstablishment(String establishmentId) {
    return _collection
        .where('establishmentId', isEqualTo: establishmentId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(Report.fromFirestore).toList());
  }

  Future<String> create({
    required String establishmentId,
    required String userId,
    required ReportType type,
    required String value,
    Duration validity = const Duration(hours: 2),
  }) async {
    final now = DateTime.now();
    final report = Report(
      id: '',
      establishmentId: establishmentId,
      userId: userId,
      type: type,
      value: value,
      confirmations: 0,
      createdAt: now,
      expiresAt: now.add(validity),
    );
    final docRef = await _collection.add(report.toMap());
    return docRef.id;
  }

  Future<void> confirm(String reportId) {
    return _collection.doc(reportId).update({
      'confirmations': FieldValue.increment(1),
    });
  }
}
