import '../../../movies/domain/entities/movie_entity.dart';
import '../../../users/domain/entities/user_entity.dart';

/// A match: a movie saved by 2+ users.
class MatchEntity {
  final MovieEntity movie;
  final int saveCount;
  final List<UserEntity> users;

  const MatchEntity({
    required this.movie,
    required this.saveCount,
    this.users = const [],
  });
}

/// Abstract repository for match operations.
abstract class MatchesRepository {
  /// Watch movies saved by 2+ users, sorted by save count desc.
  Stream<List<MatchEntity>> watchMatches();
}
