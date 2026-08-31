import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/route_model.dart';
import '../models/route_report.dart';
import 'firestore_paths.dart';

/// Operacoes sobre as colecoes `routes` e `routeReports`.
class RouteService {
  RouteService({FirebaseFirestore? firestore}) : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _routes =>
      _firestore.collection(FirestorePaths.routes);

  CollectionReference<Map<String, dynamic>> get _routeReports =>
      _firestore.collection(FirestorePaths.routeReports);

  Stream<RouteModel?> watchRoute(String routeId) {
    return _routes.doc(routeId).snapshots().map(
      (doc) => doc.exists ? RouteModel.fromFirestore(doc) : null,
    );
  }

  Stream<List<RouteReport>> watchRouteReports(String routeId) {
    return _routeReports
        .where('routeId', isEqualTo: routeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(RouteReport.fromFirestore).toList());
  }

  Future<String> createRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final route = RouteModel(
      id: '',
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
      safetyScore: 0,
      reports: const [],
    );
    final docRef = await _routes.add(route.toMap());
    return docRef.id;
  }

  Future<String> addRouteReport({
    required String routeId,
    required String userId,
    required RouteReportType type,
    required String value,
  }) async {
    final report = RouteReport(
      id: '',
      routeId: routeId,
      userId: userId,
      type: type,
      value: value,
      createdAt: DateTime.now(),
    );
    final docRef = await _routeReports.add(report.toMap());
    await _routes.doc(routeId).update({
      'reports': FieldValue.arrayUnion([docRef.id]),
    });
    return docRef.id;
  }
}
