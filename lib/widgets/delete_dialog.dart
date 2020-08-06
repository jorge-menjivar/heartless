import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows an alert asking the user if delete should really be done
Future<bool> showDeleteDialog(BuildContext context, String name, String status) async {
  var choice = false;

  var message;

  if (status == 'pMatch' || status == 'match') {
    message = 'Do you really want to delete the conversation with $name?';
  } else if (status == 'request') {
    message = 'Do you really want to delete this request?';
  }

  // Await for the dialog to be dismissed before returning
  (Platform.isIOS)
      ? await showCupertinoDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Are you sure?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(message),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("I\'m sure"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    choice = true;
                  },
                ),
              ],
            );
          },
        )
      : await showDialog<bool>(
          context: context,
          barrierDismissible: true, // user can type outside box to dismiss
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(message),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("I\'m sure"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    choice = true;
                  },
                ),
              ],
            );
          },
        );
  return choice;
}
