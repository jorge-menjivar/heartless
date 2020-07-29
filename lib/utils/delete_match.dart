import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:lise/utils/database.dart';
import 'package:sqflite/sqflite.dart';

Future<void> deleteMatch(Database db, int time, String room, GlobalKey<ScaffoldState> scaffoldKey) async {
  final snackBar = SnackBar(
    content: Text(
      //TODO
      'Deleting Match',
    ),
  );
  scaffoldKey.currentState.showSnackBar(snackBar);

  /*
  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'deleteMatch',
  );

  // Adding variables to the server to the request and calling the function
  await callable.call(
    <String, dynamic>{
      'time': time,
      'room': room,
    },
  );
  */

  dropTable(db, room);

  scaffoldKey.currentState.hideCurrentSnackBar();
  return;
}
