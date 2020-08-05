import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lise/data/models/p_matches_model.dart';
import 'package:lise/data/p_matches_data.dart';

part 'p_matches_event.dart';
part 'p_matches_state.dart';

class PMatchesBloc extends Bloc<PMatchesEvent, PMatchesState> {
  final PMatchesData pMatchesData;

  PMatchesBloc({@required this.pMatchesData}) : super(PMatchesInitial());

  @override
  Stream<PMatchesState> mapEventToState(
    PMatchesEvent event,
  ) async* {
    yield PMatchesLoading();
    if (event is GetPMatches) {
      try {
        final pMatches = await pMatchesData.fetchData(event.db, event.pMatchesDocs);
        yield PMatchesLoaded(pMatches);
      } on Error {
        yield PMatchesError('Could not fetch potential matches');
      }
    } else if (event is PMatchUpdateLastMessage) {
      try {
        final pMatches = await pMatchesData.updateData(event.db, event.pMatchesList);
        yield PMatchesLoaded(pMatches);
      } on Error {
        yield PMatchesError('Could not fetch potential matches');
      }
    }
  }
}
