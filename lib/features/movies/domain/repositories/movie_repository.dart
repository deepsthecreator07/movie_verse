import '../entities/movie_entity.dart';

/// Abstract repository for movie operations.
abstract class MovieRepository {
  /// Fetch trending movies from TMDB API, cache locally.
  /// Falls back to cache when offline.
  Future<List<MovieEntity>> getMovies({required int page});

  /// Get a single movie by ID (from cache or API).
  Future<MovieEntity?> getMovieById(int movieId);

  /// Get all cached movies.
  Future<List<MovieEntity>> getCachedMovies();
}
