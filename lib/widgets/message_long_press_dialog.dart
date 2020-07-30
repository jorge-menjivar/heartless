import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';

MessageLongPressDialog(BuildContext context, var row) {
  return showDialog(
    barrierDismissible: true,
    context: context,
    child: SimpleDialog(
      contentPadding: EdgeInsets.all(0),
      titlePadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SimpleDialogOption(
            child: IconButton(
              iconSize: 32,
              icon: FaIcon(FontAwesomeIcons.copy),
              onPressed: () {
                //TODO
                FlutterClipboard.copy(row['message']).then((value) =>
                    //TODO
                    Toast.show("Message copied to clipboard", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM));
                Navigator.of(context).pop();
              },
            ),
          ),
          SimpleDialogOption(
            child: IconButton(
              iconSize: 32,
              icon: FaIcon(FontAwesomeIcons.info),
              onPressed: () {
                //TODO
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    ),
  );
}
