import 'package:equatable/equatable.dart';
import '../../../movies/domain/entities/movie_entity.dart';

abstract class SavedMoviesState extends Equatable {
  const SavedMoviesState();
  @override
  List<Object?> get props => [];
}

class SavedMoviesInitial extends SavedMoviesState {
  const SavedMoviesInitial();
}

class SavedMoviesLoading extends SavedMoviesState {
  const SavedMoviesLoading();
}

class SavedMoviesLoaded extends SavedMoviesState {
  final List<MovieEntity> movies;
  const SavedMoviesLoaded(this.movies);
  @override
  List<Object?> get props => [movies];
}

class SavedMoviesError extends SavedMoviesState {
  final String message;
  const SavedMoviesError(this.message);
  @override
  List<Object?> get props => [message];
}
