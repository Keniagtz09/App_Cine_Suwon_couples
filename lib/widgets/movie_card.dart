import 'package:flutter/material.dart';

import '../core/theme/irworobongdo_theme.dart';
import '../models/movie_model.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  final MovieModel movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (movie.fullPosterUrl.isNotEmpty)
                    Image.network(
                      movie.fullPosterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholderPoster(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: IrworobongdoColors.elevatedIndigo,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: IrworobongdoColors.vermilion,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    _buildPlaceholderPoster(),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: IrworobongdoColors.nightSky.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: IrworobongdoColors.warmGold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: IrworobongdoColors.warmGold,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: textTheme.labelLarge?.copyWith(
                              fontSize: 12,
                              color: IrworobongdoColors.ivory,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    movie.releaseYear,
                    style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPoster() {
    return Container(
      color: IrworobongdoColors.elevatedIndigo,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          size: 40,
          color: IrworobongdoColors.mutedIvory,
        ),
      ),
    );
  }
}