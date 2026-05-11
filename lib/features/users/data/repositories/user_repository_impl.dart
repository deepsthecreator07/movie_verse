import 'package:drift/drift.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_source.dart';
import '../models/user_model.dart';

/// Concrete implementation of UserRepository.
/// Handles online/offline branching and local caching.
class UserRepositoryImpl implements UserRepository {
  final UserRemoteSource remoteSource;
  final AppDatabase database;
  final ConnectivityService connectivity;

  UserRepositoryImpl({
    required this.remoteSource,
    required this.database,
    required this.connectivity,
  });

  @override
  Future<List<UserEntity>> getUsers({required int page}) async {
    if (connectivity.isOnline) {
      try {
        final response = await remoteSource.getUsers(page: page);

        // Cache users locally
        for (final userModel in response.data) {
          await database.upsertRemoteUser(
            UsersCompanion(
              remoteId: Value(userModel.id),
              firstName: Value(userModel.firstName),
              lastName: Value(userModel.lastName),
              email: Value(userModel.email),
              avatarUrl: Value(userModel.avatar),
              isLocal: const Value(false),
              pendingSync: const Value(false),
            ),
          );
        }

        // Return from local DB to include any locally-created users
        return _mapUsersToEntities(await database.getAllUsers());
      } catch (_) {
        // On API failure, fallback to cache
        return _mapUsersToEntities(await database.getAllUsers());
      }
    } else {
      return _mapUsersToEntities(await database.getAllUsers());
    }
  }

  @override
  Future<UserEntity> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String movieTaste,
  }) async {
    int? remoteId;
    bool pendingSync = true;

    if (connectivity.isOnline) {
      try {
        final response = await remoteSource.createUser(
          firstName: firstName,
          lastName: lastName,
          email: email,
          movieTaste: movieTaste,
        );
        remoteId = int.tryParse(response['id']?.toString() ?? '');
        pendingSync = false;
      } catch (_) {
        // If API fails, keep pendingSync true
      }
    }

    final localId = await database.insertUser(
      UsersCompanion(
        remoteId: Value(remoteId),
        firstName: Value(firstName),
        lastName: Value(lastName),
        email: Value(email),
        movieTaste: Value(movieTaste),
        avatarUrl: const Value(''),
        isLocal: const Value(true),
        pendingSync: Value(pendingSync),
      ),
    );

    return UserEntity(
      id: localId,
      remoteId: remoteId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      movieTaste: movieTaste,
      isLocal: true,
      pendingSync: pendingSync,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<UserEntity>> getCachedUsers() async {
    return _mapUsersToEntities(await database.getAllUsers());
  }

  @override
  Stream<List<UserEntity>> watchUsers() {
    return database.watchAllUsers().map(_mapUsersToEntities);
  }

  @override
  Future<void> syncPendingUsers() async {
    if (!connectivity.isOnline) return;

    final pendingUsers = await database.getPendingSyncUsers();

    for (final user in pendingUsers) {
      try {
        final response = await remoteSource.createUser(
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          movieTaste: user.movieTaste,
        );

        final remoteId = int.tryParse(response['id']?.toString() ?? '');
        if (remoteId != null) {
          await database.markUserSynced(user.id, remoteId);
        }
      } catch (_) {
        // Will retry on next sync
      }
    }
  }

  List<UserEntity> _mapUsersToEntities(List<User> users) {
    return users.map((u) {
      return UserEntity(
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
      );
    }).toList();
  }
}
