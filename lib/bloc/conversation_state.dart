part of 'conversation_bloc.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();
}

class ConversationInitial extends ConversationState {
  const ConversationInitial();
  @override
  List<Object> get props => [];
}

class ConversationLoading extends ConversationState {
  const ConversationLoading();
  @override
  List<Object> get props => [];
}

class ConversationLoaded extends ConversationState {
  final Messages messages;
  const ConversationLoaded(this.messages);
  @override
  List<Object> get props => [messages];
}

class ConversationError extends ConversationState {
  final String error;
  const ConversationError({this.error});
  @override
  List<Object> get props => [error];
}
