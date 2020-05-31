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



class GenderSearchScreen extends StatefulWidget {
  GenderSearchScreen({@required this.user});
  
  final FirebaseUser user;
  
  @override
  GenderSearchScreenState createState() => GenderSearchScreenState(user: user);
}

class GenderSearchScreenState extends State<GenderSearchScreen> {
  
  GenderSearchScreenState({@required this.user});
  
  final FirebaseUser user;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  
  bool _women = false;
  bool _men = false;
  bool _transWomen = false;
  bool _transMen = false;
  bool _others = false;
  
  
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
          _women = doc.data['gender']['female'];
          _men = doc.data['gender']['male'];
          _transWomen = doc.data['gender']['trans_female'];
          _transMen = doc.data['gender']['trans_male'];
          _others = doc.data['gender']['other'];
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
        title: Text('I am interested in'),
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
              FontAwesomeIcons.venus,
              color: black,
            ),
            title: Text(
              'Women',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_women) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _women = !_women;
              });
            }
          ),
          Divider(
            color: Colors.grey
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.mars,
              color: black,
            ),
            title: Text(
              'Men',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_men) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _men = !_men;
              });
            }
          ),
          Divider(
            color: Colors.grey
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.transgender,
              color: black,
            ),
            title: Text(
              'Trans Women',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_transWomen) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _transWomen = !_transWomen;
              });
            }
          ),
          Divider(
            color: Colors.grey
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.transgender,
              color: black,
            ),
            title: Text(
              'Trans Men',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_transMen) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _transMen = !_transMen;
              });
            }
          ),
          Divider(
            color: Colors.grey
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.genderless,
              color: black,
            ),
            title: Text(
              'Others',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.check,
              color: (_others) ? black : Colors.transparent,
            ),
            onTap: () async{
              setState(() {
                _others = !_others;
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
  
  Future<void> _save() async {
    // If user made a choice, save it to the cloud
    if (_women || _men || _transWomen || _transMen || _others) {
      await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('data')
        .document('search').setData(
          <String, dynamic>{
            'gender': {
              'female': _women,
              'male': _men,
              'trans_female': _transWomen,
              'trans_male': _transMen,
              'other': _others,
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
}