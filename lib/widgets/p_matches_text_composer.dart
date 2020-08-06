import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giphy_picker/giphy_picker.dart';

Widget pMatchesTextComposer(
  BuildContext context,
  ScrollController scrollController,
  TextEditingController textController,
  String alias,
  String room,
) {
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Column(
      children: [
        Row(
          children: <Widget>[
            CupertinoButton(
                child: FaIcon(
                  FontAwesomeIcons.icons,
                  color: Colors.blue,
                ),
                onPressed: () =>
                    pickGIF(context: context, scrollController: scrollController, alias: alias, room: room)),
            Flexible(
              child: Platform.isIOS
                  ? cupertinoTextField(scrollController, textController, alias, room)
                  : materialTextField(scrollController, textController, alias, room),
            ),
          ],
        ),
        Divider(
          height: Platform.isIOS ? 16 : 8,
          color: Colors.transparent,
        ),
      ],
    ),
  );
}

Widget sendIcon(ScrollController scrollController, TextEditingController textController, String alias, String room) {
  return CupertinoButton(
    child: FaIcon(
      FontAwesomeIcons.paperPlane,
      color: Colors.pink,
    ),
    onPressed: () {
      if (textController.text.contains(RegExp(r'\S'))) {
        _sendMessage(
          scrollController: scrollController,
          textController: textController,
          alias: alias,
          room: room,
        );
      }
    },
  );
}

Widget materialTextField(
    ScrollController scrollController, TextEditingController textController, String alias, String room) {
  return TextField(
    onTap: () {
      Timer(
        Duration(milliseconds: 300),
        () => scrollController.jumpTo(scrollController.position.minScrollExtent),
      );
    },
    keyboardType: TextInputType.multiline,
    autocorrect: true,
    enableSuggestions: true,
    enableInteractiveSelection: true,
    textCapitalization: TextCapitalization.sentences,
    minLines: 1,
    maxLines: 5,
    showCursor: true,
    controller: textController,
    decoration: InputDecoration(
      suffixIcon: sendIcon(scrollController, textController, alias, room),
      hintText: 'Write a message',
      fillColor: Colors.black12,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
    ),
  );
}

Widget cupertinoTextField(
    ScrollController scrollController, TextEditingController textController, String alias, String room) {
  return CupertinoTextField(
    onTap: () {
      Timer(
        Duration(milliseconds: 300),
        () => scrollController.jumpTo(scrollController.position.minScrollExtent),
      );
    },
    keyboardType: TextInputType.multiline,
    autocorrect: true,
    enableSuggestions: true,
    enableInteractiveSelection: true,
    textCapitalization: TextCapitalization.sentences,
    minLines: 1,
    maxLines: 5,
    showCursor: true,
    controller: textController,
    placeholder: "Write a message",
    suffix: Container(
      margin: EdgeInsets.symmetric(horizontal: 0.0),
      child: sendIcon(scrollController, textController, alias, room),
    ),
  );
}

// Creating message and sending its values to cloud firestore.
void _sendMessage({
  @required ScrollController scrollController,
  @required TextEditingController textController,
  @required String alias,
  @required String room,
}) async {
  var text = textController.text;
  textController.clear();
  var sTime = DateTime.now().millisecondsSinceEpoch;
  await Firestore.instance
      .collection('messages')
      .document('rooms')
      .collection(room)
      .document(sTime.toString())
      .setData(<String, dynamic>{
    'from': alias,
    'image': false,
    'message': text,
    'time': sTime,
  }, merge: false).then((r) {
    Timer(Duration(milliseconds: 100), () => scrollController.jumpTo(scrollController.position.minScrollExtent));
    print('Document successfully written!');
  }).catchError((error) {
    print('Error writing document: ' + error.toString());
  });
}

void pickGIF({
  @required BuildContext context,
  @required ScrollController scrollController,
  @required String alias,
  @required String room,
}) async {
  final gif = await GiphyPicker.pickGif(
    context: context,
    apiKey: '9fUDytWSqLwokwmGIinJbhajQj1C87N2',
  );

  if (gif != null) {
    final url = gif.images.original.url;
    _sendGIF(scrollController: scrollController, alias: alias, room: room, url: url);
  }
}

// Creating message and sending its values to cloud firestore.
void _sendGIF({
  @required ScrollController scrollController,
  @required String alias,
  @required String room,
  @required String url,
}) async {
  var sTime = DateTime.now().millisecondsSinceEpoch;
  await Firestore.instance
      .collection('messages')
      .document('rooms')
      .collection(room)
      .document(sTime.toString())
      .setData(<String, dynamic>{
    'from': alias,
    'image': true,
    'message': url,
    'time': sTime,
  }, merge: false).then((r) {
    Timer(Duration(milliseconds: 100), () => scrollController.jumpTo(scrollController.position.minScrollExtent));
    print('Document successfully written!');
  }).catchError((error) {
    print('Error writing document: ' + error.toString());
  });
}
