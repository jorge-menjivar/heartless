import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_advanced_networkimage/provider.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lise/utils/convert_match_time.dart';
import 'package:lise/utils/database.dart';
import 'package:lise/widgets/matches_text_composer.dart';
import 'package:sqflite/sqflite.dart';

class MatchedConversationScreen extends StatefulWidget {
  final String imageLink;
  final String alias;
  final String otherUserId;
  final String matchName;
  final String username;
  final String room;
  final Database db;

  MatchedConversationScreen({
    @required this.imageLink,
    @required this.alias,
    @required this.otherUserId,
    @required this.matchName,
    @required this.username,
    @required this.room,
    @required this.db,
  });

  @override
  MatchedConversationScreenState createState() => MatchedConversationScreenState(
        imageLink: imageLink,
        alias: alias,
        otherUserId: otherUserId,
        matchName: matchName,
        username: username,
        room: room,
        db: db,
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

  MatchedConversationScreenState({
    @required this.imageLink,
    @required this.alias,
    @required this.otherUserId,
    @required this.matchName,
    @required this.username,
    @required this.room,
    @required this.db,
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

  var _messagesList = [];

  StreamSubscription _listener;

  var _showTime;

  // bubble Colors
  var _colorSent;
  var _colorReceived;

  @override
  void initState() {
    super.initState();

    getMessages();
  }

  @protected
  @mustCallSuper
  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  Future<void> getMessages() async {
    // Making sure table is created if does not exist;
    await checkMessageTable(db, room);

    _messagesList = await db.rawQuery('SELECT * FROM $room ORDER BY ${Message.db_sTime} DESC');

    _showTime = List<bool>.filled(_messagesList.length, false, growable: true);

    if (_messagesList.isNotEmpty) {
      // Start a stream that listens for new messages
      recursiveStream();
    } else {
      // Pull any messages from the cloud
      await Firestore.instance
          .collection('messages')
          .document('rooms')
          .collection(room)
          .getDocuments()
          .then((snapshot) async {
        for (var doc in snapshot.documents) {
          if (doc.documentID != 'settings') {
            var values = {
              'message': doc['message'],
              'sTime': doc['time'],
              'birth': doc['from'],
              'image': (doc['image']) ? 1 : 0,
            };

            // Inserting the values into the table room
            await db.insert(room, values);

            _showTime.add(false);
          }
        }

        setState(() {});
      });

      recursiveStream();
    }
  }

  Future<void> recursiveStream() async {
    // Try to cancel any previous streams so we don't run multiple instances
    try {
      _listener.cancel();
    } catch (e) {}

    _messagesList = await db.rawQuery('SELECT * FROM $room ORDER BY ${Message.db_sTime} DESC');

    var lastMessage = _messagesList[0];
    var lastMessageTime = lastMessage['sTime'];

    // If this is the last message, make sure to show time;
    _showTime[0] = true;

    setState(() {});

    _listener = Firestore.instance
        .collection('messages')
        .document('rooms')
        .collection(room)
        .where('time', isGreaterThan: int.tryParse(lastMessageTime))
        .orderBy('time', descending: false)
        .snapshots()
        .listen((event) async {
      if (event.documents.length > 0) {
        for (var doc in event.documents) {
          if (doc.documentID != 'settings') {
            var values = {
              'message': doc['message'],
              'sTime': doc['time'],
              'birth': doc['from'],
              'image': (doc['image']) ? 1 : 0,
            };

            // Inserting the values into the table room
            await db.insert(room, values);

            _showTime.add(false);

            recursiveStream();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _colorSent = Colors.blueGrey[800];
    _colorReceived = Colors.blueGrey[100];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Conversation with ' + matchName),
        elevation: 4.0,
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Flexible(
                child: buildMessages(),
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
      ),
    );
  }

  Widget buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      reverse: true,
      itemCount: (_messagesList.isNotEmpty) ? _messagesList.length : 0,
      itemBuilder: (context, i) {
        var row = _messagesList[i];
        if (row['birth'] == alias) {
          return _buildSentRow(row['message'], row['sTime'], i);
        } else {
          return _buildReceivedRow(row['message'], row['sTime'], i);
        }
      },
    );
  }

// ------------------------------------ SENT MESSAGES ---------------------------------------------------------
  Widget _buildSentRow(String message, String sTime, int i) {
    // Text style
    var textStyle = new TextStyle(
      fontSize: 17.0,
      color: Colors.white,
    );

    // chat bubble
    final radius = BorderRadius.only(
      topLeft: Radius.circular(20.0),
      topRight: (i < _messagesList.length - 1 && _messagesList[i + 1]['birth'] == alias)
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
            child: CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.fromLTRB(80, 0, 0, 0),
              borderRadius: BorderRadius.all(Radius.circular(0)),
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
  Widget _buildReceivedRow(String message, String sTime, int i) {
    // Text style
    var textStyle = new TextStyle(
      fontSize: 17.0,
      color: Colors.black,
    );

    // chat bubble
    final radius = BorderRadius.only(
      topLeft: (i < _messagesList.length - 1 && _messagesList[i + 1]['birth'] != alias)
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
              child: (i > 1 && _messagesList[i - 1]['birth'] != alias)
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
            child: CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.fromLTRB(4, 0, 50, 0),
              borderRadius: BorderRadius.all(Radius.circular(0)),
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
