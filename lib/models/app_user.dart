import 'package:cloud_firestore/cloud_firestore.dart';

/// Documento da colecao `users`.
class AppUser {
  final String id;
  final String displayName;
  final String? photoUrl;
  final int points;
  final List<String> badges;
  final String? bairroPreferido;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.displayName,
    this.photoUrl,
    this.points = 0,
    this.badges = const [],
    this.bairroPreferido,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      id: doc.id,
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      points: (data['points'] as num?)?.toInt() ?? 0,
      badges: List<String>.from(data['badges'] as List? ?? const []),
      bairroPreferido: data['bairroPreferido'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'points': points,
      'badges': badges,
      'bairroPreferido': bairroPreferido,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({
    String? displayName,
    String? photoUrl,
    int? points,
    List<String>? badges,
    String? bairroPreferido,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      bairroPreferido: bairroPreferido ?? this.bairroPreferido,
      createdAt: createdAt,
    );
  }
}
