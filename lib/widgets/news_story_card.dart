import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/news_item.dart';

/// Card estilo "stories" para um item do feed hyperlocal.
class NewsStoryCard extends StatelessWidget {
  const NewsStoryCard({
    super.key,
    required this.news,
    required this.onUpvote,
    this.onTap,
  });

  final NewsItem news;
  final VoidCallback onUpvote;
  final VoidCallback? onTap;

  static const _typeLabels = {
    NewsType.evento: 'Evento',
    NewsType.transito: 'Trânsito',
    NewsType.cultura: 'Cultura',
    NewsType.furo: 'Furo',
  };

  static const _typeColors = {
    NewsType.evento: Colors.purple,
    NewsType.transito: Colors.orange,
    NewsType.cultura: Colors.teal,
    NewsType.furo: Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[news.type]!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.mediaUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  news.mediaUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: color.withValues(alpha: 0.15)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _typeLabels[news.type]!,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('HH:mm').format(news.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(news.content, maxLines: 4, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: onUpvote,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('${news.upvotes}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
