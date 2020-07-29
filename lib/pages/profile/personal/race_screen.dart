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

class RaceScreen extends StatefulWidget {
  RaceScreen({@required this.user});

  final FirebaseUser user;

  @override
  RaceScreenState createState() => RaceScreenState(user: user);
}

class RaceScreenState extends State<RaceScreen> {
  RaceScreenState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  DateTime birthday;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('My race'),
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
                  color: black,
                ),
                title: Text(
                  'Asian',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateRace('asian');
                  Navigator.pop(context);
                }),
            Divider(color: Colors.grey),
            ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.child,
                  color: black,
                ),
                title: Text(
                  'Black',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateRace('black');
                  Navigator.pop(context);
                }),
            Divider(color: Colors.grey),
            ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.child,
                  color: black,
                ),
                title: Text(
                  'Latinx',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateRace('latinx');
                  Navigator.pop(context);
                }),
            Divider(color: Colors.grey),
            ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.child,
                  color: black,
                ),
                title: Text(
                  'White',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateRace('white');
                  Navigator.pop(context);
                }),
            Divider(color: Colors.grey),
            ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.child,
                  color: black,
                ),
                title: Text(
                  'Other',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateRace('other');
                  Navigator.pop(context);
                }),
          ],
        ));
  }

  Future<void> _updateRace(String race) async {
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('data')
        .document('userSettings')
        .setData(<String, dynamic>{
      'race': race,
    }, merge: true).catchError((error) {
      print('Error writing document: ' + error.toString());
    });
  }
}
