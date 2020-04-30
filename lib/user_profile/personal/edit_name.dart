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



class EditNameScreen extends StatefulWidget {
  EditNameScreen({@required this.user});
  
  final FirebaseUser user;
  
  @override
  EditNameScreenState createState() => EditNameScreenState(user: user);
}

class EditNameScreenState extends State<EditNameScreen> {
  
  EditNameScreenState({@required this.user});
  
  final FirebaseUser user;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  
  
  DateTime birthday;
  
  final _formFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _controllerDisplayName = TextEditingController();
  
  Timer searchOnStoppedTyping;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Gender'),
        elevation: 4.0,
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
        shrinkWrap: true,
        primary: false,
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Divider(
            color: Colors.transparent
          ),
          TextFormField(
            key: _formFieldKey,
            controller: _controllerDisplayName,
            onChanged: (value) {
              _onChangeHandler(value);
            },
            onEditingComplete: () {
              _saveName(_controllerDisplayName.text);
            },
            keyboardType: TextInputType.text,
            autocorrect: false,
            autofocus: true,
            autovalidate: true,
            decoration: InputDecoration(
              hintText: 'What is your first name?',
              ),
            validator: (username) {
              if (username.contains(new RegExp(r'\W'))) {
                return 'Only letter, digits, and _';
              }
            },
          ),
        ],
      )
    );
  }
  
  Future<void> _onChangeHandler(value) async{
    const duration = Duration(milliseconds:1500); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
        setState(() => searchOnStoppedTyping.cancel()); // clear timer
    }
    setState(() => searchOnStoppedTyping = Timer(duration, () => _saveName(value)));
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
        }
      );
    }
  }
    
}