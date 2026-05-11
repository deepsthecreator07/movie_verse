import 'package:equatable/equatable.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

/// Load trending movies (first page).
class LoadMovies extends MoviesEvent {
  final int userId;

  const LoadMovies({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Load next page of movies.
class LoadMoreMovies extends MoviesEvent {
  const LoadMoreMovies();
}

/// Toggle save/unsave a movie for the current user.
class ToggleSaveMovie extends MoviesEvent {
  final int userId;
  final int movieId;

  const ToggleSaveMovie({required this.userId, required this.movieId});

  @override
  List<Object?> get props => [userId, movieId];
}
