import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../saved_movies/domain/repositories/saved_movie_repository.dart';
import '../../domain/repositories/movie_repository.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final MovieRepository _movieRepository;
  final SavedMovieRepository _savedMovieRepository;
  int _currentPage = 1;
  StreamSubscription<Set<int>>? _savedIdsSubscription;

  MoviesBloc({
    required MovieRepository movieRepository,
    required SavedMovieRepository savedMovieRepository,
  })  : _movieRepository = movieRepository,
        _savedMovieRepository = savedMovieRepository,
        super(const MoviesInitial()) {
    on<LoadMovies>(_onLoadMovies);
    on<LoadMoreMovies>(_onLoadMoreMovies);
    on<ToggleSaveMovie>(_onToggleSave);
  }

  Future<void> _onLoadMovies(
    LoadMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(const MoviesLoading());
    _currentPage = 1;

    try {
      final movies = await _movieRepository.getMovies(page: _currentPage);
      final savedIds =
          await _savedMovieRepository.watchSavedMovieIds(event.userId).first;

      emit(MoviesLoaded(
        movies: movies,
        savedMovieIds: savedIds,
        hasMore: movies.length >= 20,
        userId: event.userId,
      ));

      // Listen for saved movie changes
      _savedIdsSubscription?.cancel();
      _savedIdsSubscription =
          _savedMovieRepository.watchSavedMovieIds(event.userId).listen((ids) {
        final currentState = state;
        if (currentState is MoviesLoaded) {
          // ignore: invalid_use_of_visible_for_testing_member
          emit(currentState.copyWith(savedMovieIds: ids));
        }
      });
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }

  Future<void> _onLoadMoreMovies(
    LoadMoreMovies event,
    Emitter<MoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesLoaded || !currentState.hasMore) return;
    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    _currentPage++;

    try {
      final newMovies = await _movieRepository.getMovies(page: _currentPage);
      emit(currentState.copyWith(
        movies: [...currentState.movies, ...newMovies],
        hasMore: newMovies.length >= 20,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onToggleSave(
    ToggleSaveMovie event,
    Emitter<MoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesLoaded) return;

    final isSaved = currentState.savedMovieIds.contains(event.movieId);

    // Optimistic update
    final updatedIds = Set<int>.from(currentState.savedMovieIds);
    if (isSaved) {
      updatedIds.remove(event.movieId);
    } else {
      updatedIds.add(event.movieId);
    }
    emit(currentState.copyWith(savedMovieIds: updatedIds));

    try {
      if (isSaved) {
        await _savedMovieRepository.unsaveMovie(event.userId, event.movieId);
      } else {
        await _savedMovieRepository.saveMovie(event.userId, event.movieId);
      }
    } catch (_) {
      // Revert on failure
      emit(currentState.copyWith(savedMovieIds: currentState.savedMovieIds));
    }
  }

  @override
  Future<void> close() {
    _savedIdsSubscription?.cancel();
    return super.close();
  }
}
