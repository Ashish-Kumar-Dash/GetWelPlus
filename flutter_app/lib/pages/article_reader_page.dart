import 'package:flutter/material.dart';
import 'package:flutter_app/services/article_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// in-app article reader - shows full article content without leaving the app
class ArticleReaderPage extends StatelessWidget {
  final Article article;

  const ArticleReaderPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // collapsing app bar with article image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: scheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // article image or placeholder
                  if (article.imageUrl != null)
                    Image.network(
                      article.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: scheme.primaryContainer,
                        child: Icon(
                          Icons.article_rounded,
                          size: 64,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: scheme.primaryContainer,
                      child: Icon(
                        Icons.article_rounded,
                        size: 64,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  // gradient overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // share button
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  Share.share(
                    '${article.title}\n\nRead more: ${article.url}',
                    subject: article.title,
                  );
                },
              ),
              // open in browser button
              IconButton(
                icon: const Icon(Icons.open_in_browser_rounded),
                onPressed: () => _openInBrowser(article.url),
              ),
            ],
          ),

          // article content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // source and date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article.source,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: scheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.formattedDate,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // title
                  Text(
                    article.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // author if available
                  if (article.author != null && article.author!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: scheme.secondaryContainer,
                            child: Icon(
                              Icons.person_rounded,
                              size: 16,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'By ${article.author}',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Divider(),
                  const SizedBox(height: 16),

                  // description (lead paragraph)
                  Text(
                    article.description,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                      color: scheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // main content
                  Text(
                    article.content,
                    style: textTheme.bodyMedium?.copyWith(
                      height: 1.8,
                      color: scheme.onSurface.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // "read full article" button for complete content
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _openInBrowser(article.url),
                      icon: const Icon(Icons.article_outlined, size: 18),
                      label: const Text('Read Full Article'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
