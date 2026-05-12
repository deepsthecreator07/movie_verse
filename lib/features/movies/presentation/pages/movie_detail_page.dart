import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../domain/entities/movie_entity.dart';

/// PAGE 04 — Movie Detail with Hero animation and savers section.
class MovieDetailPage extends StatelessWidget {
  final MovieEntity movie;
  final bool isSaved;
  final VoidCallback? onToggleSave;
  /// Stream of users who have saved this movie (reactive, from local DB).
  final Stream<List<UserEntity>> saversStream;

  const MovieDetailPage({
    super.key,
    required this.movie,
    this.isSaved = false,
    this.onToggleSave,
    required this.saversStream,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
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
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
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
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceLight,
                              child: const Center(
                                child: Icon(Icons.movie, color: AppColors.textTertiary, size: 80),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceLight,
                            child: const Center(
                              child: Icon(Icons.movie, color: AppColors.textTertiary, size: 80),
                            ),
                          ),
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
                  if (onToggleSave != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          onToggleSave?.call();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isSaved ? 'Movie removed from watchlist' : 'Movie saved to watchlist'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
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
                  ],

                  // Savers section — reactive
                  StreamBuilder<List<UserEntity>>(
                    stream: saversStream,
                    builder: (context, snapshot) {
                      final savers = snapshot.data ?? [];
                      return _SaversSection(savers: savers);
                    },
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
      ),
    );
  }
}

/// Displays the list of users who saved this movie with small avatars.
class _SaversSection extends StatelessWidget {
  final List<UserEntity> savers;
  const _SaversSection({required this.savers});

  @override
  Widget build(BuildContext context) {
    if (savers.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.star_border, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 8),
          Text('Be the first to save this.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      );
    }

    final preview = savers.take(4).toList();
    final extra = savers.length - preview.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${savers.length} ${savers.length == 1 ? 'user wants' : 'users want'} to watch this',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Stacked avatars
            SizedBox(
              height: 36,
              width: (preview.length * 24.0) + 12 + (extra > 0 ? 36 : 0),
              child: Stack(
                children: [
                  for (int i = 0; i < preview.length; i++)
                    Positioned(
                      left: i * 24.0,
                      child: _SaverAvatar(user: preview[i]),
                    ),
                  if (extra > 0)
                    Positioned(
                      left: preview.length * 24.0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                        child: Center(
                          child: Text('+$extra', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SaverAvatar extends StatelessWidget {
  final UserEntity user;
  const _SaverAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.surfaceLight,
        child: user.avatarUrl.isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              )
            : Text(
                user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
              ),
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

