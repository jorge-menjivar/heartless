part of 'matches_bloc.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();
}

class GetMatches extends MatchesEvent {
  final db;
  final List matchesDocs;

  const GetMatches({
    @required this.db,
    @required this.matchesDocs,
  });

  @override
  List<Object> get props => [matchesDocs];
}

class MatchUpdateLastMessage extends MatchesEvent {
  final db;
  final List matchesList;

  const MatchUpdateLastMessage({
    @required this.db,
    @required this.matchesList,
  });

  @override
  List<Object> get props => [matchesList];
}
