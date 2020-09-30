import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

import '../app_variables.dart';

class Advertisements {
  InterstitialAd _interstitialAd;
  int _counter = 1;

  void start() {
    _loadInterstitial();
  }

  Future<void> interstitial({@required int tapsInBetween}) async {
    // Showing advertisements after 2 taps
    if (_counter % (tapsInBetween + 1) == 0 || tapsInBetween == 0) {
      await _interstitialAd.show(
        anchorType: AnchorType.bottom,
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
      );

      _loadInterstitial();
    }

    if (tapsInBetween != 0) {
      _counter++;
    }
  }

  void _loadInterstitial() async {
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

    _interstitialAd = InterstitialAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: adMobInterstitialUnitID,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
      },
    );

    await _interstitialAd.load();
  }
}
