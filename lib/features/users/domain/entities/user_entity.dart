import 'package:equatable/equatable.dart';

/// Domain entity for a user.
class UserEntity extends Equatable {
  final int id;
  final int? remoteId;
  final String firstName;
  final String lastName;
  final String email;
  final String avatarUrl;
  final String movieTaste;
  final bool isLocal;
  final bool pendingSync;
  final DateTime createdAt;
  final int savedMovieCount;

  const UserEntity({
    required this.id,
    this.remoteId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl = '',
    this.movieTaste = '',
    this.isLocal = false,
    this.pendingSync = false,
    required this.createdAt,
    this.savedMovieCount = 0,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        remoteId,
        firstName,
        lastName,
        email,
        avatarUrl,
        movieTaste,
        isLocal,
        pendingSync,
        createdAt,
        savedMovieCount,
      ];
}
