import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

// New Convo
import 'package:http/http.dart' as http;

// Notifications
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Storage
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PMConversationScreen extends StatefulWidget {
  final FirebaseUser user;
  final String matchName;
  final String username;
  final String room;

  PMConversationScreen({this.user, this.matchName, this.username, this.room});

  @override
  PMConversationScreenState createState() => new PMConversationScreenState(
        user: this.user,
        matchName: this.matchName,
        username: this.username,
        room: this.room,
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

  final String tableName = "Messages";

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var showTime;
  
  
  // Text styles
  var sentStyle = new TextStyle(
    fontSize: 16.0,
    color: Colors.white,
  );
  var receivedStyle = new TextStyle(
    fontSize: 16.0,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
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
          new AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = new IOSInitializationSettings();
      var initializationSettings = new InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin.initialize(initializationSettings);
      flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text("Conversation with " + matchName),
        elevation: 4.0,
      ),
      body: new Builder(
        builder: (BuildContext context) {
          return new Column(
            children: <Widget>[
              new Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('messages')
                      .document('rooms')
                      .collection(room)
                      .snapshots(),
                  builder: _buildMessageTiles
                ),
              ),
              new Divider(
                height: 1.0,
                color: Colors.black
              ),
              new Container(
              decoration: new BoxDecoration(
                color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
              ),
            ],
          );
        }
      )
    );
  }

  Widget _buildMessageTiles (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
      
      
      List<ListTile> listTiles = snapshot.data.documents.where((element) => element['message'] != null).map((DocumentSnapshot document) {
        if (document['from'] == 'user2') {
          return ListTile(
            contentPadding: EdgeInsets.only(right: 80.0),
            leading: new CircleAvatar(
              child: new Text(document['from'].toUpperCase()[0])
            ),
            title: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: .1,
                        color: Colors.black.withOpacity(.7)
                      )
                    ],
                    color: colorReceived,
                    borderRadius: radius,
                  ),
                  child:new Text(
                  document['message'],
                  textAlign: TextAlign.left,
                  style: receivedStyle,
                  ),
                ),
              ],
            ),
            //subtitle: _receivedTimeRow(int.parse(document.documentID)),
          );
        }
        
        else {
          return new ListTile(
            contentPadding: EdgeInsets.only(left: 80.0),
            title: new Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: .1,
                        color: Colors.black.withOpacity(.7)
                      )
                    ],
                    color: colorSent,
                    borderRadius: radius,
                  ),
                  child:new Text(
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
        return new Text('Error: ${snapshot.error}');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return new Text('Loading...');
      } else {
        return new ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            controller: _scrollController,
            children: completeList);
      }
    }
    return CircularProgressIndicator();
  }
  
  
  //TODO fix bug where screen doesn't scroll up and gets blocked by keyboard
  Widget _buildTextComposer() {
    return new Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: new Row(children: <Widget>[
          new Flexible(
            child: new TextField(
              onTap: () {
                Timer(
                  Duration(milliseconds: 300),
                  () => _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent));
              },
              maxLines: null,
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration:
                  new InputDecoration.collapsed(hintText: "Write a message"),
            ),
          ),
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 0.0),
            child: new IconButton(
                icon: new Icon(
                  Icons.send,
                  color: Colors.purple),
                  iconSize: 28,
                onPressed: () {
                  if (_textController.text.contains(new RegExp(r'\S'))) {
                    _handleSubmitted(_textController.text);
                  }
                }),
          ),
        ]));
  }
  
  
  
  String _getTime (int time) {
    var dt = DateTime.fromMillisecondsSinceEpoch(time);
    return "${dt.hour}:${dt.minute}";
  }
  
  
  
  Widget _sentTimeRow (int secs) {
    var dt = DateTime.fromMillisecondsSinceEpoch(secs);
    var time = "${dt.hour}:${dt.minute}";
    return Row(mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.only(right : 3.0),
          child: new Text(
            time.toString(),
            textAlign: TextAlign.right,
            style: new TextStyle(
              fontSize: 12.0
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _receivedTimeRow (int secs) {
    var dt = DateTime.fromMillisecondsSinceEpoch(secs);
    var time = "${dt.hour}:${dt.minute}";
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Container(
          child: new Text(
            time.toString(),
            textAlign: TextAlign.left,
            style: new TextStyle(
              fontSize: 12.0
            ),
          ),
        ),
      ],
    );
  }

  // Creating message and sending its values to cloud firestore.
  _handleSubmitted(String text) async{
    _textController.clear();
    var sTime = DateTime.now().millisecondsSinceEpoch.toString();
    Firestore.instance
      .collection('messages')
      .document('rooms')
      .collection(room)
      .document(sTime.toString()).setData(
        <String, dynamic>{
          'from': user.uid.toString(),
          'image': false,
          'message': text,
        },
        merge: false
      )
      .then((r) {
          print("Document successfully written!");
      })
      .catchError((error) {
          print("Error writing document: " + error);
      });
  }
}