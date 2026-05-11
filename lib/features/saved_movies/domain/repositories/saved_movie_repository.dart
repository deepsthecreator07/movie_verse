import '../../../movies/domain/entities/movie_entity.dart';

/// Abstract repository for saved movie operations.
abstract class SavedMovieRepository {
  /// Save a movie for a user.
  Future<void> saveMovie(int userId, int movieId);

  /// Unsave a movie for a user.
  Future<void> unsaveMovie(int userId, int movieId);

  /// Check if a movie is saved by a user.
  Future<bool> isMovieSaved(int userId, int movieId);

  /// Watch saved movies for a user.
  Stream<List<MovieEntity>> watchSavedMovies(int userId);

  /// Watch saved movie IDs for a user (for quick toggle checks).
  Stream<Set<int>> watchSavedMovieIds(int userId);

  /// Get the save count for a movie.
  Future<int> getSaveCount(int movieId);
}
