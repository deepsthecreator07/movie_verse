import 'package:equatable/equatable.dart';
import '../../domain/repositories/matches_repository.dart';

abstract class MatchesState extends Equatable {
  const MatchesState();
  @override
  List<Object?> get props => [];
}

class MatchesInitial extends MatchesState {
  const MatchesInitial();
}

class MatchesLoading extends MatchesState {
  const MatchesLoading();
}

class MatchesLoaded extends MatchesState {
  final List<MatchEntity> matches;
  const MatchesLoaded(this.matches);
  @override
  List<Object?> get props => [matches];
}

class MatchesError extends MatchesState {
  final String message;
  const MatchesError(this.message);
  @override
  List<Object?> get props => [message];
}
