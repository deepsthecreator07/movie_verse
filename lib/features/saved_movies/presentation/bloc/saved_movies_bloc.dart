import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/saved_movie_repository.dart';
import 'saved_movies_event.dart';
import 'saved_movies_state.dart';

class SavedMoviesBloc extends Bloc<SavedMoviesEvent, SavedMoviesState> {
  final SavedMovieRepository _repository;
  StreamSubscription? _subscription;

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

    _subscription?.cancel();
    _subscription = _repository.watchSavedMovies(event.userId).listen(
      (movies) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(SavedMoviesLoaded(movies));
      },
      onError: (e) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(SavedMoviesError(e.toString()));
      },
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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
