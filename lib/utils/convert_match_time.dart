import 'package:flutter/material.dart';

import '../localizations.dart';

String convertMatchTime(BuildContext context, int time) {
  var dateTime = DateTime.fromMillisecondsSinceEpoch(time);

  var minutes = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(time)).inMinutes;

  var hours = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(time)).inHours;

  var days = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(time)).inDays;

  if (minutes < 1) {
    return AppLocalizations.of(context).translate('Just_now');
  } else if (minutes < 60) {
    return (minutes > 1)
        ? '$minutes ${AppLocalizations.of(context).translate('minutes_ago')}'
        : '$minutes ${AppLocalizations.of(context).translate('minute_ago')}';
  } else if (hours < 24) {
    return (hours > 1)
        ? '$hours ${AppLocalizations.of(context).translate('hours_ago')}'
        : '$hours ${AppLocalizations.of(context).translate('hour_ago')}';
  } else if (days < 7) {
    return (days > 1)
        ? '${days} ${AppLocalizations.of(context).translate('days_ago')}'
        : '${days} ${AppLocalizations.of(context).translate('day_ago')}';
  } else if (days >= 7) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  return '';
}
