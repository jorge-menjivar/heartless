part of 'p_matches_bloc.dart';

abstract class PMatchesEvent extends Equatable {
  const PMatchesEvent();
}

class GetPMatches extends PMatchesEvent {
  final List pMatchesDocs;

  const GetPMatches({this.pMatchesDocs});

  @override
  List<Object> get props => [pMatchesDocs];
}
