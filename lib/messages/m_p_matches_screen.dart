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

class ConversationScreen extends StatefulWidget {
  final FirebaseUser user;
  final String matchName;
  final String username;
  final String room;

  ConversationScreen({this.user, this.matchName, this.username, this.room});

  @override
  ConversationScreenState createState() => new ConversationScreenState(
    user: this.user,
    matchName: this.matchName,
    username: this.username,
    room: this.room, 
  );
}

class ConversationScreenState extends State<ConversationScreen> with WidgetsBindingObserver{
  final FirebaseUser user;
  final String matchName;
  final String username;
  String room;

  ConversationScreenState({this.user, this.matchName, this.username, this.room});
  

  ScrollController controller;
  final TextEditingController _textController = new TextEditingController();

  final String tableName = "Messages";

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var showTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try{
      var initializationSettingsAndroid =
          new AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = new IOSInitializationSettings();
      var initializationSettings = new InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin.initialize(initializationSettings);
      flutterLocalNotificationsPlugin.cancelAll();
    }
    catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text("Conversation with " + matchName),
        elevation: 4.0,
      ),
      body: new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('messages').document('rooms').collection(room).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting: return new Text('Loading...');
            default:
              return new ListView(
                children: snapshot.data.documents.map((DocumentSnapshot document) {
                  return new ListTile(
                    title: new Text(document['message']),
                    subtitle: new Text(document.documentID),
                  );
                }).toList(),
              );
          }
        }
      )
    );
  }


  Widget _buildTextComposer() {
    return new Container(
       margin: const EdgeInsets.symmetric(horizontal: 8.0),
       child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                //onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(
                  Icons.send,
                  color: Colors.purple),
                onPressed: () {
                  if (_textController.text.contains(new RegExp(r'\S'))) {
                    //_handleSubmitted(_textController.text);
                  }
                }
              ),
           ),
         ]
       )
    );
  }


/**
  // Creating message and sending its values to all databases.
  _handleSubmitted(String text) async{
    _textController.clear();
    var sTime = DateTime.now().millisecondsSinceEpoch.toString();

    // Main message
    var message = new MessageEntry(
      message: text,
      birth: user.uid.toString(),
    );

    print(room);
    print(username);
    print(matchName);
    
    // Add to cloud database
    

  }



  Widget buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      reverse: true,

      // For even rows, the function adds a ListTile row for the word pairing.
      // For odd rows, the function adds a Divider widget to visually
      itemBuilder: (context, i){
        return getTile(i);
      }
    );
  }  
*/

// ------------------------------------ SENT MESSAGES ---------------------------------------------------------
  Widget _buildSentRow(String message, String status, String sTime, int i) {

    // Text style
    var textStyle = new TextStyle(
      fontSize: 16.0,
      color: Colors.white,
    );

    // time
    int secs = int.tryParse(sTime);
    var dt = DateTime.fromMillisecondsSinceEpoch(secs);
    var time = "${dt.hour}:${dt.minute}";

    // chat bubble
    final radius = BorderRadius.only(
      topLeft: Radius.circular(20.0),
      topRight: Radius.circular(20.0),
      bottomLeft: Radius.circular(20.0),
      bottomRight: Radius.circular(20.0),
    );

    // bubble Color
    var color = Colors.purple[900];

    var timeRow;
    if (showTime[i] == true){
      timeRow = new Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
    else {
      timeRow = null;
    }

    // received or read icon
    var icon;
    if (status == '2'){
      icon = Icons.chat_bubble_outline;
    }
    else if (status == '3'){
      icon = Icons.chat_bubble;
    }

    return ListTile(
      contentPadding: EdgeInsets.only(left: 80.0),
      title: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: .5,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(.12)
                )
              ],
              color: color,
              borderRadius: radius,
            ),
            child:new Text(
            message,
            textAlign: TextAlign.right,
            style: textStyle,
            ),
          ),

        ],
      ),
      subtitle: timeRow,
      trailing: new Icon(
              icon,
              color: Colors.blue,
              size: 20.0,),
      onLongPress: () {      // Add 9 lines from here...
        setState(() {
        });
      },
      onTap: () {
        setState(() {
          //toggle boolean
          showTime[i] = !showTime[i];
        });
      }
    );
  }




  // ---------------------------------- RECEIVED MESSAGES -------------------------------------------------
  Widget _buildReceivedRow(String message, String sTime, int i) {

    

    // Text style
    var textStyle = new TextStyle(
      fontSize: 16.0,
      color: Colors.black,
    );

    // time
    int secs = int.tryParse(sTime);
    var dt = DateTime.fromMillisecondsSinceEpoch(secs);
    var time = "${dt.hour}:${dt.minute}";

    // chat bubble
    final radius = BorderRadius.only(
      topLeft: Radius.circular(20.0),
      topRight: Radius.circular(20.0),
      bottomLeft: Radius.circular(20.0),
      bottomRight: Radius.circular(20.0),
    );

    // bubble Color
    var color = Colors.blueGrey[50];

    var timeRow;
    if (showTime[i] == true){
      timeRow = Row(
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
    else {
      timeRow = null;
    }
        
    return ListTile(
      contentPadding: EdgeInsets.only(right: 80.0),
      leading: new CircleAvatar(
        child: new Text(matchName.toUpperCase()[0])
      ),
      title: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(child: new DrawerHeader(child: new CircleAvatar()),color: Colors.tealAccent,),
            

        ],
      ),
      subtitle: timeRow,
      onLongPress: () {      // Add 9 lines from here...
        setState(() {
        });
      },
      onTap: () {
        setState(() {
          //toggle boolean
          showTime[i] = !showTime[i];
        });
      }
    );
  }

}








class ChatMessage extends StatelessWidget {
    final String text;
    final String sentTime;
    final String contact;
  ChatMessage({this.text, this.sentTime, this.contact});

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(child: new Text(contact[0])),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(contact, style: Theme.of(context).textTheme.subhead),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: new Text(text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



/**
class MessageEntry {
  String message;
  String image;
  String birth;

  MessageEntry({this.message, this.image, this.birth});

  MessageEntry.fromSnapshot(DocumentSnapshot snapshot)
  : message = snapshot.value['m'],
    image = snapshot.value['i'],
    birth = snapshot.value['b'];

  toJson() {
    return {
      "m": message,
      "i": image,
      "b": birth
    };
  }
}
*/




class SentMessage {
  final String time;
  final String message;
  final String image;

  SentMessage({this.time, this.message, this.image});
  factory SentMessage.fromJson(Map<String, dynamic> parsedJson) {

    return SentMessage (
      time: parsedJson['time'], 
      message: parsedJson['message'],
      image: parsedJson['image'],
    );
  }
  
  Map<String, dynamic> toJson() => 
  {
    'time': time,
    'message' : message,
    'image' : image,
  };
}


class ReceivedMessage {
  final String sTime;
  final String rTime;
  final String message;
  final String image;
  final String status;

  ReceivedMessage({this.sTime, this.rTime, this.message, this.image, this.status});
  factory ReceivedMessage.fromJson(Map<String, dynamic> parsedJson) {

    return ReceivedMessage (
      sTime: parsedJson['sTime'], 
      rTime: parsedJson['rTime'],
      message: parsedJson['message'],
      image: parsedJson['image'],
      status: parsedJson['status']
    );
  }
  
  Map<String, dynamic> toJson() => 
  {
    'sTime': sTime,
    'rTime': rTime,
    'message' : message,
    'image' : image,
    'status' : status
  };
}
