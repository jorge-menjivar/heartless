import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget matchesTextComposer(
    ScrollController scrollController, TextEditingController textController, String alias, String room) {
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Row(
      children: <Widget>[
        Flexible(
          child: TextField(
            onTap: () {
              Timer(
                Duration(milliseconds: 300),
                () => scrollController.jumpTo(scrollController.position.minScrollExtent),
              );
            },
            keyboardType: TextInputType.multiline,
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            showCursor: true,
            controller: textController,
            decoration: InputDecoration.collapsed(hintText: 'Write a message'),
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
              if (textController.text.contains(RegExp(r'\S'))) {
                _sendMessage(scrollController, textController, alias, room);
              }
            },
          ),
        ),
      ],
    ),
  );
}

// Creating message and sending its values to cloud firestore.
void _sendMessage(
    ScrollController scrollController, TextEditingController textController, String alias, String room) async {
  var text = textController.text;
  textController.clear();
  var sTime = DateTime.now().millisecondsSinceEpoch;
  await Firestore.instance.collection('messages').document('rooms').collection(room).document(sTime.toString()).setData(
      <String, dynamic>{'from': alias, 'image': false, 'message': text, 'time': sTime},
      merge: false).then((r) {
    Timer(Duration(milliseconds: 100), () => scrollController.jumpTo(scrollController.position.minScrollExtent));
    print('Document successfully written!');
  }).catchError((error) {
    print('Error writing document: ' + error.toString());
  });
}
