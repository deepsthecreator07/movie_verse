import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/movie_entity.dart';

/// PAGE 04 — Movie Detail with Hero animation.
class MovieDetailPage extends StatelessWidget {
  final MovieEntity movie;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing poster header
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'movie_poster_${movie.id}',
                    child: movie.posterPath.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: '${ApiConstants.posterW500}${movie.posterPath}',
                            fit: BoxFit.cover,
                            fadeInDuration: AppConstants.fadeInDuration,
                          )
                        : Container(color: AppColors.surfaceLight),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.posterOverlay),
                  ),
                  Positioned(
                    bottom: 16, left: 16, right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(movie.title, style: AppTextStyles.displayMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (movie.year.isNotEmpty) ...[
                              _InfoChip(icon: Icons.calendar_today, label: movie.year),
                              const SizedBox(width: 12),
                            ],
                            _InfoChip(icon: Icons.star, label: movie.voteAverage.toStringAsFixed(1), color: AppColors.accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onToggleSave,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          key: ValueKey(isSaved),
                        ),
                      ),
                      label: Text(isSaved ? 'Saved' : 'Save to Watchlist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSaved ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),
                  // Overview
                  Text('Overview', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoChip({required this.icon, required this.label, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.white),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
