import 'package:equatable/equatable.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();
  @override
  List<Object?> get props => [];
}

class LoadMatches extends MatchesEvent {
  const LoadMatches();
}
