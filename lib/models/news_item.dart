import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de post no feed hyperlocal.
enum NewsType {
  evento,
  transito,
  cultura,
  furo;

  static NewsType fromValue(String? value) {
    return NewsType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NewsType.evento,
    );
  }
}

/// Documento da colecao `newsFeed`.
class NewsItem {
  final String id;
  final String bairro;
  final String authorId;
  final NewsType type;
  final String content;
  final String? mediaUrl;
  final String? linkedEstablishmentId;
  final int upvotes;
  final DateTime createdAt;

  const NewsItem({
    required this.id,
    required this.bairro,
    required this.authorId,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.linkedEstablishmentId,
    this.upvotes = 0,
    required this.createdAt,
  });

  factory NewsItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return NewsItem(
      id: doc.id,
      bairro: data['bairro'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      type: NewsType.fromValue(data['type'] as String?),
      content: data['content'] as String? ?? '',
      mediaUrl: data['mediaUrl'] as String?,
      linkedEstablishmentId: data['linkedEstablishmentId'] as String?,
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bairro': bairro,
      'authorId': authorId,
      'type': type.name,
      'content': content,
      'mediaUrl': mediaUrl,
      'linkedEstablishmentId': linkedEstablishmentId,
      'upvotes': upvotes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
