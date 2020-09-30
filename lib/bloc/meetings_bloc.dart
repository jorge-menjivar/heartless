import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lise/data/meetings_data.dart';
import 'package:lise/data/models/meetings_model.dart';

part 'meetings_event.dart';
part 'meetings_state.dart';

class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  final MeetingsData meetingsData;

  MeetingsBloc({@required this.meetingsData}) : super(MeetingsInitial());

  @override
  Stream<MeetingsState> mapEventToState(
    MeetingsEvent event,
  ) async* {
    yield MeetingsLoading();
    if (event is GetMeetings) {
      try {
        final meetings = await meetingsData.fetchData(event.meetingsDocs);
        yield MeetingsLoaded(meetings);
      } on Error {
        yield MeetingsError('Could not fetch meetings');
      }
    } else if (event is UpdateMeetings) {
      try {
        final meetings = await meetingsData.updateData(event.meetingsList, event.meetingsDocs);
        yield MeetingsLoaded(meetings);
      } on Error {
        yield MeetingsError('Could not fetch meetings');
      }
    }
  }
}
