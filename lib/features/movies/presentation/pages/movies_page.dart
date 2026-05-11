import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../database/app_database.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../domain/entities/movie_entity.dart';
import '../bloc/movies_bloc.dart';
import '../bloc/movies_event.dart';
import '../bloc/movies_state.dart';

/// PAGE 03 — Movie browsing with save/unsave.
class MoviesPage extends StatefulWidget {
  final UserEntity user;
  final void Function(MovieEntity movie) onMovieTap;
  final VoidCallback onSavedMoviesTap;

  const MoviesPage({
    super.key,
    required this.user,
    required this.onMovieTap,
    required this.onSavedMoviesTap,
  });

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<MoviesBloc>().add(const LoadMoreMovies());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.firstName}\'s Movies', style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            onPressed: widget.onSavedMoviesTap,
            tooltip: 'Saved Movies',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bookmark, color: AppColors.accent, size: 20),
            ),
          ),
        ],
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is MoviesLoading) return _buildShimmerGrid();

          if (state is MoviesError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load movies',
              subtitle: state.message,
              actionLabel: 'Retry',
              onAction: () => context.read<MoviesBloc>().add(LoadMovies(userId: widget.user.id)),
            );
          }

          if (state is MoviesLoaded) {
            if (state.movies.isEmpty) {
              return const EmptyState(
                icon: Icons.movie_outlined,
                title: 'No movies found',
                subtitle: 'Check your connection and try again.',
              );
            }

            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.movies.length + (state.isLoadingMore ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= state.movies.length) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final movie = state.movies[index];
                final isSaved = state.savedMovieIds.contains(movie.id);
                return _MovieCard(
                  movie: movie,
                  isSaved: isSaved,
                  saveCountStream: getIt<AppDatabase>().watchSaveCountForMovie(movie.id),
                  onTap: () => widget.onMovieTap(movie),
                  onSave: () => context.read<MoviesBloc>().add(
                    ToggleSaveMovie(userId: widget.user.id, movieId: movie.id),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.55, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerLoading(width: double.infinity, height: 280, borderRadius: 16),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieEntity movie;
  final bool isSaved;
  final Stream<int> saveCountStream;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const _MovieCard({
    required this.movie,
    required this.isSaved,
    required this.saveCountStream,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Poster ────────────────────────────────────
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'movie_poster_${movie.id}',
                    child: movie.posterPath.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: '${ApiConstants.posterW342}${movie.posterPath}',
                            fit: BoxFit.cover,
                            fadeInDuration: AppConstants.fadeInDuration,
                            placeholder: (_, __) => Container(color: AppColors.surfaceLight),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceLight,
                              child: const Icon(Icons.movie, color: AppColors.textTertiary, size: 40),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceLight,
                            child: const Icon(Icons.movie, color: AppColors.textTertiary, size: 40),
                          ),
                  ),
                  // Star rating badge — bottom-left
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: AppColors.accent, size: 12),
                          const SizedBox(width: 3),
                          Text(movie.voteAverage.toStringAsFixed(1), style: AppTextStyles.badge),
                        ],
                      ),
                    ),
                  ),
                  // Save button — top-right
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: onSave,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSaved ? AppColors.accent : Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.white, size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Info row ──────────────────────────────────
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      movie.title,
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Year + savers count on the same row
                    Row(
                      children: [
                        if (movie.year.isNotEmpty) ...[
                          Text(movie.year, style: AppTextStyles.bodySmall),
                          const Spacer(),
                        ],
                        // Savers count — live stream from DB
                        StreamBuilder<int>(
                          stream: saveCountStream,
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Row(
                                key: ValueKey(count),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 12,
                                    color: count > 0 ? AppColors.accent : AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$count saved',
                                    style: AppTextStyles.badge.copyWith(
                                      color: count > 0 ? AppColors.accent : AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
    );
  }
}
