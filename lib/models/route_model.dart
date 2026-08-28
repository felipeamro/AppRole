import 'package:cloud_firestore/cloud_firestore.dart';

/// Documento da colecao `routes`.
class RouteModel {
  final String id;
  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;
  final double safetyScore;
  final List<String> reports;

  const RouteModel({
    required this.id,
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
    this.safetyScore = 0,
    this.reports = const [],
  });

  factory RouteModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return RouteModel(
      id: doc.id,
      fromLat: (data['fromLat'] as num?)?.toDouble() ?? 0,
      fromLng: (data['fromLng'] as num?)?.toDouble() ?? 0,
      toLat: (data['toLat'] as num?)?.toDouble() ?? 0,
      toLng: (data['toLng'] as num?)?.toDouble() ?? 0,
      safetyScore: (data['safetyScore'] as num?)?.toDouble() ?? 0,
      reports: List<String>.from(data['reports'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromLat': fromLat,
      'fromLng': fromLng,
      'toLat': toLat,
      'toLng': toLng,
      'safetyScore': safetyScore,
      'reports': reports,
    };
  }
}
