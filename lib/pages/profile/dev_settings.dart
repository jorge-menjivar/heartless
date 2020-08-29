import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frino_icons/frino_icons.dart';

final _biggerFont = const TextStyle(
  fontSize: 18.0,
);

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
  bool _deleteDatabase = false;

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
        appBar: AppBar(
          title: Text('DEV Settings'),
        ),
        body: ListView(
          shrinkWrap: true,
          primary: false,
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Divider(color: Colors.transparent),
            ListTile(
              leading: Icon(
                FrinoIcons.f_code,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              title: Text(
                'Delete Matches',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: Icon(
                FrinoIcons.f_check,
                color: (_deleteMatches) ? Colors.green : Colors.transparent,
              ),
              onTap: () async {
                setState(() {
                  _deleteMatches = !_deleteMatches;
                });
              },
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(
                FrinoIcons.f_code,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              title: Text(
                'Delete Potential Matches',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: Icon(
                FrinoIcons.f_check,
                color: (_deletePMatches) ? Colors.green : Colors.transparent,
              ),
              onTap: () async {
                setState(() {
                  _deletePMatches = !_deletePMatches;
                });
              },
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(
                FrinoIcons.f_code,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              title: Text(
                'Delete Users Met',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: Icon(
                FrinoIcons.f_check,
                color: (_deleteUsersMet) ? Colors.green : Colors.transparent,
              ),
              onTap: () async {
                setState(() {
                  _deleteUsersMet = !_deleteUsersMet;
                });
              },
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(
                FrinoIcons.f_code,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              title: Text(
                'Restore Tokens',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: Icon(
                FrinoIcons.f_check,
                color: (_restoreTokens) ? Colors.green : Colors.transparent,
              ),
              onTap: () async {
                setState(() {
                  _restoreTokens = !_restoreTokens;
                });
              },
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(
                FrinoIcons.f_code,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              title: Text(
                'Delete database',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: Icon(
                FrinoIcons.f_check,
                color: (_deleteDatabase) ? Colors.green : Colors.transparent,
              ),
              onTap: () async {
                setState(() {
                  _deleteDatabase = !_deleteDatabase;
                });
              },
            ),
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
