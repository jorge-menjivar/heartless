import 'package:flutter/material.dart';

class AppVariables {
  static final int DEFAULT_ROW_COUNT = 20;

  int convoRowCount = DEFAULT_ROW_COUNT;
  Map<String, bool> convoOpen = {};

  static final String AD_MOB_APP_ID_ANDROID = 'ca-app-pub-3406887840465649~2347320999';
  static final String AD_MOB_APP_ID_IOS = 'ca-app-pub-3406887840465649~9459524254';

  static final String AD_MOB_INTERSTITIAL_ID_ANDROID = 'ca-app-pub-3940256099942544/8691691433'; // Test ad
  static final String AD_MOB_INTERSTITIAL_ID_IOS = 'ca-app-pub-3940256099942544/5135589807'; // Test ad

  static final String MAPS_KEY = 'AIzaSyDqfYdbII8ZpRln9ZVFn5KAPmDo4UBICOI';

  bool nightModeON = false;
  static final Color NIGHT_MODE_COLOR_BACKGROUND = Colors.black12;
  static final Color DAY_MODE_COLOR_BACKGROUND = Colors.white;
}
