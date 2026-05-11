import '../entities/user_entity.dart';

/// Abstract repository for user operations.
abstract class UserRepository {
  /// Fetch users from API, cache them, and return.
  /// Falls back to cache when offline.
  Future<List<UserEntity>> getUsers({required int page});

  /// Create a new user. If offline, save locally with pendingSync = true.
  Future<UserEntity> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String movieTaste,
  });

  /// Get all locally cached users.
  Future<List<UserEntity>> getCachedUsers();

  /// Watch all users as a stream (for real-time updates).
  Stream<List<UserEntity>> watchUsers();

  /// Sync pending local users to the server.
  Future<void> syncPendingUsers();
}
