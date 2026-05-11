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
  final String firstName;
  final String lastName;
  final String email;
  final String movieTaste;

  const AddUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.movieTaste,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, movieTaste];
}
