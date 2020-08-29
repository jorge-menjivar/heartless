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

class GenderScreen extends StatefulWidget {
  GenderScreen({@required this.user});

  final FirebaseUser user;

  @override
  GenderScreenState createState() => GenderScreenState(user: user);
}

class GenderScreenState extends State<GenderScreen> {
  GenderScreenState({@required this.user});

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
        appBar: AppBar(
          title: Text('Gender'),
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
                leading: Icon(
                  FrinoIcons.f_lab,
                  color: IconTheme.of(context).color,
                  size: IconTheme.of(context).size,
                ),
                title: Text(
                  'Female',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateGender('female');
                  Navigator.pop(context);
                }),
            Divider(color: Colors.grey),
            ListTile(
                leading: Icon(
                  FrinoIcons.f_lab,
                  color: IconTheme.of(context).color,
                  size: IconTheme.of(context).size,
                ),
                title: Text(
                  'Male',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateGender('male');
                  Navigator.pop(context);
                }),
            Divider(color: Colors.grey),
            ListTile(
                leading: Icon(
                  FrinoIcons.f_lab,
                  color: IconTheme.of(context).color,
                  size: IconTheme.of(context).size,
                ),
                title: Text(
                  'Trans Female',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateGender('trans_female');
                  Navigator.pop(context);
                }),
            Divider(color: Colors.grey),
            ListTile(
                leading: Icon(
                  FrinoIcons.f_lab,
                  color: IconTheme.of(context).color,
                  size: IconTheme.of(context).size,
                ),
                title: Text(
                  'Trans Male',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateGender('trans_male');
                  Navigator.pop(context);
                }),
            Divider(color: Colors.grey),
            ListTile(
                leading: Icon(
                  FrinoIcons.f_lab,
                  color: IconTheme.of(context).color,
                  size: IconTheme.of(context).size,
                ),
                title: Text(
                  'Other',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () {
                  _updateGender('other');
                  Navigator.pop(context);
                }),
          ],
        ));
  }

  Future<void> _updateGender(String gender) async {
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('data')
        .document('userSettings')
        .setData(<String, dynamic>{
      'gender': gender,
    }, merge: true).catchError((error) {
      print('Error writing document: ' + error.toString());
    });
  }
}
