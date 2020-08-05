part of 'p_matches_bloc.dart';

abstract class PMatchesEvent extends Equatable {
  const PMatchesEvent();
}

class GetPMatches extends PMatchesEvent {
  final db;
  final List pMatchesDocs;

  const GetPMatches({
    @required this.db,
    @required this.pMatchesDocs,
  });

  @override
  List<Object> get props => [pMatchesDocs];
}

class PMatchUpdateLastMessage extends PMatchesEvent {
  final db;
  final List pMatchesList;

  const PMatchUpdateLastMessage({
    @required this.db,
    @required this.pMatchesList,
  });

  @override
  List<Object> get props => [pMatchesList];
}
