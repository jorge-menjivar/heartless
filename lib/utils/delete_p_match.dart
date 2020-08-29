import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:lise/widgets/loading_dialog.dart';

Future<void> deletePotentialMatch(
    BuildContext context, int time, String room, GlobalKey<ScaffoldState> scaffoldKey) async {
  showLoadingDialog(context);
  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'deletePotentialMatch',
  );

  // Adding variables to the server to the request and calling the function
  await callable.call(<String, dynamic>{
    'time': time,
    'room': room,
  });

  Navigator.pop(context);
  return;
}
