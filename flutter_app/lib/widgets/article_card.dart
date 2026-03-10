import 'package:flutter/material.dart';

// card for displaying articles - supports both network and asset images
class ArticleCard extends StatelessWidget {
  final String? imageUrl;      // network image url
  final String? imagePath;     // local asset path (fallback)
  final String title;
  final String subtitle;
  final String? source;        // article source name
  final String? timeAgo;       // relative time like "2h ago"
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    this.imageUrl,
    this.imagePath,
    required this.title,
    required this.subtitle,
    this.source,
    this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 280,
      width: 260,
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image section with gradient overlay
              Stack(
                children: [
                  _buildImage(scheme),
                  // subtle gradient at bottom for text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // source badge
                  if (source != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          source!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // text section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
                      ),

                      const Spacer(),

                      // time ago
                      if (timeAgo != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: scheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeAgo!,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.outline,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme scheme) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: 260,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(scheme),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholder(scheme, loading: true);
        },
      );
    } else if (imagePath != null) {
      return Image.asset(
        imagePath!,
        width: 260,
        height: 160,
        fit: BoxFit.cover,
      );
    }
    return _placeholder(scheme);
  }

  Widget _placeholder(ColorScheme scheme, {bool loading = false}) {
    return Container(
      width: 260,
      height: 160,
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.outline,
                ),
              )
            : Icon(
                Icons.article_rounded,
                size: 40,
                color: scheme.outline,
              ),
      ),
    );
  }
}
