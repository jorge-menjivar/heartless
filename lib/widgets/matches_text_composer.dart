import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:giphy_picker/giphy_picker.dart';

class MatchesTextComposer extends StatelessWidget {
  final ScrollController scrollController;
  final TextEditingController textController;
  final String userID;
  final String room;

  MatchesTextComposer({
    @required this.scrollController,
    @required this.textController,
    @required this.userID,
    @required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    FrinoIcons.f_gif,
                    color: Colors.blue,
                  ),
                  onPressed: () => pickGIF(context)),
              Flexible(
                child: Platform.isIOS ? cupertinoTextField(context) : materialTextField(context),
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

  Widget sendIcon() {
    return IconButton(
      icon: Icon(
        FrinoIcons.f_send,
        color: Colors.pink,
      ),
      onPressed: () {
        if (textController.text.contains(RegExp(r'\S'))) {
          _sendMessage();
        }
      },
    );
  }

  Widget materialTextField(BuildContext context) {
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
        suffixIcon: sendIcon(),
        hintText: 'Write a message',
        fillColor: Theme.of(context).splashColor,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white54 : Colors.black12,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white12 : Colors.black12,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white12 : Colors.black12,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
      ),
    );
  }

  Widget cupertinoTextField(BuildContext context) {
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
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyText2.color,
      ),
      controller: textController,
      placeholder: "Write a message",
      suffix: Container(
        margin: EdgeInsets.symmetric(horizontal: 0.0),
        child: sendIcon(),
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white12 : Colors.black12,
        ),
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

// Creating message and sending its values to cloud firestore.
  void _sendMessage() async {
    var text = textController.text;
    textController.clear();
    var sTime = DateTime.now().millisecondsSinceEpoch;
    await Firestore.instance
        .collection('messages')
        .document('rooms')
        .collection(room)
        .document(sTime.toString())
        .setData(<String, dynamic>{
      'from': userID,
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

  void pickGIF(BuildContext context) async {
    final gif = await GiphyPicker.pickGif(
      context: context,
      apiKey: '9fUDytWSqLwokwmGIinJbhajQj1C87N2',
    );

    if (gif != null) {
      final url = gif.images.original.url;
      _sendGIF(url: url);
    }
  }

// Creating message and sending its values to cloud firestore.
  void _sendGIF({
    @required String url,
  }) async {
    var sTime = DateTime.now().millisecondsSinceEpoch;
    await Firestore.instance
        .collection('messages')
        .document('rooms')
        .collection(room)
        .document(sTime.toString())
        .setData(<String, dynamic>{
      'from': userID,
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
}
