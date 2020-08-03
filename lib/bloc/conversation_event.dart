part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();
}

class GetConversation extends ConversationEvent {
  final Database db;
  final String room;
  final int limit;

  const GetConversation({
    @required this.db,
    @required this.room,
    this.limit,
  });

  @override
  List<Object> get props => [room];
}
