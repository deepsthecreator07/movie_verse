import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../bloc/saved_movies_bloc.dart';
import '../bloc/saved_movies_event.dart';
import '../bloc/saved_movies_state.dart';

/// PAGE 05 — Saved Movies for a specific user.
class SavedMoviesPage extends StatelessWidget {
  final UserEntity user;
  final void Function(int movieId) onMovieTap;

  const SavedMoviesPage({
    super.key,
    required this.user,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.firstName}\'s Watchlist', style: AppTextStyles.headlineMedium),
      ),
      body: BlocBuilder<SavedMoviesBloc, SavedMoviesState>(
        builder: (context, state) {
          if (state is SavedMoviesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is SavedMoviesError) {
            return EmptyState(icon: Icons.error_outline, title: 'Error', subtitle: state.message);
          }

          if (state is SavedMoviesLoaded) {
            if (state.movies.isEmpty) {
              return const EmptyState(
                icon: Icons.bookmark_border,
                title: 'No saved movies yet',
                subtitle: 'Browse movies and tap the bookmark to save them here.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              itemCount: state.movies.length,
              itemBuilder: (context, index) {
                final movie = state.movies[index];
                return Dismissible(
                  key: ValueKey(movie.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<SavedMoviesBloc>().add(
                      UnsaveMovie(userId: user.id, movieId: movie.id),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${movie.title} removed')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        onTap: () => onMovieTap(movie.id),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: movie.posterPath.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: '${ApiConstants.posterW342}${movie.posterPath}',
                                        width: 60, height: 90, fit: BoxFit.cover,
                                      )
                                    : Container(width: 60, height: 90, color: AppColors.surfaceLight,
                                        child: const Icon(Icons.movie, color: AppColors.textTertiary)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(movie.title, style: AppTextStyles.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    if (movie.year.isNotEmpty) Text(movie.year, style: AppTextStyles.bodySmall),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: AppColors.accent),
                                        const SizedBox(width: 4),
                                        Text(movie.voteAverage.toStringAsFixed(1), style: AppTextStyles.labelMedium),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
