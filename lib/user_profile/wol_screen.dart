import 'dart:async';
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



class WayOfLivingScreen extends StatefulWidget {
  WayOfLivingScreen({@required this.user});
  
  final FirebaseUser user;
  
  @override
  WayOfLivingScreenState createState() => WayOfLivingScreenState(user: user);
}

class WayOfLivingScreenState extends State<WayOfLivingScreen> {
  
  WayOfLivingScreenState({@required this.user});
  
  final FirebaseUser user;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  
  
  RangeValues _ageRange = RangeValues(18, 30);
  
  double _distance = 20;

  
  
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    //TODO _checkCurrentUser();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My way of living'),
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
              FontAwesomeIcons.solidHeart,
              color: black,
            ),
            title: Text(
              'I like...',
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
              );
            }
          ),
          Divider(
            color: Colors.transparent
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.heartBroken,
              color: black,
            ),
            title: Text(
              'I dislike...',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            onLongPress: () {},
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RaceSearchScreen(user: user,)
                )
              );
            }
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