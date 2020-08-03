import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_advanced_networkimage/provider.dart';

// Storage
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lise/app_variables.dart';
import 'package:lise/bloc/conversation_bloc.dart';
import 'package:lise/utils/convert_match_time.dart';
import 'package:lise/widgets/matches_text_composer.dart';
import 'package:lise/widgets/message_long_press_dialog.dart';
import 'package:sqflite/sqflite.dart';

class MatchedConversationScreen extends StatefulWidget {
  final String imageLink;
  final String alias;
  final String otherUserId;
  final String matchName;
  final String username;
  final String room;
  final Database db;
  final AppVariables appVariables;

  MatchedConversationScreen({
    @required this.imageLink,
    @required this.alias,
    @required this.otherUserId,
    @required this.matchName,
    @required this.username,
    @required this.room,
    @required this.db,
    @required this.appVariables,
  });

  @override
  MatchedConversationScreenState createState() => MatchedConversationScreenState(
        imageLink: this.imageLink,
        alias: this.alias,
        otherUserId: this.otherUserId,
        matchName: this.matchName,
        username: this.username,
        room: this.room,
        db: this.db,
        appVariables: this.appVariables,
      );
}

class MatchedConversationScreenState extends State<MatchedConversationScreen> with WidgetsBindingObserver {
  final String imageLink;
  final String alias;
  final String otherUserId;
  final String matchName;
  final String username;
  final String room;
  final Database db;
  final AppVariables appVariables;

  MatchedConversationScreenState({
    @required this.imageLink,
    @required this.alias,
    @required this.otherUserId,
    @required this.matchName,
    @required this.username,
    @required this.room,
    @required this.db,
    @required this.appVariables,
  });

  final _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  // Text styles
  var sentStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.white,
  );
  var receivedStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.black,
  );

  var _showTime;

  // bubble Colors
  var _colorSent;
  var _colorReceived;

  var _firstTime = true;

  var _isLoading = false;

  var _messagesList;

  var _loadedAllRows = false;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<ConversationBloc>(context)
      ..add(GetConversation(
        db: db,
        room: room,
        limit: appVariables.convoRowCount,
      ));
  }

  Future<void> _queryNext() async {
    // Whether or not we have already loaded all the messages in this conversation
    // If this is the case, this will prevent the loading indicator from showing
    if (!_loadedAllRows) {
      appVariables.convoRowCount += 30;
      // Adding the conversation event
      // ignore: close_sinks
      BlocProvider.of<ConversationBloc>(context)
        ..add(GetConversation(
          db: db,
          room: room,
          limit: appVariables.convoRowCount,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Conversation with ' + matchName),
        elevation: 4.0,
      ),
      body: BlocListener<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state is ConversationLoading) {}
          if (state is ConversationLoaded) {
            // If the new list has the same number of rows as the previous one, then we
            // can say we have loaded all the messages in the conversation
            if (_messagesList != null) {
              if (_messagesList.length == state.messages.list.length) {
                _loadedAllRows = true;
              }
            }
            _messagesList = state.messages.list;
            _showTime = List<bool>.filled(_messagesList.length, false, growable: true);
            _showTime[0] = true;
          }
        },
        child: BlocBuilder<ConversationBloc, ConversationState>(
          builder: (context, state) {
            if (state is ConversationLoaded) {
              // If there messages loaded are not a multiple of 30 we can tell we loaded
              // all messages because we did not reach the limit rows of the query
              if (state.messages.list.length < 30) {
                _loadedAllRows = true;
              }

              _isLoading = false;
              _messagesList = state.messages.list;
              if (_firstTime) {
                _showTime = List<bool>.filled(_messagesList.length, false, growable: true);
                _showTime[0] = true;

                _firstTime = false;
              }
              return builder(context, _messagesList);
            }

            if (state is ConversationLoading) {
              if (_messagesList != null) {
                _isLoading = true;
                return builder(context, _messagesList);
              }
            }
            return loading(context);
          },
        ),
      ),
    );
  }

  Widget loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget builder(BuildContext context, var messagesList) {
    _colorSent = Colors.blueGrey[800];
    _colorReceived = Colors.blueGrey[100];

    return Builder(
      builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Container(
              height: _isLoading ? 100 : 0,
              child: loading(context),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
            Flexible(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!_isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                    // Load the next set of messages
                    _queryNext();
                  }
                },
                child: buildMessages(messagesList),
              ),
            ),
            Divider(
              height: 1.0,
              color: Colors.black,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: matchesTextComposer(_scrollController, _textController, alias, room),
            ),
          ],
        );
      },
    );
  }

  Widget buildMessages(var messagesList) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      reverse: true,
      itemCount: (messagesList.isNotEmpty) ? messagesList.length : 0,
      itemBuilder: (context, i) {
        var row = messagesList[i];
        if (row['birth'] == alias) {
          return _buildSentRow(messagesList, row['message'], row['sTime'], i, row);
        } else {
          return _buildReceivedRow(messagesList, row['message'], row['sTime'], i, row);
        }
      },
    );
  }

// ------------------------------------ SENT MESSAGES ---------------------------------------------------------
  Widget _buildSentRow(var messagesList, String message, String sTime, int i, var row) {
    // Text style
    var textStyle = new TextStyle(
      fontSize: 17.0,
      color: Colors.white,
    );

    // chat bubble
    final radius = BorderRadius.only(
      topLeft: Radius.circular(20.0),
      topRight: (i < messagesList.length - 1 && messagesList[i + 1]['birth'] == alias)
          ? Radius.circular(5.0)
          : Radius.circular(20.0),
      bottomLeft: Radius.circular(20.0),
      bottomRight: Radius.circular(5.0),
    );

    var messageContainer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: RawMaterialButton(
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.fromLTRB(80, 0, 0, 0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: _colorSent,
                  borderRadius: radius,
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.left,
                  style: textStyle,
                ),
              ),
              onPressed: () {
                setState(() {
                  //toggle boolean
                  _showTime[i] = !_showTime[i];
                });
              },
              onLongPress: () {
                MessageLongPressDialog(context, row);
              },
            ),
          ),
        ],
      ),
    );

    // If we should show the time with the message
    if (_showTime[i]) {
      // Setting the time
      var time = convertMatchTime(context, int.tryParse(sTime));
      var timeRow = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 3.0),
            child: Text(
              time.toString(),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.0),
            ),
          ),
        ],
      );

      return Column(
        children: [messageContainer, timeRow],
      );
    } else {
      return messageContainer;
    }
  }

  // ---------------------------------- RECEIVED MESSAGES -------------------------------------------------
  Widget _buildReceivedRow(var messagesList, String message, String sTime, int i, var row) {
    // Text style
    var textStyle = new TextStyle(
      fontSize: 17.0,
      color: Colors.black,
    );

    // chat bubble
    final radius = BorderRadius.only(
      topLeft: (i < messagesList.length - 1 && messagesList[i + 1]['birth'] != alias)
          ? Radius.circular(5.0)
          : Radius.circular(20.0),
      topRight: Radius.circular(20.0),
      bottomLeft: Radius.circular(5.0),
      bottomRight: Radius.circular(20.0),
    );

    var messageContainer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
            child: SizedBox(
              height: 40,
              width: 40,
              child: (i > 1 && messagesList[i - 1]['birth'] != alias)
                  ? null
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AdvancedNetworkImage(
                            imageLink,
                            useDiskCache: true,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: RawMaterialButton(
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.fromLTRB(4, 0, 50, 0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: _colorReceived,
                  borderRadius: radius,
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.left,
                  style: textStyle,
                ),
              ),
              onPressed: () {
                setState(() {
                  //toggle boolean
                  _showTime[i] = !_showTime[i];
                });
              },
              onLongPress: () {
                MessageLongPressDialog(context, row);
              },
            ),
          ),
        ],
      ),
    );

    // If we should show the time with the message
    if (_showTime[i]) {
      // Setting the time
      var time = convertMatchTime(context, int.tryParse(sTime));
      var timeRow = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 55,
          ),
          Container(
            margin: const EdgeInsets.only(right: 3.0),
            child: Text(
              time.toString(),
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 12.0),
            ),
          ),
        ],
      );

      return Column(
        children: [messageContainer, timeRow],
      );
    } else {
      return messageContainer;
    }
  }
}
