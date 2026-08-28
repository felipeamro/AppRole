import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de report feito sobre uma rota.
enum RouteReportType {
  iluminacao,
  movimento,
  seguranca;

  static RouteReportType fromValue(String? value) {
    return RouteReportType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RouteReportType.seguranca,
    );
  }
}

/// Documento da colecao `routeReports`.
class RouteReport {
  final String id;
  final String routeId;
  final String userId;
  final RouteReportType type;
  final String value;
  final DateTime createdAt;

  const RouteReport({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.type,
    required this.value,
    required this.createdAt,
  });

  factory RouteReport.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return RouteReport(
      id: doc.id,
      routeId: data['routeId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      type: RouteReportType.fromValue(data['type'] as String?),
      value: data['value']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'userId': userId,
      'type': type.name,
      'value': value,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
