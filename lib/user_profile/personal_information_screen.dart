import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Tools
import 'package:lise/user_profile/personal/edit_name.dart';
import 'package:lise/user_profile/personal/gender_screen.dart';


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
final _listTitleStyle = const TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold
);
var _iconColor = black;



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
  
  @override
  void initState() {
    super.initState();
    _downloadData();
    _scrollController = ScrollController();
    //TODO _checkCurrentUser();
  }
  
  
  Future<void> _downloadData() async{
    
    String gender;
    
    // Downloading data and synchronizing it with public variables
    await Firestore.instance
      .collection('users')
      .document(user.uid)
      .collection('data')
      .document('personal')
      .get()
      .then((doc) {
        if (!doc.exists) {
          print('No data document!');
        } else {
          _name = doc.data['name'];
          _birthday = DateTime.fromMillisecondsSinceEpoch(doc.data['birthday']);
          gender = doc.data['gender'];
        }
      });
    
    
    // Setting gender in readable format
    if (gender == 'female') {
      _gender = 'Female';
    }
    else if (gender == 'male') {
      _gender = 'Male';
    }
    else if (gender == 'trans_female') {
      _gender = 'Trans Female';
    }
    else if (gender == 'trans_male') {
      _gender = 'Trans Male';
    }
    else if (gender == 'other') {
      _gender = 'Other';
    }
    
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
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
          Divider(
            color: Colors.transparent
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.signature,
              color: black,
            ),
            title: Row(
              children: <Widget>[
                Text(
                  _name,
                  style: _biggerFont,
                ),
              ],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNameScreen(user: user,)
                )
              ).then((value) => _downloadData());
            }
          ),
          Container (
            padding: EdgeInsets.all(10),
            color: white[50],
            child: Flexible(
                child: 
                  Center(
                    child: Text(
                      'Your potential match is able to see your name in the conversation screen,\n\nbut your name will NOT be displayed next to your pictures until you have matched',
                      textAlign: TextAlign.center,
                      style: _subFont,
                    )
              ),
            ),
          ),
          Divider(
            color: Colors.transparent
          ),
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
            onTap: () => showDatePicker(
              //TODO 100 years
              firstDate: DateTime(1900, 1),
              initialDate: (_birthday != null) ? _birthday : DateTime(2000, 1, 1),
              
              //TODO 18 years
              lastDate: DateTime(2002, 1),
              context: context,
            ).then((v) async => await _updateBirthday(v)),
          ),
          Divider(
            color: Colors.transparent
          ),
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
            subtitle: Text(
              (_gender != null) ? _gender : ''
            ),
            onLongPress: () {},
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GenderScreen(user: user,)
                )
              ).then((value) => _downloadData());
            }
          ),
        ],
      )
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
      .document('personal').setData(
        <String, dynamic>{
          'birthday': epochBirthday,
        },
        merge: true
      )
      .catchError((error) {
          print('Error writing document: ' + error.toString());
      }
    );
  }
  
  String _readableTimeString(DateTime dateTime) {
    var month = dateTime.month;
    var day = dateTime.day;
    var year = dateTime.year;
    
    return '${month}/${day}/${year}';
  }
}