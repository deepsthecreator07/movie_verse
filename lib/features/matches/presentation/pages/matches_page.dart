import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_state.dart';

/// PAGE 06 — Movies saved by 2+ users (Matches).
class MatchesPage extends StatelessWidget {
  final void Function(MovieEntity movie) onMovieTap;

  const MatchesPage({super.key, required this.onMovieTap});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.favorite, color: AppColors.accent, size: 22),
            const SizedBox(width: 8),
            Text('Matches', style: AppTextStyles.headlineMedium),
          ],
        ),
      ),
      body: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is MatchesError) {
            return EmptyState(icon: Icons.error_outline, title: 'Error', subtitle: state.message);
          }

          if (state is MatchesLoaded) {
            if (state.matches.isEmpty) {
              return const EmptyState(
                icon: Icons.favorite_border,
                title: 'No matches yet',
                subtitle: 'When multiple users save the same movie, it\'ll appear here as a match!',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              itemCount: state.matches.length,
              itemBuilder: (context, index) {
                final match = state.matches[index];
                final isTopPick = match.saveCount == match.totalAppUsers && match.totalAppUsers > 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isTopPick
                        ? AppColors.accent.withValues(alpha: 0.08)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      onTap: () => onMovieTap(match.movie),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Poster
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: match.movie.posterPath.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: '${ApiConstants.posterW342}${match.movie.posterPath}',
                                      width: 60, height: 90, fit: BoxFit.cover,
                                    )
                                  : Container(width: 60, height: 90, color: AppColors.surfaceLight),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isTopPick)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('🏆 TOP PICK', style: AppTextStyles.badge.copyWith(color: Colors.black)),
                                    ),
                                  Text(match.movie.title, style: AppTextStyles.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('${match.saveCount} users want to watch', style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent)),
                                  const SizedBox(height: 8),
                                  // User avatars
                                  SizedBox(
                                    height: 28,
                                    child: Row(
                                      children: [
                                        ...match.users.take(5).map((user) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 4),
                                            child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: AppColors.surfaceLight,
                                              child: user.avatarUrl.isNotEmpty
                                                  ? ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl: user.avatarUrl,
                                                        width: 28, height: 28, fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : Text(user.firstName.isNotEmpty ? user.firstName[0] : '?',
                                                      style: AppTextStyles.badge.copyWith(color: AppColors.primary)),
                                            ),
                                          );
                                        }),
                                        if (match.users.length > 5)
                                          Text('+${match.users.length - 5}', style: AppTextStyles.labelSmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
      ),
    );
  }
}
