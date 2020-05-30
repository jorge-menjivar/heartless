import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

// Notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PMConversationScreen extends StatefulWidget {
  final FirebaseUser user;
  final String matchName;
  final String username;
  final String room;

  PMConversationScreen({this.user, this.matchName, this.username, this.room});

  @override
  PMConversationScreenState createState() => PMConversationScreenState(
        user: user,
        matchName: matchName,
        username: username,
        room: room,
      );
}

class PMConversationScreenState extends State<PMConversationScreen>
    with WidgetsBindingObserver {
  final FirebaseUser user;
  final String matchName;
  final String username;
  String room;

  PMConversationScreenState(
      {this.user, this.matchName, this.username, this.room});

  ScrollController _scrollController;
  final TextEditingController _textController = TextEditingController();

  final String tableName = 'Messages';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var showTime;

  // Text styles
  var sentStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.white,
  );
  var receivedStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin.initialize(initializationSettings);
      flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print(e.toString());
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
        body: Builder(builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('messages')
                        .document('rooms')
                        .collection(room)
                        .snapshots(),
                    builder: _buildMessageTiles),
              ),
              Divider(height: 1.0, color: Colors.black),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
            ],
          );
        }));
  }

  Widget _buildMessageTiles(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasData) {
      // chat bubble
      final radius = BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
        bottomLeft: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      );

      // bubble Colors
      var colorSent = Colors.purple[900];
      var colorReceived = Colors.blueGrey[50];

      var listTiles = snapshot.data.documents.reversed
          .where((element) => element['message'] != null)
          .map((DocumentSnapshot document) {
        if (document['from'] != user.uid) {
          return ListTile(
            contentPadding: EdgeInsets.only(right: 80.0),
            leading: CircleAvatar(child: Text(matchName.toUpperCase()[0])),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          spreadRadius: .1,
                          color: Colors.black.withOpacity(.7))
                    ],
                    color: colorReceived,
                    borderRadius: radius,
                  ),
                  child: Text(
                    document['message'],
                    textAlign: TextAlign.left,
                    style: receivedStyle,
                  ),
                ),
              ],
            ),
            //subtitle: _receivedTimeRow(int.parse(document.documentID)),
          );
        } else {
          return ListTile(
            contentPadding: EdgeInsets.only(left: 80.0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          spreadRadius: .1,
                          color: Colors.black.withOpacity(.7))
                    ],
                    color: colorSent,
                    borderRadius: radius,
                  ),
                  child: Text(
                    document['message'],
                    textAlign: TextAlign.left,
                    style: sentStyle,
                  ),
                ),
              ],
            ),
            //subtitle: _sentTimeRow(int.parse(document.documentID)),
          );
        }
      }).toList();

      List<Object> completeList = listTiles;

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text('Loading...');
      } else {
        return ListView(
            physics: BouncingScrollPhysics(),
            reverse: true,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            controller: _scrollController,
            children: completeList);
      }
    }
    return CircularProgressIndicator();
  }

  //TODO fix bug where screen doesn't scroll up and gets blocked by keyboard
  Widget _buildTextComposer() {
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(children: <Widget>[
          Flexible(
            child: TextField(
              onTap: () {
                Timer(
                    Duration(milliseconds: 300),
                    () => _scrollController
                        .jumpTo(_scrollController.position.minScrollExtent));
              },
              maxLines: null,
              controller: _textController,
              onSubmitted: _sendMessage,
              decoration:
                  InputDecoration.collapsed(hintText: 'Write a message'),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 0.0),
            child: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.paperPlane,
                  color: Colors.pink,
                ),
                onPressed: () {
                  if (_textController.text.contains(RegExp(r'\S'))) {
                    _sendMessage(_textController.text);
                  }
                }),
          ),
        ]));
  }

  String _getTime(int time) {
    var dt = DateTime.fromMillisecondsSinceEpoch(time);
    return '${dt.hour}:${dt.minute}';
  }

  Widget _sentTimeRow(int secs) {
    var dt = DateTime.fromMillisecondsSinceEpoch(secs);
    var time = '${dt.hour}:${dt.minute}';
    return Row(
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
  }

  Widget _receivedTimeRow(int secs) {
    var dt = DateTime.fromMillisecondsSinceEpoch(secs);
    var time = '${dt.hour}:${dt.minute}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            time.toString(),
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0),
          ),
        ),
      ],
    );
  }

  // Creating message and sending its values to cloud firestore.
  void _sendMessage(String text) async {
    print(user.uid.toString());
    _textController.clear();
    var sTime = DateTime.now().millisecondsSinceEpoch.toString();
    await Firestore.instance
        .collection('messages')
        .document('rooms')
        .collection(room)
        .document(sTime.toString())
        .setData(<String, dynamic>{
      'from': user.uid.toString(),
      'image': false,
      'message': text,
    }, merge: false).then((r) {
      Timer(
          Duration(milliseconds: 100),
          () => _scrollController
              .jumpTo(_scrollController.position.minScrollExtent));
      print('Document successfully written!');
    }).catchError((error) {
      print('Error writing document: ' + error.toString());
    });
  }
}
