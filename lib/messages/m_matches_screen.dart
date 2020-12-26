import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Storage
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lise/app_variables.dart';
import 'package:lise/bloc/conversation_bloc.dart';
import 'package:lise/bloc/public_profile_bloc.dart';
import 'package:lise/data/public_data.dart';
import 'package:lise/pages/public/public_profile.dart';
import 'package:lise/utils/convert_match_time.dart';
import 'package:lise/widgets/loading_progress_indicator.dart';
import 'package:lise/widgets/matches_text_composer.dart';
import 'package:lise/widgets/message_long_press_dialog.dart';
import 'package:sqflite/sqflite.dart';

class MatchedConversationScreen extends StatefulWidget {
  final String imageLink;
  final String otherUserId;
  final String otherUserAlias;
  final String matchName;
  final String username;
  final String room;
  final Database db;
  final AppVariables appVariables;

  MatchedConversationScreen({
    @required this.imageLink,
    @required this.otherUserId,
    @required this.otherUserAlias,
    @required this.matchName,
    @required this.username,
    @required this.room,
    @required this.db,
    @required this.appVariables,
  });

  @override
  MatchedConversationScreenState createState() => MatchedConversationScreenState(
        imageLink: this.imageLink,
        otherUserId: this.otherUserId,
        otherUserAlias: this.otherUserAlias,
        matchName: this.matchName,
        username: this.username,
        room: this.room,
        db: this.db,
        appVariables: this.appVariables,
      );
}

enum PopupMenuChoice { flag }

class MatchedConversationScreenState extends State<MatchedConversationScreen> with WidgetsBindingObserver {
  final String imageLink;
  final String otherUserId;
  final String otherUserAlias;
  final String matchName;
  final String username;
  final String room;
  final Database db;
  final AppVariables appVariables;

  MatchedConversationScreenState({
    @required this.imageLink,
    @required this.otherUserId,
    @required this.otherUserAlias,
    @required this.matchName,
    @required this.username,
    @required this.room,
    @required this.db,
    @required this.appVariables,
  });

  final _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  var _showTime;

  // bubble Colors
  var _colorSent;
  var _colorReceived;

  var _firstTime = true;

  var _isLoading = false;

  var _messagesList;

  var _loadedAllRows = false;

  var _selection;

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
      appVariables.convoRowCount += AppVariables.DEFAULT_ROW_COUNT;
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
      appBar: AppBar(
        centerTitle: true,
        elevation: 4.0,
        title: Column(
          children: [
            CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.all(0),
              child: SizedBox(
                height: kToolbarHeight - 20,
                width: kToolbarHeight - 20,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        imageLink,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (parentContext) => BlocProvider(
                      create: (childContext) => PublicProfileBloc(
                        publicData: PublicDataRepository(),
                      ),
                      child: PublicProfileScreen(
                        alias: otherUserAlias,
                        name: matchName,
                      ),
                    ),
                  ),
                );
              },
            ),
            Text(
              matchName,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<PopupMenuChoice>(
            onSelected: (PopupMenuChoice result) {
              setState(() {
                _selection = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<PopupMenuChoice>>[
              const PopupMenuItem<PopupMenuChoice>(
                value: PopupMenuChoice.flag,
                child: Text('Report'),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state is ConversationLoaded) {
            _isLoading = false;
            // If the new list has the same number of rows as the previous one, then we
            // can say we have loaded all the messages in the conversation
            if (_messagesList != null) {
              if (_firstTime && _messagesList.length == state.messages.list.length) {
                _loadedAllRows = true;
                _firstTime = false;
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
              if (state.messages.list.length < AppVariables.DEFAULT_ROW_COUNT) {
                _loadedAllRows = true;
              }

              _isLoading = false;
              _messagesList = state.messages.list;
              if (_firstTime) {
                _showTime = List<bool>.filled(_messagesList.length, false, growable: true);
                _showTime[0] = true;
              }
              return builder(context, _messagesList);
            }

            if (state is ConversationLoading) {
              if (_messagesList != null) {
                _isLoading = true;
                return builder(context, _messagesList);
              }
            }
            return loading_progress_indicator();
          },
        ),
      ),
    );
  }

  Widget builder(BuildContext context, var messagesList) {
    _colorSent = Colors.blue[600];
    _colorReceived = (Theme.of(context).brightness == Brightness.light) ? Colors.blueGrey[100] : Colors.white30;

    return Builder(
      builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Container(
              height: _isLoading ? 100 : 0,
              child: loading_progress_indicator(),
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
              child: MatchesTextComposer(
                scrollController: _scrollController,
                textController: _textController,
                userID: username,
                room: room,
              ),
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
        if (row['birth'] == username) {
          return _buildSentRow(
            image: (row['image'] == 1) ? true : false,
            messagesList: messagesList,
            message: row['message'],
            sTime: row['sTime'],
            i: i,
            row: row,
          );
        } else {
          return _buildReceivedRow(
            image: (row['image'] == 1) ? true : false,
            messagesList: messagesList,
            message: row['message'],
            sTime: row['sTime'],
            i: i,
            row: row,
          );
        }
      },
    );
  }

// ------------------------------------ SENT MESSAGES ---------------------------------------------------------
  Widget _buildSentRow({
    @required bool image,
    @required var messagesList,
    @required String message,
    @required String sTime,
    @required int i,
    @required var row,
  }) {
    // Text style
    var textStyle = new TextStyle(
      fontSize: 17.0,
      color: Colors.white,
    );

    // chat bubble
    final radius = BorderRadius.only(
      topLeft: Radius.circular(20.0),
      topRight: (i < messagesList.length - 1 && messagesList[i + 1]['birth'] == username)
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
              child: image
                  ? gifImage(radius, message)
                  : Container(
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
              style: TextStyle(
                fontSize: 12.0,
              ),
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
  Widget _buildReceivedRow({
    @required var messagesList,
    @required bool image,
    @required String message,
    @required String sTime,
    @required int i,
    @required var row,
  }) {
    // Text style
    var textStyle = new TextStyle(
      fontSize: 17.0,
    );

    // chat bubble
    final radius = BorderRadius.only(
      topLeft: (i < messagesList.length - 1 && messagesList[i + 1]['birth'] != username)
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
              child: (i > 1 && messagesList[i - 1]['birth'] != username)
                  ? null
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            imageLink,
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
              child: image
                  ? gifImage(radius, message)
                  : Container(
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

  Widget gifImage(BorderRadius radius, String url) {
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        httpHeaders: {'accept': 'image/*'},
        placeholder: (context, valueString) {
          return loading_progress_indicator();
        },
      ),
    );
  }
}
