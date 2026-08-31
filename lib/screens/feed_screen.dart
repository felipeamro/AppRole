import 'package:flutter/material.dart';

import '../models/news_item.dart';
import '../services/news_service.dart';
import '../widgets/news_story_card.dart';
import '../widgets/trocar_bairro_action.dart';

/// Feed de noticias hyperlocal do bairro: eventos, transito, cultura e furos
/// enviados pela comunidade, em cards estilo stories.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.bairro});

  final String bairro;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _newsService = NewsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed · ${widget.bairro}'),
        actions: [TrocarBairroChip(bairroAtual: widget.bairro)],
      ),
      body: StreamBuilder<List<NewsItem>>(
        stream: _newsService.watchByBairro(widget.bairro),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final news = snapshot.data ?? const [];
          if (news.isEmpty) {
            return const Center(
              child: Text('Nenhuma novidade por aqui ainda.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: news.length,
            itemBuilder: (context, index) {
              final item = news[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NewsStoryCard(
                  news: item,
                  onUpvote: () => _newsService.upvote(item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
