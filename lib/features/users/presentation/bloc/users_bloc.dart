import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/user_repository.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository _repository;
  int _currentPage = 1;

  UsersBloc({required UserRepository repository})
      : _repository = repository,
        super(const UsersInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
    on<AddUser>(_onAddUser);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());
    _currentPage = 1;

    try {
      final users = await _repository.getUsers(page: _currentPage);
      emit(UsersLoaded(
        users: users,
        hasMore: users.length >= 6, // Reqres returns 6 per page
      ));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsers event,
    Emitter<UsersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UsersLoaded || !currentState.hasMore) return;
    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    _currentPage++;

    try {
      final allUsers = await _repository.getUsers(page: _currentPage);
      emit(UsersLoaded(
        users: allUsers,
        hasMore: allUsers.length > currentState.users.length,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onAddUser(
    AddUser event,
    Emitter<UsersState> emit,
  ) async {
    try {
      final user = await _repository.createUser(
        firstName: event.name,
        lastName: ' ',
        email: 'unknown@local.app',
        movieTaste: event.movieTaste,
      );

      emit(UserAdded(user));

      // Re-fetch users to update the list
      add(const LoadUsers());
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }
}
