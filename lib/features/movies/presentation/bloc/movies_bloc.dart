import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../database/app_database.dart';
import '../../../saved_movies/domain/repositories/saved_movie_repository.dart';
import '../../domain/repositories/movie_repository.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final MovieRepository _movieRepository;
  final SavedMovieRepository _savedMovieRepository;
  final AppDatabase _database;
  int _currentPage = 1;
  StreamSubscription<Set<int>>? _savedIdsSubscription;
  StreamSubscription<Map<int, int>>? _saveCountSubscription;

  MoviesBloc({
    required MovieRepository movieRepository,
    required SavedMovieRepository savedMovieRepository,
    required AppDatabase database,
  })  : _movieRepository = movieRepository,
        _savedMovieRepository = savedMovieRepository,
        _database = database,
        super(const MoviesInitial()) {
    on<LoadMovies>(_onLoadMovies);
    on<LoadMoreMovies>(_onLoadMoreMovies);
    on<ToggleSaveMovie>(_onToggleSave);
    on<UpdateSavedMovieIds>(_onUpdateSavedMovieIds);
    on<UpdateSaveCounts>(_onUpdateSaveCounts);
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

      // Listen for saved movie ID changes
      _savedIdsSubscription?.cancel();
      _savedIdsSubscription =
          _savedMovieRepository.watchSavedMovieIds(event.userId).listen((ids) {
        if (!isClosed) add(UpdateSavedMovieIds(ids));
      });

      // Listen for aggregate save-count changes across all loaded movies
      _subscribeSaveCounts(movies.map((m) => m.id).toList());
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }

  void _subscribeSaveCounts(List<int> movieIds) {
    _saveCountSubscription?.cancel();
    _saveCountSubscription =
        _database.watchSaveCountsForMovies(movieIds).listen((countMap) {
      if (!isClosed) add(UpdateSaveCounts(countMap));
    });
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
      final allMovies = [...currentState.movies, ...newMovies];
      emit(currentState.copyWith(
        movies: allMovies,
        hasMore: newMovies.length >= 20,
        isLoadingMore: false,
      ));

      // Re-subscribe with expanded movie list
      _subscribeSaveCounts(allMovies.map((m) => m.id).toList());
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

  Future<void> _onUpdateSavedMovieIds(
    UpdateSavedMovieIds event,
    Emitter<MoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is MoviesLoaded) {
      emit(currentState.copyWith(savedMovieIds: event.savedIds));
    }
  }

  Future<void> _onUpdateSaveCounts(
    UpdateSaveCounts event,
    Emitter<MoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is MoviesLoaded) {
      emit(currentState.copyWith(saveCountMap: event.saveCounts));
    }
  }

  @override
  Future<void> close() {
    _savedIdsSubscription?.cancel();
    _saveCountSubscription?.cancel();
    return super.close();
  }
}

