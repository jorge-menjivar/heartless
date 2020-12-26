import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:lise/widgets/loading_dialog.dart';

/// Updates the location of the device to the database and sends a request for a potential match.
Future<void> createMeeting({
  @required BuildContext context,
  @required double latitude,
  @required double longitude,
  @required String locName,
  @required num dateTime,
  @required bool paying,
  @required String locAddress,
  @required String photoRef,
}) async {
  showLoadingDialog(context);

  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'createMeeting',
  );

  // Adding variables to the server to the request and calling the function
  HttpsCallableResult resp = await callable.call(
    <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locName,
      'location_address': locAddress,
      'date_time': dateTime,
      'paying': paying,
      'photo_ref': photoRef,
    },
  );

  print(resp.data);
  Navigator.pop(context);

  return;
}
