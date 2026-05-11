import '../../../../database/app_database.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../domain/repositories/saved_movie_repository.dart';

/// Concrete implementation of SavedMovieRepository.
class SavedMovieRepositoryImpl implements SavedMovieRepository {
  final AppDatabase database;

  SavedMovieRepositoryImpl({required this.database});

  @override
  Future<void> saveMovie(int userId, int movieId) {
    return database.saveMovieForUser(userId, movieId);
  }

  @override
  Future<void> unsaveMovie(int userId, int movieId) {
    return database.unsaveMovieForUser(userId, movieId);
  }

  @override
  Future<bool> isMovieSaved(int userId, int movieId) {
    return database.isMovieSavedByUser(userId, movieId);
  }

  @override
  Stream<List<MovieEntity>> watchSavedMovies(int userId) {
    return database.watchSavedMoviesForUser(userId).map((movies) {
      return movies.map((m) {
        return MovieEntity(
          id: m.id,
          title: m.title,
          overview: m.overview,
          posterPath: m.posterPath,
          backdropPath: m.backdropPath,
          releaseDate: m.releaseDate,
          voteAverage: m.voteAverage,
          voteCount: m.voteCount,
        );
      }).toList();
    });
  }

  @override
  Stream<Set<int>> watchSavedMovieIds(int userId) {
    return database.watchSavedMovieIdsForUser(userId);
  }

  @override
  Future<int> getSaveCount(int movieId) {
    return database.getSaveCountForMovie(movieId);
  }
}
