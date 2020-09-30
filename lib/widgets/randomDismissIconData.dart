import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData randomDismissIconData() {
  var random = Random(DateTime.now().millisecondsSinceEpoch).nextInt(4);
  var dismissIcon;
  switch (random) {
    case 0:
      dismissIcon = FontAwesomeIcons.kissWinkHeart;
      break;

    case 1:
      dismissIcon = FontAwesomeIcons.grinTongueSquint;
      break;

    case 2:
      dismissIcon = FontAwesomeIcons.grinBeamSweat;
      break;

    case 3:
      dismissIcon = FontAwesomeIcons.grinSquintTears;

      break;
  }

  return dismissIcon;
}
