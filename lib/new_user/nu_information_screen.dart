import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/new_user/nu_upload_pictures_screen.dart';

// Tools
import 'package:lise/user_profile/personal/edit_name.dart';
import 'package:lise/user_profile/personal/gender_screen.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lise/user_profile/personal/race_screen.dart';
import 'package:lise/user_profile/search/gender_search_screen.dart';

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

class NewUserInformationScreen extends StatefulWidget {
  NewUserInformationScreen({@required this.user});

  final FirebaseUser user;

  @override
  NewUserInformationScreenState createState() => NewUserInformationScreenState(user: user);
}

class NewUserInformationScreenState extends State<NewUserInformationScreen> {
  NewUserInformationScreenState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  final _formFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _controllerDisplayName = TextEditingController();

  DateTime _birthday;
  String _userGender;
  String _name;
  String _race;

  bool _women = false;
  bool _men = false;
  bool _transWomen = false;
  bool _transMen = false;
  bool _others = false;

  @override
  void initState() {
    super.initState();
    _downloadData();
    _scrollController = ScrollController();
  }

  Future<void> _downloadData() async {
    String myGender;
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
        if (doc.data['name'] != null) {
          _name = doc.data['name'];
        }

        if (doc.data['birthday'] != null) {
          _birthday = DateTime.fromMillisecondsSinceEpoch(doc.data['birthday']);
        }

        if (doc.data['gender'] != null) {
          myGender = doc.data['gender'];
        }

        if (doc.data['race'] != null) {
          race = doc.data['race'];
        }

        if (doc.data['searchGender'] != null) {
          _women = doc.data['searchGender']['female'];
          _women = doc.data['searchGender']['female'];
          _men = doc.data['searchGender']['male'];
          _transWomen = doc.data['searchGender']['trans_female'];
          _transMen = doc.data['searchGender']['trans_male'];
          _others = doc.data['searchGender']['other'];
        }
      }

      setState(() {});
    });

    // Setting user gender in readable format
    if (myGender == 'female') {
      _userGender = 'Female';
    } else if (myGender == 'male') {
      _userGender = 'Male';
    } else if (myGender == 'trans_female') {
      _userGender = 'Trans Female';
    } else if (myGender == 'trans_male') {
      _userGender = 'Trans Male';
    } else if (myGender == 'other') {
      _userGender = 'Other';
    }

    // Setting user race in readable format
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Information'),
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
                FontAwesomeIcons.signature,
                color: black,
              ),
              title: Row(
                children: <Widget>[
                  Text(
                    (_name != null) ? _name : '',
                    style: TextStyle(
                      fontSize: 26.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              trailing: FaIcon(
                FontAwesomeIcons.check,
                color: (_name != null) ? Colors.green : Colors.transparent,
              ),
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditNameScreen(
                              user: user,
                            ))).then((value) => _downloadData());
              }),
          Container(
            padding: EdgeInsets.all(10),
            color: white,
            child: Text(
              'We got your back!\nYour name and pictures are never shown together to strangers.',
              textAlign: TextAlign.center,
              style: _subFont,
            ),
          ),
          Divider(color: Colors.grey),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.birthdayCake,
              color: black,
            ),
            title: Row(
              children: <Widget>[
                Text(
                  'Birthday',
                  style: _biggerFont,
                ),
              ],
            ),
            subtitle: Text(
              (_birthday != null) ? _readableTimeString(_birthday) : _readableTimeString(DateTime(2000, 1, 1)),
            ),
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_birthday != null) ? Colors.green : Colors.transparent,
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
              leading: FaIcon(
                FontAwesomeIcons.baby,
                color: black,
              ),
              title: Text(
                'Gender',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              subtitle: Text((_userGender != null) ? _userGender : ''),
              trailing: FaIcon(
                FontAwesomeIcons.check,
                color: (_userGender != null) ? Colors.green : Colors.transparent,
              ),
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GenderScreen(
                              user: user,
                            ))).then((value) => _downloadData());
              }),
          ListTile(
              leading: FaIcon(
                FontAwesomeIcons.solidHeart,
                color: black,
              ),
              title: Text(
                'I am interested in',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: FaIcon(
                FontAwesomeIcons.check,
                color: (_women || _men || _transWomen || _transMen || _others) ? Colors.green : Colors.transparent,
              ),
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
              leading: FaIcon(
                FontAwesomeIcons.child,
                color: black,
              ),
              title: Text(
                'My Race',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              subtitle: Text((_race != null) ? _race : ''),
              trailing: FaIcon(
                FontAwesomeIcons.check,
                color: (_race != null) ? Colors.green : Colors.transparent,
              ),
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RaceScreen(
                              user: user,
                            ))).then((value) => _downloadData());
              }),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        color: black,
        child: ListTile(
          trailing: Container(
            child: IconButton(
              iconSize: 45,
              icon: Text('NEXT',
                  style: TextStyle(
                    color: white,
                    fontSize: 14.0,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  )),
              onPressed: () async {
                if ((_women || _men || _transWomen || _transMen || _others) &&
                    (_name != null && _birthday != null && _userGender != null && _race != null)) {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UploadPicturesScreen(
                                user: user,
                              )));
                } else {
                  print('not complete');
                }
              },
            ),
          ),
        ),
      ),
    );
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
        .setData(<String, dynamic>{
      'birthday': epochBirthday,
    }, merge: true).catchError((error) {
      print('Error writing document: ' + error.toString());
    });
  }

  String _readableTimeString(DateTime dateTime) {
    var month = dateTime.month;
    var day = dateTime.day;
    var year = dateTime.year;

    return '${month}/${day}/${year}';
  }
}
