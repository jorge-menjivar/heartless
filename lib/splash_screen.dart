import 'package:flutter/material.dart';
import 'package:lise/widgets/loading_progress_indicator.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: Center(
        child: loading_progress_indicator(),
      ),
    );
  }
}
