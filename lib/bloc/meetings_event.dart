part of 'meetings_bloc.dart';

abstract class MeetingsEvent extends Equatable {
  const MeetingsEvent();

  @override
  List<Object> get props => [];
}

class GetMeetings extends MeetingsEvent {
  final List meetingsDocs;

  const GetMeetings({
    @required this.meetingsDocs,
  });

  @override
  List<Object> get props => [meetingsDocs];
}

class UpdateMeetings extends MeetingsEvent {
  final List meetingsList;
  final List meetingsDocs;

  const UpdateMeetings({
    @required this.meetingsList,
    @required this.meetingsDocs,
  });

  @override
  List<Object> get props => [meetingsList, meetingsDocs];
}
