import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:lise/widgets/loading_dialog.dart';
import 'package:lise/widgets/not_enough_tokens_dialog.dart';
import 'package:location/location.dart';

/// Updates the location of the device to the database and sends a request for a potential match.
Future<void> sendPotentialMatchRequest(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) async {
  showLoadingDialog(context);
  var location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

  // Checking is location is enabled in device
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();

    if (!serviceEnabled) {
      return false;
    }
  }

  // Checking if app has permission to get location
  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();

    if (permissionGranted != PermissionStatus.granted) {
      return false;
    }
  }

  // Getting location form device.
  locationData = await location.getLocation();

  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'getPotentialMatch',
  );

  // Adding variables to the server to the request and calling the function
  dynamic resp = await callable.call(
    <String, dynamic>{
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
    },
  );
  Navigator.pop(context);

  // If not able to send a new request because not enough tokens
  if (!resp.data['success']) {
    showNotEnoughTokensDialog(context);
  }
  return;
}
