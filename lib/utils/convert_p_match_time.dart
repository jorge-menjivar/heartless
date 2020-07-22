import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lise/utils/send_connection_request.dart';

import '../localizations.dart';

String convertPMatchTime({BuildContext context, String userID, int time, String roomKey}) {
  var minutes = DateTime.fromMillisecondsSinceEpoch(time).difference(DateTime.now()).inMinutes;

  var hours = DateTime.fromMillisecondsSinceEpoch(time).difference(DateTime.now()).inHours;

  var days = DateTime.fromMillisecondsSinceEpoch(time).difference(DateTime.now()).inDays;

  // Sending connection request 24 hours before the connection screen is shown to have profiles ready and prevent slowdown in the app
  if (hours < 36) {
    Firestore.instance
        .collection('users')
        .document('${userID}')
        .collection('data_generated')
        .document('user_rooms')
        .collection('p_matches')
        .document('$roomKey')
        .get()
        .then(
      (doc) {
        if (!doc.exists) {
          print('No data document!');
        } else {
          if (doc.data['connections'] == null || doc.data['connections'].length == 0) {
            sendConnectionsRequest(roomKey);
          }
        }
      },
    );
  }
  if (minutes < 0) {
    return AppLocalizations.of(context).translate('COMPLETED');
  }

  if (minutes < 60) {
    return (minutes > 1)
        ? '$minutes ${AppLocalizations.of(context).translate('minutes_left')}'
        : '$minutes ${AppLocalizations.of(context).translate('minute_left')}';
  } else if (hours < 24) {
    return (hours > 1)
        ? '$hours ${AppLocalizations.of(context).translate('hours_left')}'
        : '$hours ${AppLocalizations.of(context).translate('hour_left')}';
  } else if (days > 0) {
    if (days > 1) {
      if (hours % 24 > 1) {
        return '$days days, ${hours % 24} ${AppLocalizations.of(context).translate('hours_left')}';
      } else {
        return '$days days, ${hours % 24} ${AppLocalizations.of(context).translate('hour_left')}';
      }
    } else {
      if (hours % 24 > 1) {
        return '$days day, ${hours % 24} ${AppLocalizations.of(context).translate('hours_left')}';
      } else {
        return '$days day, ${hours % 24} ${AppLocalizations.of(context).translate('hour_left')}';
      }
    }
  }

  return ' ';
}
