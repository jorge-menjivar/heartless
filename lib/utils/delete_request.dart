import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

Future<void> deleteRequest(String key, GlobalKey<ScaffoldState> scaffoldKey) async {
  final snackBar = SnackBar(
    content: Text(
      //TODO
      'Deleting Request',
    ),
  );
  scaffoldKey.currentState.showSnackBar(snackBar);

  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'deleteRequest',
  );

  // Adding variables to the server to the request and calling the function
  await callable.call(
    <String, dynamic>{
      'requestKey': key,
    },
  );

  scaffoldKey.currentState.hideCurrentSnackBar();
  return;
}
