import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../bloc/saved_movies_bloc.dart';
import '../bloc/saved_movies_event.dart';
import '../bloc/saved_movies_state.dart';

/// PAGE 05 — Saved Movies for a specific user.
class SavedMoviesPage extends StatelessWidget {
  final UserEntity user;
  final void Function(MovieEntity movie) onMovieTap;
  final VoidCallback onBrowseTap;

  const SavedMoviesPage({
    super.key,
    required this.user,
    required this.onMovieTap,
    required this.onBrowseTap,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
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
            Widget userHeader = Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: Row(
                children: [
                  Hero(
                    tag: 'user_avatar_${user.id}',
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.surfaceLight,
                      child: user.avatarUrl.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.avatarUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: AppTextStyles.headlineMedium),
                        if (user.movieTaste.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.movieTaste,
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryLight),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );

            if (state.movies.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  userHeader,
                  const Spacer(),
                  EmptyState(
                    icon: Icons.bookmark_border,
                    title: 'No saved movies yet',
                    subtitle: 'Browse movies and tap the bookmark to save them here.',
                    onAction: onBrowseTap,
                  ),
                  const Spacer(),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                userHeader,
                const Divider(height: 1, color: AppColors.surfaceLight),
                Expanded(
                  child: ListView.builder(
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
                        onTap: () => onMovieTap(movie),
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
            ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onBrowseTap,
        icon: const Icon(Icons.movie_filter),
        label: const Text('Browse Movies'),
      ),
      ),
    );
  }
}
