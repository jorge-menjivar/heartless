part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();
}

class GetConversation extends ConversationEvent {
  final Database db;
  final String room;

  const GetConversation({
    @required this.db,
    @required this.room,
  });

  @override
  List<Object> get props => [room];
}
