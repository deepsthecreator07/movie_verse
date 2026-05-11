import 'package:drift/drift.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_source.dart';

/// Concrete implementation of MovieRepository.
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteSource remoteSource;
  final AppDatabase database;
  final ConnectivityService connectivity;

  MovieRepositoryImpl({
    required this.remoteSource,
    required this.database,
    required this.connectivity,
  });

  @override
  Future<List<MovieEntity>> getMovies({required int page}) async {
    if (connectivity.isOnline) {
      try {
        final response = await remoteSource.getTrendingMovies(page: page);

        // Cache movies locally
        final companions = response.results.map((m) {
          return MoviesCompanion(
            id: Value(m.id),
            title: Value(m.title),
            overview: Value(m.overview),
            posterPath: Value(m.posterPath),
            backdropPath: Value(m.backdropPath),
            releaseDate: Value(m.releaseDate),
            voteAverage: Value(m.voteAverage),
            voteCount: Value(m.voteCount),
          );
        }).toList();

        await database.upsertMovies(companions);

        return response.results.map((m) => m.toEntity()).toList();
      } catch (_) {
        return _getCachedMovieEntities();
      }
    } else {
      return _getCachedMovieEntities();
    }
  }

  @override
  Future<MovieEntity?> getMovieById(int movieId) async {
    // Check cache first
    final cached = await database.getMovieById(movieId);
    if (cached != null) return _movieToEntity(cached);

    if (connectivity.isOnline) {
      try {
        final model = await remoteSource.getMovieById(movieId);

        // Cache it
        await database.upsertMovie(
          MoviesCompanion(
            id: Value(model.id),
            title: Value(model.title),
            overview: Value(model.overview),
            posterPath: Value(model.posterPath),
            backdropPath: Value(model.backdropPath),
            releaseDate: Value(model.releaseDate),
            voteAverage: Value(model.voteAverage),
            voteCount: Value(model.voteCount),
          ),
        );

        return model.toEntity();
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  @override
  Future<List<MovieEntity>> getCachedMovies() => _getCachedMovieEntities();

  Future<List<MovieEntity>> _getCachedMovieEntities() async {
    final movies = await database.getCachedMovies();
    return movies.map(_movieToEntity).toList();
  }

  MovieEntity _movieToEntity(Movy m) {
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
  }
}
