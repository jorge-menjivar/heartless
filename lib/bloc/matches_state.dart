part of 'matches_bloc.dart';

abstract class MatchesState extends Equatable {
  const MatchesState();
}

class MatchesInitial extends MatchesState {
  const MatchesInitial();
  @override
  List<Object> get props => [];
}

class MatchesLoading extends MatchesState {
  const MatchesLoading();
  @override
  List<Object> get props => [];
}

class MatchesLoaded extends MatchesState {
  final Matches matches;
  const MatchesLoaded(this.matches);
  @override
  List<Object> get props => [matches];
}

class MatchesError extends MatchesState {
  final String message;
  const MatchesError(this.message);
  @override
  List<Object> get props => [message];
}
