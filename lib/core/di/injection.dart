import 'package:get_it/get_it.dart';
import '../../database/app_database.dart';
import '../network/dio_client.dart';
import '../network/connectivity_service.dart';
import '../../features/users/data/datasources/user_remote_source.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/movies/data/datasources/movie_remote_source.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../../features/saved_movies/data/repositories/saved_movie_repository_impl.dart';
import '../../features/saved_movies/domain/repositories/saved_movie_repository.dart';
import '../../features/matches/data/repositories/matches_repository_impl.dart';
import '../../features/matches/domain/repositories/matches_repository.dart';

final getIt = GetIt.instance;

/// Register all dependencies.
Future<void> setupDependencies() async {
  // ── Core ─────────────────────────────────────────────
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ── Data Sources ─────────────────────────────────────
  getIt.registerLazySingleton<UserRemoteSource>(
    () => UserRemoteSource(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<MovieRemoteSource>(
    () => MovieRemoteSource(getIt<DioClient>()),
  );

  // ── Repositories ─────────────────────────────────────
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteSource: getIt<UserRemoteSource>(),
      database: getIt<AppDatabase>(),
      connectivity: getIt<ConnectivityService>(),
    ),
  );
  getIt.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteSource: getIt<MovieRemoteSource>(),
      database: getIt<AppDatabase>(),
      connectivity: getIt<ConnectivityService>(),
    ),
  );
  getIt.registerLazySingleton<SavedMovieRepository>(
    () => SavedMovieRepositoryImpl(
      database: getIt<AppDatabase>(),
    ),
  );
  getIt.registerLazySingleton<MatchesRepository>(
    () => MatchesRepositoryImpl(
      database: getIt<AppDatabase>(),
    ),
  );
}
