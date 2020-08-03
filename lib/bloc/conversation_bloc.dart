import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lise/data/messages_data.dart';
import 'package:lise/data/models/messages_model.dart';
import 'package:sqflite/sqflite.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessagesData messagesData;
  ConversationBloc({@required this.messagesData}) : super(ConversationInitial());

  @override
  Stream<ConversationState> mapEventToState(
    ConversationEvent event,
  ) async* {
    if (event is GetConversation) {
      try {
        yield ConversationLoading();
        var messagesList;
        if (event.limit == null || event.limit < 1) {
          messagesList = await messagesData.fetchData(event.db, event.room);
        } else if (event.limit > 0) {
          messagesList = await messagesData.fetchData(event.db, event.room, limit: event.limit);
        }
        yield ConversationLoaded(messagesList);
      } on Error {
        yield ConversationError(
          error: 'Could not load conversation',
        );
      }
    }
  }
}
