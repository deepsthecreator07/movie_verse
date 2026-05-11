import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';

/// PAGE 01 — Users list with pagination and staggered animations.
class UsersPage extends StatefulWidget {
  final void Function(UserEntity user) onUserTap;
  final VoidCallback onAddUser;
  final VoidCallback onMatchesTap;

  const UsersPage({
    super.key,
    required this.onUserTap,
    required this.onAddUser,
    required this.onMatchesTap,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<UsersBloc>().add(const LoadMoreUsers());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.movie_filter, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text('MovieVerse', style: AppTextStyles.headlineMedium),
          ],
        ),
        actions: [
          _buildMatchesButton(),
        ],
      ),
      body: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UserAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.user.fullName} added!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                backgroundColor: AppColors.surfaceElevated,
                behavior: SnackBarBehavior.floating,
                duration: AppConstants.snackbarDuration,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UsersLoading) {
            return _buildShimmerList();
          }

          if (state is UsersError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Something went wrong',
              subtitle: state.message,
              actionLabel: 'Retry',
              onAction: () =>
                  context.read<UsersBloc>().add(const LoadUsers()),
            );
          }

          if (state is UsersLoaded) {
            if (state.users.isEmpty) {
              return EmptyState(
                icon: Icons.people_outline,
                title: 'No users yet',
                subtitle: 'Add a user to start saving movies!',
                actionLabel: 'Add User',
                onAction: widget.onAddUser,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<UsersBloc>().add(const LoadUsers());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.primary,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingMd,
                ),
                itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.users.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }

                  return _UserListTile(
                    user: state.users[index],
                    index: index,
                    onTap: () => widget.onUserTap(state.users[index]),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAddUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildMatchesButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: widget.onMatchesTap,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.favorite,
            color: AppColors.accent,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const ShimmerLoading(width: 56, height: 56, borderRadius: 28),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(width: 150, height: 16),
                  SizedBox(height: 8),
                  ShimmerLoading(width: 100, height: 12),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated user list tile with staggered entrance.
class _UserListTile extends StatefulWidget {
  final UserEntity user;
  final int index;
  final VoidCallback onTap;

  const _UserListTile({
    required this.user,
    required this.index,
    required this.onTap,
  });

  @override
  State<_UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<_UserListTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Staggered delay
    Future.delayed(
      Duration(milliseconds: widget.index * AppConstants.staggerDelay.inMilliseconds),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMd,
            vertical: 4,
          ),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              splashColor: AppColors.primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                child: Row(
                  children: [
                    // Avatar
                    Hero(
                      tag: 'user_avatar_${widget.user.id}',
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.surfaceLight,
                        child: widget.user.avatarUrl.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: widget.user.avatarUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const ShimmerLoading(
                                    width: 56,
                                    height: 56,
                                    borderRadius: 28,
                                  ),
                                ),
                              )
                            : Text(
                                widget.user.firstName.isNotEmpty
                                    ? widget.user.firstName[0].toUpperCase()
                                    : '?',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.fullName,
                            style: AppTextStyles.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.email,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.user.movieTaste.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.user.movieTaste,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Sync indicator
                    if (widget.user.pendingSync)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.warning,
                          size: 20,
                        ),
                      ),

                    // Chevron
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
