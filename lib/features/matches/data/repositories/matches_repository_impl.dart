import '../../../../database/app_database.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../domain/repositories/matches_repository.dart';

/// Concrete implementation of MatchesRepository.
class MatchesRepositoryImpl implements MatchesRepository {
  final AppDatabase database;

  MatchesRepositoryImpl({required this.database});

  @override
  Stream<List<MatchEntity>> watchMatches() {
    return database.watchMatches().asyncMap((matches) async {
      final result = <MatchEntity>[];

      // Get all users once, outside the loop
      final allUsers = await database.getAllUsers();

      for (final match in matches) {
        // Get the user IDs who saved this movie
        final userIds = await database.getUserIdsForMovie(match.movie.id);

        // Filter users who saved this movie
        final matchedUsers = allUsers
            .where((u) => userIds.contains(u.id))
            .map((u) => UserEntity(
                  id: u.id,
                  remoteId: u.remoteId,
                  firstName: u.firstName,
                  lastName: u.lastName,
                  email: u.email,
                  avatarUrl: u.avatarUrl,
                  movieTaste: u.movieTaste,
                  isLocal: u.isLocal,
                  pendingSync: u.pendingSync,
                  createdAt: u.createdAt,
                ))
            .toList();

        result.add(MatchEntity(
          movie: MovieEntity(
            id: match.movie.id,
            title: match.movie.title,
            overview: match.movie.overview,
            posterPath: match.movie.posterPath,
            backdropPath: match.movie.backdropPath,
            releaseDate: match.movie.releaseDate,
            voteAverage: match.movie.voteAverage,
            voteCount: match.movie.voteCount,
          ),
          saveCount: match.saveCount,
          users: matchedUsers,
          totalAppUsers: allUsers.length,
        ));
      }

      return result;
    });
  }
}
