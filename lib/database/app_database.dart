import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/users_table.dart';
import 'tables/movies_table.dart';
import 'tables/saved_movies_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users, Movies, SavedMovies])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Test constructor
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ═══════════════════════════════════════════════════════════
  //  USER OPERATIONS
  // ═══════════════════════════════════════════════════════════

  /// Watch all users ordered by creation date.
  Stream<List<User>> watchAllUsers() {
    return (select(users)..orderBy([(u) => OrderingTerm.desc(u.createdAt)]))
        .watch();
  }

  /// Get all users (one-shot).
  Future<List<User>> getAllUsers() => select(users).get();

  /// Insert a user; returns the new row ID.
  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  /// Update user by local ID.
  Future<bool> updateUser(User user) => update(users).replace(user);

  /// Get users that haven't been synced to the server.
  Future<List<User>> getPendingSyncUsers() {
    return (select(users)..where((u) => u.pendingSync.equals(true))).get();
  }

  /// Mark a user as synced with their remote ID.
  Future<void> markUserSynced(int localId, int remoteId) {
    return (update(users)..where((u) => u.id.equals(localId))).write(
      UsersCompanion(
        remoteId: Value(remoteId),
        pendingSync: const Value(false),
      ),
    );
  }

  /// Check if a user with the given email exists.
  Future<User?> getUserByEmail(String email) {
    return (select(users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  /// Upsert a user from remote API (by remoteId).
  Future<void> upsertRemoteUser(UsersCompanion user) async {
    final existing = await (select(users)
          ..where(
              (u) => u.remoteId.equals(user.remoteId.value!)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(users)..where((u) => u.id.equals(existing.id)))
          .write(user);
    } else {
      await into(users).insert(user);
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  MOVIE OPERATIONS
  // ═══════════════════════════════════════════════════════════

  /// Insert or update a movie in the cache.
  Future<void> upsertMovie(MoviesCompanion movie) {
    return into(movies).insertOnConflictUpdate(movie);
  }

  /// Insert multiple movies at once.
  Future<void> upsertMovies(List<MoviesCompanion> movieList) async {
    await batch((batch) {
      for (final movie in movieList) {
        batch.insert(movies, movie, onConflict: DoUpdate((_) => movie));
      }
    });
  }

  /// Get all cached movies.
  Future<List<Movy>> getCachedMovies() => select(movies).get();

  /// Get a single movie by TMDB ID.
  Future<Movy?> getMovieById(int movieId) {
    return (select(movies)..where((m) => m.id.equals(movieId)))
        .getSingleOrNull();
  }

  // ═══════════════════════════════════════════════════════════
  //  SAVED MOVIE OPERATIONS
  // ═══════════════════════════════════════════════════════════

  /// Save a movie for a user.
  Future<int> saveMovieForUser(int userId, int movieId) {
    return into(savedMovies).insert(
      SavedMoviesCompanion(
        userId: Value(userId),
        movieId: Value(movieId),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Remove a saved movie for a user.
  Future<int> unsaveMovieForUser(int userId, int movieId) {
    return (delete(savedMovies)
          ..where(
              (s) => s.userId.equals(userId) & s.movieId.equals(movieId)))
        .go();
  }

  /// Check if a specific movie is saved by a user.
  Future<bool> isMovieSavedByUser(int userId, int movieId) async {
    final result = await (select(savedMovies)
          ..where(
              (s) => s.userId.equals(userId) & s.movieId.equals(movieId)))
        .getSingleOrNull();
    return result != null;
  }

  /// Watch saved movies for a specific user (with movie details).
  Stream<List<Movy>> watchSavedMoviesForUser(int userId) {
    final query = select(movies).join([
      innerJoin(savedMovies, savedMovies.movieId.equalsExp(movies.id)),
    ])
      ..where(savedMovies.userId.equals(userId))
      ..orderBy([OrderingTerm.desc(savedMovies.savedAt)]);

    return query.map((row) => row.readTable(movies)).watch();
  }

  /// Get the number of users who saved a specific movie.
  Future<int> getSaveCountForMovie(int movieId) async {
    final count = savedMovies.id.count();
    final query = selectOnly(savedMovies)
      ..addColumns([count])
      ..where(savedMovies.movieId.equals(movieId));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Watch movies saved by 2+ users (matches).
  Stream<List<MovieMatch>> watchMatches() {
    final query = customSelect(
      'SELECT m.*, COUNT(sm.user_id) as save_count '
      'FROM movies m '
      'INNER JOIN saved_movies sm ON sm.movie_id = m.id '
      'GROUP BY m.id '
      'HAVING COUNT(sm.user_id) >= 2 '
      'ORDER BY save_count DESC',
      readsFrom: {movies, savedMovies},
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        return MovieMatch(
          movie: Movy(
            id: row.read<int>('id'),
            title: row.read<String>('title'),
            overview: row.read<String>('overview'),
            posterPath: row.read<String>('poster_path'),
            backdropPath: row.read<String>('backdrop_path'),
            releaseDate: row.read<String>('release_date'),
            voteAverage: row.read<double>('vote_average'),
            voteCount: row.read<int>('vote_count'),
            cachedAt: row.read<DateTime>('cached_at'),
          ),
          saveCount: row.read<int>('save_count'),
        );
      }).toList();
    });
  }

  /// Get all user IDs who saved a specific movie.
  Future<List<int>> getUserIdsForMovie(int movieId) async {
    final query = select(savedMovies)
      ..where((s) => s.movieId.equals(movieId));

    final results = await query.get();
    return results.map((s) => s.userId).toList();
  }

  /// Watch the save count for a movie.
  Stream<int> watchSaveCountForMovie(int movieId) {
    final count = savedMovies.id.count();
    final query = selectOnly(savedMovies)
      ..addColumns([count])
      ..where(savedMovies.movieId.equals(movieId));

    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Get saved movie IDs for a user (for quick lookup).
  Future<Set<int>> getSavedMovieIdsForUser(int userId) async {
    final query = select(savedMovies)
      ..where((s) => s.userId.equals(userId));

    final results = await query.get();
    return results.map((s) => s.movieId).toSet();
  }

  /// Watch saved movie IDs for a user.
  Stream<Set<int>> watchSavedMovieIdsForUser(int userId) {
    final query = select(savedMovies)
      ..where((s) => s.userId.equals(userId));

    return query.watch().map(
          (rows) => rows.map((s) => s.movieId).toSet(),
        );
  }
}

/// A movie + how many users saved it (for Matches page).
class MovieMatch {
  final Movy movie;
  final int saveCount;

  const MovieMatch({required this.movie, required this.saveCount});
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'movie_verse.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
