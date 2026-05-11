import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/matches_repository.dart';
import 'matches_event.dart';
import 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final MatchesRepository _repository;
  StreamSubscription? _subscription;

  MatchesBloc({required MatchesRepository repository})
      : _repository = repository,
        super(const MatchesInitial()) {
    on<LoadMatches>(_onLoad);
  }

  Future<void> _onLoad(
    LoadMatches event,
    Emitter<MatchesState> emit,
  ) async {
    emit(const MatchesLoading());

    _subscription?.cancel();
    _subscription = _repository.watchMatches().listen(
      (matches) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(MatchesLoaded(matches));
      },
      onError: (e) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(MatchesError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
