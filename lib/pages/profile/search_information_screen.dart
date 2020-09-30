import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:lise/pages/profile/search/gender_search_screen.dart';
import 'package:lise/pages/profile/search/race_search_screen.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';

final _biggerFont = const TextStyle(
  fontSize: 18.0,
);

class SearchInformationScreen extends StatefulWidget {
  SearchInformationScreen({@required this.user});

  final FirebaseUser user;

  @override
  SearchInformationScreenState createState() => SearchInformationScreenState(user: user);
}

class SearchInformationScreenState extends State<SearchInformationScreen> {
  SearchInformationScreenState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  RangeValues _ageRange = RangeValues(18, 30);

  double _distance = 20;

  @override
  void initState() {
    super.initState();
    _downloadData();
    _scrollController = ScrollController();
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
        _ageRange = RangeValues(doc.data['searchMinAge'].toDouble(), doc.data['searchMaxAge'].toDouble());
        _distance = doc.data['searchMaxDistance'].toDouble();
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Search Settings'),
        ),
        body: ListView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Divider(color: Colors.transparent),
            ListTile(
                leading: Icon(
                  FrinoIcons.f_search,
                  color: IconTheme.of(context).color,
                  size: IconTheme.of(context).size,
                ),
                title: Text(
                  'I am interested in',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onLongPress: () {},
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GenderSearchScreen(
                                user: user,
                              ))).then((value) => _downloadData());
                }),
            Divider(color: Colors.transparent),
            ListTile(
                leading: Icon(
                  FrinoIcons.f_rocking_horse,
                  color: IconTheme.of(context).color,
                  size: IconTheme.of(context).size,
                ),
                title: Text(
                  'Races',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RaceSearchScreen(
                                user: user,
                              ))).then((value) => _downloadData());
                }),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(
                FrinoIcons.f_calendar,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              title: Text(
                'Age Range',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: Text(
                (_ageRange.end.round() != 50)
                    ? ('${_ageRange.start.round()} - ${_ageRange.end.round()} years')
                    : ('${_ageRange.start.round()} - ${_ageRange.end.round()}+ years'),
                textAlign: TextAlign.end,
                style: _biggerFont,
              ),
            ),
            RangeSlider(
                labels: (_ageRange.end.round() != 50)
                    ? RangeLabels('${_ageRange.start.round()}', '${_ageRange.end.round()}')
                    : RangeLabels('${_ageRange.start.round()}', '${_ageRange.end.round()}+'),
                //divisions: 32,
                min: 18,
                max: 50,
                values: _ageRange,
                onChangeEnd: (value) async {
                  await _saveAge();
                },
                onChanged: (value) {
                  setState(() {
                    _ageRange = RangeValues(value.start.round().toDouble(), value.end.round().toDouble());
                  });
                }),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(
                FrinoIcons.f_compass,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              title: Text(
                'Maximum Distance',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: Text(
                '${_distance.round()} miles',
                style: _biggerFont,
              ),
            ),
            Slider(
                label: '${_distance.round()} miles',
                value: _distance,
                //divisions: 30,
                min: 10,
                max: 40,
                onChangeEnd: (value) async {
                  await _saveDistance();
                },
                onChanged: (value) {
                  setState(() {
                    _distance = value.round().toDouble();
                  });
                }),
            Divider(color: Colors.grey),
          ],
        ));
  }

  Future<void> _saveAge() async {
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('data')
        .document('userSettings')
        .setData(<String, dynamic>{
      'searchMinAge': _ageRange.start.round(),
      'searchMaxAge': _ageRange.end.round(),
    }, merge: true).catchError((error) {
      print('Error writing document: ' + error.toString());
    });
  }

  Future<void> _saveDistance() async {
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('data')
        .document('userSettings')
        .setData(<String, dynamic>{
      'searchMaxDistance': _distance,
      'searchDistanceUnit': 'mile',
    }, merge: true).catchError((error) {
      print('Error writing document: ' + error.toString());
    });
  }
}
