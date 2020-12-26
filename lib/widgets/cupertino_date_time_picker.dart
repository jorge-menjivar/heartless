import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime> showCupertinoDateTimePicker(
    {@required BuildContext context,
    @required DateTime dateStart,
    @required DateTime dateEnd,
    @required Widget title,
    @required CupertinoDatePickerMode mode,
    @required DateTime initialDateTime}) async {
  var tempDate;
  var date;

  await showCupertinoModalPopup(
    context: context,
    builder: (BuildContext modalContext) => CupertinoActionSheet(
      title: title,
      cancelButton: CupertinoDialogAction(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      message: Container(
        height: MediaQuery.of(context).size.height / 4,
        child: CupertinoDatePicker(
          initialDateTime: initialDateTime,
          minimumDate: dateStart,
          maximumDate: dateEnd,
          mode: mode,
          onDateTimeChanged: (dateTime) {
            tempDate = dateTime;
          },
        ),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text("Done"),
          onPressed: () {
            date = (tempDate != null) ? tempDate : initialDateTime;
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );

  return date;
}
