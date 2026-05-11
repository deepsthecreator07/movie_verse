import 'package:equatable/equatable.dart';
import '../../domain/entities/movie_entity.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

class MoviesInitial extends MoviesState {
  const MoviesInitial();
}

class MoviesLoading extends MoviesState {
  const MoviesLoading();
}

class MoviesLoaded extends MoviesState {
  final List<MovieEntity> movies;
  final Set<int> savedMovieIds;
  final Map<int, int> saveCountMap; // movieId → number of savers
  final bool hasMore;
  final bool isLoadingMore;
  final int userId;

  const MoviesLoaded({
    required this.movies,
    required this.savedMovieIds,
    this.saveCountMap = const {},
    this.hasMore = true,
    this.isLoadingMore = false,
    required this.userId,
  });

  MoviesLoaded copyWith({
    List<MovieEntity>? movies,
    Set<int>? savedMovieIds,
    Map<int, int>? saveCountMap,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MoviesLoaded(
      movies: movies ?? this.movies,
      savedMovieIds: savedMovieIds ?? this.savedMovieIds,
      saveCountMap: saveCountMap ?? this.saveCountMap,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [movies, savedMovieIds, saveCountMap, hasMore, isLoadingMore, userId];
}

class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object?> get props => [message];
}
