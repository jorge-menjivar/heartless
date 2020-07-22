part of 'p_matches_bloc.dart';

abstract class PMatchesState extends Equatable {
  const PMatchesState();
}

class PMatchesInitial extends PMatchesState {
  const PMatchesInitial();
  @override
  List<Object> get props => [];
}

class PMatchesLoading extends PMatchesState {
  const PMatchesLoading();
  @override
  List<Object> get props => [];
}

class PMatchesLoaded extends PMatchesState {
  final PMatches pMatches;
  const PMatchesLoaded(this.pMatches);
  @override
  List<Object> get props => [pMatches];
}

class PMatchesError extends PMatchesState {
  final String message;
  const PMatchesError(this.message);
  @override
  List<Object> get props => [message];
}
