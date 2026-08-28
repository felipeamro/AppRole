import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de report feito em um estabelecimento.
enum ReportType {
  lotacao,
  fila,
  preco,
  vibe,
  promocao;

  static ReportType fromValue(String? value) {
    return ReportType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportType.vibe,
    );
  }
}

/// Documento da colecao `reports`.
class Report {
  final String id;
  final String establishmentId;
  final String userId;
  final ReportType type;
  final String value;
  final int confirmations;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const Report({
    required this.id,
    required this.establishmentId,
    required this.userId,
    required this.type,
    required this.value,
    this.confirmations = 0,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  factory Report.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Report(
      id: doc.id,
      establishmentId: data['establishmentId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      type: ReportType.fromValue(data['type'] as String?),
      value: data['value']?.toString() ?? '',
      confirmations: (data['confirmations'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'establishmentId': establishmentId,
      'userId': userId,
      'type': type.name,
      'value': value,
      'confirmations': confirmations,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt == null ? null : Timestamp.fromDate(expiresAt!),
    };
  }
}
