import 'package:equatable/equatable.dart';

abstract class SavedMoviesEvent extends Equatable {
  const SavedMoviesEvent();
  @override
  List<Object?> get props => [];
}

class LoadSavedMovies extends SavedMoviesEvent {
  final int userId;
  const LoadSavedMovies({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class UnsaveMovie extends SavedMoviesEvent {
  final int userId;
  final int movieId;
  const UnsaveMovie({required this.userId, required this.movieId});
  @override
  List<Object?> get props => [userId, movieId];
}
