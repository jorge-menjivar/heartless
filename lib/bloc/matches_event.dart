part of 'matches_bloc.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();
}

class GetMatches extends MatchesEvent {
  final List matchesDocs;

  const GetMatches({this.matchesDocs});

  @override
  List<Object> get props => [matchesDocs];
}
