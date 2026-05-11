import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/matches_repository.dart';
import 'matches_event.dart';
import 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final MatchesRepository _repository;

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

    await emit.forEach<List<MatchEntity>>(
      _repository.watchMatches(),
      onData: (matches) => MatchesLoaded(matches),
      onError: (e, _) => MatchesError(e.toString()),
    );
  }
}
