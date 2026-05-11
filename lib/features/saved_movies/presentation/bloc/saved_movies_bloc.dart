import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/saved_movie_repository.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import 'saved_movies_event.dart';
import 'saved_movies_state.dart';

class SavedMoviesBloc extends Bloc<SavedMoviesEvent, SavedMoviesState> {
  final SavedMovieRepository _repository;

  SavedMoviesBloc({required SavedMovieRepository repository})
      : _repository = repository,
        super(const SavedMoviesInitial()) {
    on<LoadSavedMovies>(_onLoad);
    on<UnsaveMovie>(_onUnsave);
  }

  Future<void> _onLoad(
    LoadSavedMovies event,
    Emitter<SavedMoviesState> emit,
  ) async {
    emit(const SavedMoviesLoading());

    await emit.forEach<List<MovieEntity>>(
      _repository.watchSavedMovies(event.userId),
      onData: (movies) => SavedMoviesLoaded(movies),
      onError: (e, _) => SavedMoviesError(e.toString()),
    );
  }

  Future<void> _onUnsave(
    UnsaveMovie event,
    Emitter<SavedMoviesState> emit,
  ) async {
    try {
      await _repository.unsaveMovie(event.userId, event.movieId);
    } catch (e) {
      emit(SavedMoviesError(e.toString()));
    }
  }
}
