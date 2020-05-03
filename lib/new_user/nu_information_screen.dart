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
final _listTitleStyle = const TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold
);
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
  
  @override
  void initState() {
    super.initState();
    _downloadData();
    _scrollController = ScrollController();
    //TODO _checkCurrentUser();
  }
  
  
  Future<void> _downloadData() async{
    
    String myGender;
    String race;
    
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
          myGender = doc.data['gender'];
          race = doc.data['race'];
        }
      });
    
    
    // Setting gender in readable format
    if (myGender == 'female') {
      _userGender = 'Female';
    }
    else if (myGender == 'male') {
      _userGender = 'Male';
    }
    else if (myGender == 'trans_female') {
      _userGender = 'Trans Female';
    }
    else if (myGender == 'trans_male') {
      _userGender = 'Trans Male';
    }
    else if (myGender == 'other') {
      _userGender = 'Other';
    }
    
    
     // Setting race in readable format
    if (race == 'asian') {
      _race = 'Asian';
    }
    else if (race == 'black') {
      _race = 'Black';
    }
    else if (race == 'latinx') {
      _race = 'Latinx';
    }
    else if (race == 'white') {
      _race = 'White';
    }
    else if (race == 'other') {
      _race = 'Other';
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
            title: TextFormField(
              key: _formFieldKey,
              controller: _controllerDisplayName,
              onFieldSubmitted: (value) async {
                await _saveName(value);
              },
              keyboardType: TextInputType.text,
              autocorrect: false,
              autofocus: true,
              autovalidate: true,
              decoration: InputDecoration(
                hintText: 'What is your first name?',
                ),
              validator: (username) {
                if (username.contains(RegExp(r'\W'))) {
                  return 'Only letter, digits, and _';
                }
              },
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
              (_userGender != null) ? _userGender : ''
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
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GenderSearchScreen(user: user,)
                )
              ).then((value) => _downloadData());
            }
          ),
          Divider(
            color: Colors.transparent
          ),
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
            subtitle: Text(
              (_race != null) ? _race : ''
            ),
            onLongPress: () {},
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RaceScreen(user: user,)
                )
              ).then((value) => _downloadData());
            }
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        color: black,
        child: ListTile(
          trailing: Container(
              child: IconButton(
                iconSize: 45,
                icon: Text(
                  'NEXT',
                  style: TextStyle(
                    color: white,
                    fontSize: 14.0,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  )
                ),
                onPressed: () async {
                  if (_name != null && _birthday != null && _userGender != null && _race != null) {
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadPicturesScreen(user: user,)
                      )
                    );
                  }
                  else {
                    print ('not complete');
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
  
  Future<void> _saveName(String name) async {
    if (_formFieldKey.currentState.validate() == true){
      await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('data')
        .document('personal').setData(
          <String, dynamic>{
            'name': name,
          },
          merge: true
        )
        .catchError((error) {
            print('Error writing document: ' + error.toString());
            print(user.uid);
            print(user.isEmailVerified);
        }
      );
    }
  }
}