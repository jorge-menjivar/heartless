import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:lise/pages/profile/personal/gender_screen.dart';
import 'package:lise/pages/profile/personal/race_screen.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';

final _biggerFont = const TextStyle(
  fontSize: 18.0,
);

class PersonalInformationScreen extends StatefulWidget {
  PersonalInformationScreen({@required this.user});

  final FirebaseUser user;

  @override
  PersonalInformationScreenState createState() => PersonalInformationScreenState(user: user);
}

class PersonalInformationScreenState extends State<PersonalInformationScreen> {
  PersonalInformationScreenState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  DateTime _birthday;
  String _gender;
  String _name;
  String _race;

  @override
  void initState() {
    super.initState();
    _downloadData();
    _scrollController = ScrollController();
  }

  Future<void> _downloadData() async {
    String gender;
    String race;

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
        _name = doc.data['name'];
        _birthday = DateTime.fromMillisecondsSinceEpoch(doc.data['birthday']);
        gender = doc.data['gender'];
        race = doc.data['race'];
      }
    });

    // Setting gender in readable format
    if (gender == 'female') {
      _gender = 'Female';
    } else if (gender == 'male') {
      _gender = 'Male';
    } else if (gender == 'trans_female') {
      _gender = 'Trans Female';
    } else if (gender == 'trans_male') {
      _gender = 'Trans Male';
    } else if (gender == 'other') {
      _gender = 'Other';
    }

    // Setting race in readable format
    if (race == 'asian') {
      _race = 'Asian';
    } else if (race == 'black') {
      _race = 'Black';
    } else if (race == 'latinx') {
      _race = 'Latinx';
    } else if (race == 'white') {
      _race = 'White';
    } else if (race == 'other') {
      _race = 'Other';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // 100 years maximum for DatePicker
    final dateStart = DateTime(now.year - 100, now.month, now.day);

    // 18 years minimum for DatePicker
    final dateEnd = DateTime(now.year - 18, now.month, now.day);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('My Information'),
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
                FrinoIcons.f_edit,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              title: Row(
                children: <Widget>[
                  Text(
                    (_name != null) ? _name : '',
                    style: TextStyle(
                      fontSize: 26.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'We got your back!\nYour name and pictures are never shown together to strangers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(
                FrinoIcons.f_birthday,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              title: Row(
                children: <Widget>[
                  Text(
                    'My Birthday',
                    style: _biggerFont,
                  ),
                ],
              ),
              subtitle: Text(
                (_birthday != null) ? _readableTimeString(_birthday) : _readableTimeString(DateTime(2000, 1, 1)),
              ),
              onTap: () => showDatePicker(
                helpText: 'SELECT BIRTHDAY',
                fieldLabelText: 'Birthday',
                initialEntryMode: DatePickerEntryMode.input,
                initialDatePickerMode: DatePickerMode.year,
                firstDate: dateStart,
                initialDate: (_birthday != null) ? _birthday : DateTime(2000, 1, 1),
                lastDate: dateEnd,
                context: context,
              ).then((v) async {
                if (v != null) {
                  await _updateBirthday(v);
                }
              }),
            ),
            Divider(color: Colors.transparent),
            ListTile(
                leading: Icon(
                  FrinoIcons.f_baby,
                  color: IconTheme.of(context).color,
                  size: IconTheme.of(context).size,
                ),
                title: Text(
                  'My Gender',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                subtitle: Text((_gender != null) ? _gender : ''),
                onLongPress: () {},
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenderScreen(
                        user: user,
                      ),
                    ),
                  ).then((value) => _downloadData());
                }),
            Divider(color: Colors.transparent),
            ListTile(
                leading: Icon(
                  FrinoIcons.f_rocking_horse,
                  color: IconTheme.of(context).color,
                  size: IconTheme.of(context).size,
                ),
                title: Text(
                  'My Race',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                subtitle: Text((_race != null) ? _race : ''),
                onLongPress: () {},
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RaceScreen(
                                user: user,
                              ))).then((value) => _downloadData());
                }),
          ],
        ));
  }

  Future<void> _updateBirthday(DateTime dateTime) async {
    setState(() {
      _birthday = dateTime;
    });

    var epochBirthday = dateTime.millisecondsSinceEpoch;

    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('data')
        .document('userSettings')
        .updateData(<String, dynamic>{
      'birthday': epochBirthday,
    }).catchError((error) {
      print('Error writing document: ' + error.toString());
    });
  }

  String _readableTimeString(DateTime dateTime) {
    var month = dateTime.month;
    var day = dateTime.day;
    var year = dateTime.year;

    var monthString;
    switch (month) {
      case 1:
        monthString = 'January';
    }
    return '${month}/${day}/${year}';
  }
}
