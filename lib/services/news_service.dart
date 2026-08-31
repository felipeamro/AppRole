import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/news_item.dart';
import 'firestore_paths.dart';

/// Operacoes sobre a colecao `newsFeed`.
class NewsService {
  NewsService({FirebaseFirestore? firestore}) : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.newsFeed);

  /// Feed hyperlocal de um bairro, mais recente primeiro.
  Stream<List<NewsItem>> watchByBairro(String bairro) {
    return _collection
        .where('bairro', isEqualTo: bairro)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map(NewsItem.fromFirestore).toList());
  }

  Future<String> create(NewsItem item) async {
    final docRef = await _collection.add(item.toMap());
    return docRef.id;
  }

  Future<void> upvote(String newsId) {
    return _collection.doc(newsId).update({
      'upvotes': FieldValue.increment(1),
    });
  }
}
