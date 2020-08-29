import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lise/widgets/loading_progress_indicator.dart';

showLoadingDialog(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    child: Center(
      child: loading_progress_indicator(),
    ),
  );
}
