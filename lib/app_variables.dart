import 'package:flutter/material.dart';

class AppVariables {
  static final int DEFAULT_ROW_COUNT = 20;

  int convoRowCount = DEFAULT_ROW_COUNT;
  Map<String, bool> convoOpen = {};

  bool nightModeON = false;
  static final Color NIGHT_MODE_COLOR_BACKGROUND = Colors.black12;
  static final Color DAY_MODE_COLOR_BACKGROUND = Colors.white;
}
