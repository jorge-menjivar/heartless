import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Tools
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_package;
import 'package:lise/user_profile/personal/gender_screen.dart';
import 'package:lise/user_profile/search/gender_search_screen.dart';


// Storage
import 'package:path_provider/path_provider.dart';
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
  
  
  String _gender;
  
  RangeValues _ageRange = RangeValues(18, 30);
  
  double _distance = 4/0.62;
  
  Key _sliderKey;
  
  
  
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
      .document('search')
      .get()
      .then((doc) {
        if (!doc.exists) {
          print('No data document!');
        } else {
          gender = doc.data['gender'];
        }
      });
    
    
    // Setting gender in readable format
    if (gender == 'female') {
      _gender = 'Women';
    }
    else if (gender == 'male') {
      _gender = 'Men';
    }
    else if (gender == 'trans_female') {
      _gender = 'Trans Women';
    }
    else if (gender == 'trans_male') {
      _gender = 'Trans Men';
    }
    else if (gender == 'other') {
      _gender = 'Others';
    }
    
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
              FontAwesomeIcons.smile,
              color: black,
            ),
            title: Text(
              'I am interested in',
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
                  builder: (context) => GenderSearchScreen(user: user,)
                )
              ).then((value) => _downloadData());
            }
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.calendar,
              color: black,
            ),
            title: Text(
              'Age Range',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: Text(
              '${_ageRange.start.floor()} - ${_ageRange.end.floor()}',
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
          RangeSlider(
            labels: RangeLabels('${_ageRange.start.floor()}','${_ageRange.end.floor()}'),
            min: 18,
            max: 55,
            values: _ageRange,
            onChanged: (value) => {
              setState(() {
                _ageRange = RangeValues(value.start.floor().toDouble(), value.end.floor().toDouble());
              })
            }
          ),
          
        ],
      )
    );
  }

}