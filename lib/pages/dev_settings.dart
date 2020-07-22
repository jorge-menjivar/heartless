import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';

Map<int, Color> color = {
  50: Color.fromRGBO(0, 0, 0, .1),
  100: Color.fromRGBO(0, 0, 0, .2),
  200: Color.fromRGBO(0, 0, 0, .3),
  300: Color.fromRGBO(0, 0, 0, .4),
  400: Color.fromRGBO(0, 0, 0, .5),
  500: Color.fromRGBO(0, 0, 0, .6),
  600: Color.fromRGBO(0, 0, 0, .7),
  700: Color.fromRGBO(0, 0, 0, .8),
  800: Color.fromRGBO(0, 0, 0, .9),
  900: Color.fromRGBO(0, 0, 0, 1),
};
MaterialColor black = MaterialColor(0xFF000000, color);
MaterialColor white = MaterialColor(0xFFFFFFFF, color);

final _biggerFont = const TextStyle(
  fontSize: 18.0,
  color: Colors.black,
);
final _subFont = const TextStyle(
  color: Colors.black,
);
final _trailFont = const TextStyle(
  color: Colors.black,
);
final _listTitleStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
var _iconColor = black;

class DevSettings extends StatefulWidget {
  DevSettings({@required this.user});

  final FirebaseUser user;

  @override
  DevSettingsState createState() => DevSettingsState(user: user);
}

class DevSettingsState extends State<DevSettings> {
  DevSettingsState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  bool _deleteMatches = false;
  bool _deletePMatches = false;
  bool _deleteUsersMet = false;
  bool _restoreTokens = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _save,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('DEV Settings'),
          elevation: 4.0,
        ),
        body: ListView(
          shrinkWrap: true,
          primary: false,
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Divider(color: Colors.transparent),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.bug,
                color: black,
              ),
              title: Text(
                'Delete Matches',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: FaIcon(
                FontAwesomeIcons.check,
                color: (_deleteMatches) ? black : Colors.transparent,
              ),
              onTap: () async {
                setState(() {
                  _deleteMatches = !_deleteMatches;
                });
              },
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.bug,
                color: black,
              ),
              title: Text(
                'Delete Potential Matches',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: FaIcon(
                FontAwesomeIcons.check,
                color: (_deletePMatches) ? black : Colors.transparent,
              ),
              onTap: () async {
                setState(() {
                  _deletePMatches = !_deletePMatches;
                });
              },
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.bug,
                color: black,
              ),
              title: Text(
                'Delete Users Met',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: FaIcon(
                FontAwesomeIcons.check,
                color: (_deleteUsersMet) ? black : Colors.transparent,
              ),
              onTap: () async {
                setState(() {
                  _deleteUsersMet = !_deleteUsersMet;
                });
              },
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.bug,
                color: black,
              ),
              title: Text(
                'Restore Tokens',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: FaIcon(
                FontAwesomeIcons.check,
                color: (_restoreTokens) ? black : Colors.transparent,
              ),
              onTap: () async {
                setState(() {
                  _restoreTokens = !_restoreTokens;
                });
              },
            ),
            Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<bool> _save() async {
    // If user made a choice, save it to the cloud
    if (_deleteMatches) {
      final matchesQuery = await Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data_generated')
          .document('user_rooms')
          .collection('matches')
          .getDocuments();

      for (var match in matchesQuery.documents) {
        var id = match.documentID;
        await Firestore.instance
            .collection('users')
            .document('${user.uid}')
            .collection('data_generated')
            .document('user_rooms')
            .collection('matches')
            .document(id)
            .delete();
      }
    }

    if (_deletePMatches) {
      final matchesQuery = await Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data_generated')
          .document('user_rooms')
          .collection('p_matches')
          .where('time', isGreaterThanOrEqualTo: 0)
          .getDocuments();

      for (var match in matchesQuery.documents) {
        var id = match.documentID;
        await Firestore.instance
            .collection('users')
            .document('${user.uid}')
            .collection('data_generated')
            .document('user_rooms')
            .collection('p_matches')
            .document(id)
            .delete();
      }
    }

    if (_deleteUsersMet) {
      await Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data')
          .document('private')
          .updateData(<String, dynamic>{
        'usersMet': [],
      });
    }

    if (_restoreTokens) {
      await Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data')
          .document('private')
          .updateData(<String, dynamic>{
        'requestsAvailable': 3,
      });
    }

    Navigator.pop(context);
    return false;
  }
}
