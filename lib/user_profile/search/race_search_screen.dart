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
  
  @override
  @protected
  @mustCallSuper
  void deactivate() async {
    super.deactivate();
    await _save();
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
          _asian = doc.data['race']['asian'];
          _black = doc.data['race']['black'];
          _latinx = doc.data['race']['latinx'];
          _white = doc.data['race']['white'];
          _other = doc.data['race']['other'];
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
        title: Text('Races'),
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
              FontAwesomeIcons.child,
              color: black,
            ),
            title: Text(
              'Asian',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_asian) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _asian = !_asian;
              });
            }
          ),
          Divider(
            color: Colors.grey
          ),
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
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_black) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _black = !_black;
              });
            }
          ),
          Divider(
            color: Colors.grey
          ),
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
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_latinx) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _latinx = !_latinx;
              });
            }
          ),
          Divider(
            color: Colors.grey
          ),
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
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_white) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _white = !_white;
              });
            }
          ),
          Divider(
            color: Colors.grey
          ),
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
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_other) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _other = !_other;
              });
            }
          ),
        ],
      )
    );
  }
  
  Future<void> _save() async {
    await Firestore.instance
      .collection('users')
      .document(user.uid)
      .collection('data')
      .document('search').setData(
        <String, dynamic>{
          'race': {
            'asian': _asian,
            'black': _black,
            'latinx': _latinx,
            'white': _white,
            'other': _other,
          },
        },
        merge: true
      )
      .catchError((error) {
          print('Error writing document: ' + error.toString());
      }
    );
  }
}