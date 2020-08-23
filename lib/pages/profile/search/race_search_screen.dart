import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';

final _biggerFont = const TextStyle(
  fontSize: 18.0,
);

class RaceSearchScreen extends StatefulWidget {
  RaceSearchScreen({@required this.user});

  final FirebaseUser user;

  @override
  RaceSearchScreenState createState() => RaceSearchScreenState(user: user);
}

class RaceSearchScreenState extends State<RaceSearchScreen> {
  RaceSearchScreenState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  DateTime birthday;

  bool _asian = true;
  bool _black = true;
  bool _latinx = true;
  bool _white = true;
  bool _other = true;

  @override
  void initState() {
    super.initState();
    _downloadData();
  }

  Future<void> _downloadData() async {
    // Downloading data and synchronizing it with public variables
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('data')
        .document('userSettings')
        .get()
        .then((doc) {
      if (!doc.exists) {
        print('No data document!');
      } else {
        _asian = doc.data['searchRace']['asian'];
        _black = doc.data['searchRace']['black'];
        _latinx = doc.data['searchRace']['latinx'];
        _white = doc.data['searchRace']['white'];
        _other = doc.data['searchRace']['other'];
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _save,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Races'),
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
                      FontAwesomeIcons.child,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'Asian',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: FaIcon(
                      FontAwesomeIcons.check,
                      color: (_asian) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _asian = !_asian;
                      });
                    }),
                Divider(color: Colors.grey),
                ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.child,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'Black',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: FaIcon(
                      FontAwesomeIcons.check,
                      color: (_black) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _black = !_black;
                      });
                    }),
                Divider(color: Colors.grey),
                ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.child,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'Latinx',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: FaIcon(
                      FontAwesomeIcons.check,
                      color: (_latinx) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _latinx = !_latinx;
                      });
                    }),
                Divider(color: Colors.grey),
                ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.child,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'White',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: FaIcon(
                      FontAwesomeIcons.check,
                      color: (_white) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _white = !_white;
                      });
                    }),
                Divider(color: Colors.grey),
                ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.child,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'Other',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: FaIcon(
                      FontAwesomeIcons.check,
                      color: (_other) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _other = !_other;
                      });
                    }),
              ],
            )));
  }

  Future<bool> _save() async {
    // If user made a choice, save it to the cloud
    if (_asian || _black || _latinx || _white || _other) {
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('data')
          .document('userSettings')
          .setData(<String, dynamic>{
        'searchRace': {
          'asian': _asian,
          'black': _black,
          'latinx': _latinx,
          'white': _white,
          'other': _other,
        },
      }, merge: true).catchError((error) {
        print('Error writing document: ' + error.toString());
      });
      Navigator.pop(context);
    }
    return false;
  }
}
