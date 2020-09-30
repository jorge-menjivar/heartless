import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

/// The action that will be sent to the server
enum EditLikeAction { remove, add }

/// Sends a call to the server to add or remove a like from the account
Future<void> sendEditLikeCall(BuildContext context,
    {@required String interestName, @required EditLikeAction action}) async {
  print(action.index);

  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'editLikes',
  );

  // Adding variables to the server to the request and calling the function
  dynamic resp = await callable.call(
    <String, dynamic>{
      'interestName': interestName,
      'action': action.index,
    },
  );

  print(resp);

  return;
}
