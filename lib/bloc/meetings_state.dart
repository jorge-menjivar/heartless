part of 'meetings_bloc.dart';

abstract class MeetingsState extends Equatable {
  const MeetingsState();

  @override
  List<Object> get props => [];
}

class MeetingsInitial extends MeetingsState {
  const MeetingsInitial();
  @override
  List<Object> get props => [];
}

class MeetingsLoading extends MeetingsState {
  const MeetingsLoading();
  @override
  List<Object> get props => [];
}

class MeetingsLoaded extends MeetingsState {
  final Meetings meetings;
  const MeetingsLoaded(this.meetings);
  @override
  List<Object> get props => [meetings];
}

class MeetingsError extends MeetingsState {
  final String message;
  const MeetingsError(this.message);
  @override
  List<Object> get props => [message];
}
