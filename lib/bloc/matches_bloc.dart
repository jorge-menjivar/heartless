import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lise/data/matches_data.dart';
import 'package:lise/data/models/matches_model.dart';

part 'matches_event.dart';
part 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final MatchesData matchesData;

  MatchesBloc(this.matchesData) : super(MatchesInitial());

  @override
  Stream<MatchesState> mapEventToState(
    MatchesEvent event,
  ) async* {
    yield MatchesLoading();
    if (event is GetMatches) {
      try {
        final matches = await matchesData.fetchData(event.matchesDocs);
        yield MatchesLoaded(matches);
      } on Error {
        yield MatchesError('Could not fetch potential matches');
      }
    }
  }
}
