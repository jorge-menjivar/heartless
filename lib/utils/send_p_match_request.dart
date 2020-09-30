import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:lise/widgets/loading_dialog.dart';
import 'package:lise/widgets/not_enough_tokens_dialog.dart';
import 'package:location/location.dart';

import '../app_variables.dart';

/// Updates the location of the device to the database and sends a request for a potential match.
Future<void> sendPotentialMatchRequest(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) async {
  showLoadingDialog(context);
  var location = Location();

  print(location);

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

  InterstitialAd interstitialAd;
  var adMobInterstitialUnitID;
  if (Platform.isIOS) {
    adMobInterstitialUnitID = AppVariables.AD_MOB_INTERSTITIAL_ID_IOS;
  } else if (Platform.isAndroid) {
    adMobInterstitialUnitID = AppVariables.AD_MOB_INTERSTITIAL_ID_ANDROID;
  }

  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutter', 'LISA'],
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  interstitialAd = InterstitialAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: adMobInterstitialUnitID,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("InterstitialAd event is $event");
    },
  );

  await interstitialAd.load();

  await interstitialAd.show(
    anchorType: AnchorType.bottom,
    anchorOffset: 0.0,
    horizontalCenterOffset: 0.0,
  );

  Navigator.pop(context);

  // If not able to send a new request because not enough tokens
  if (!resp.data['success']) {
    showNotEnoughTokensDialog(context);
  }
}
