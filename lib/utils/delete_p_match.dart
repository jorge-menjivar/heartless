import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

Future<void> deletePotentialMatch(int time, String room, GlobalKey<ScaffoldState> scaffoldKey) async {
  final snackBar = SnackBar(
    content: Text(
      //TODO
      'Deleting Potential Match',
    ),
  );
  scaffoldKey.currentState.showSnackBar(snackBar);
  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'deletePotentialMatch',
  );

  // Adding variables to the server to the request and calling the function
  await callable.call(<String, dynamic>{
    'time': time,
    'room': room,
  });

  scaffoldKey.currentState.hideCurrentSnackBar();
  return;
}
