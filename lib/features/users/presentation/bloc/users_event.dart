import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

/// Load users (first page or refresh).
class LoadUsers extends UsersEvent {
  const LoadUsers();
}

/// Load next page of users.
class LoadMoreUsers extends UsersEvent {
  const LoadMoreUsers();
}

/// Add a new user.
class AddUser extends UsersEvent {
  final String name;
  final String movieTaste;

  const AddUser({
    required this.name,
    required this.movieTaste,
  });

  @override
  List<Object?> get props => [name, movieTaste];
}
