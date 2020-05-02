import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Tools
import 'package:lise/user_profile/search/gender_search_screen.dart';


// Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lise/user_profile/search/race_search_screen.dart';


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
    //TODO _checkCurrentUser();
  }
  
  
  Future<void> _downloadData() async{
    
    // Downloading data and synchronizing it with public variables
    await Firestore.instance
      .collection('users')
      .document(user.uid)
      .collection('data')
      .document('search')
      .get()
      .then((doc) {
        if (!doc.exists) {
          print('No data document!');
        } else {
          _ageRange = RangeValues(doc.data['age_min'].toDouble(), doc.data['age_max'].toDouble());
          _distance = doc.data['max_distance'].toDouble();
        }
      });
    
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Search Settings'),
        elevation: 4.0,
      ),
      body: ListView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Divider(
            color: Colors.transparent
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.genderless,
              color: black,
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
              'Races',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RaceSearchScreen(user: user,)
                )
              ).then((value) => _downloadData());
            }
          ),
          Divider(
            color: Colors.grey
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.calendarAlt,
              color: black,
            ),
            title: Text(
              'Age Range',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: Text(
              (_ageRange.end.round() != 50)
              ? ('${_ageRange.start.round()} - ${_ageRange.end.round()}')
              : ('${_ageRange.start.round()} - ${_ageRange.end.round()}+'),
              textAlign: TextAlign.end,
              style: _biggerFont,
            ),
          ),
          RangeSlider(
            labels: (_ageRange.end.round() != 50)
              ? RangeLabels('${_ageRange.start.round()}','${_ageRange.end.round()}')
              : RangeLabels('${_ageRange.start.round()}','${_ageRange.end.round()}+'),
            divisions: 32,
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
            }
          ),
          Divider(
            color: Colors.grey
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.streetView,
              color: black,
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
            divisions: 30,
            min: 10,
            max: 40,
            onChangeEnd: (value) async {
              await _saveDistance();
            },
            onChanged: (value) {
              setState(() {
                _distance = value.round().toDouble();
              });
            }
          ),
          Divider(
            color: Colors.grey
          ),
          
        ],
      )
    );
  }
  
  
  Future<void> _saveAge() async {
    await Firestore.instance
      .collection('users')
      .document(user.uid)
      .collection('data')
      .document('search').setData(
        <String, dynamic>{
          'age_min': _ageRange.start.round(),
          'age_max': _ageRange.end.round(),
        },
        merge: true
      )
      .catchError((error) {
          print('Error writing document: ' + error.toString());
      }
    );
  }
  
  
  
  Future<void> _saveDistance() async {
    await Firestore.instance
      .collection('users')
      .document(user.uid)
      .collection('data')
      .document('search').setData(
        <String, dynamic>{
          'max_distance': _distance,
          'distance_unit' : 'mile',
        },
        merge: true
      )
      .catchError((error) {
          print('Error writing document: ' + error.toString());
      }
    );
  }

}