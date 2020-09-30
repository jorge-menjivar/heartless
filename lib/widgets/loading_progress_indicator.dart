import 'package:flutter/material.dart';

Widget loading_progress_indicator({double value}) {
  if (value != null) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(4),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent[400]),
          value: value,
        ),
      ),
    );
  } else {
    return Center(
      child: Container(
        padding: EdgeInsets.all(4),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent[400]),
        ),
      ),
    );
  }
}
