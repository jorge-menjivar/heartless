import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frino_icons/frino_icons.dart';

final _biggerFont = const TextStyle(
  fontSize: 18.0,
);

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

  Future<void> _downloadData() async {
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
        if (doc.data['searchGender'] != null) {
          _women = doc.data['searchGender']['female'];
          _men = doc.data['searchGender']['male'];
          _transWomen = doc.data['searchGender']['trans_female'];
          _transMen = doc.data['searchGender']['trans_male'];
          _others = doc.data['searchGender']['other'];
        }
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _save,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('I am interested in'),
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
                      FrinoIcons.f_lab,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'Women',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: Icon(
                      FrinoIcons.f_check,
                      color: (_women) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _women = !_women;
                      });
                    }),
                Divider(color: Colors.grey),
                ListTile(
                    leading: Icon(
                      FrinoIcons.f_lab,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'Men',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: Icon(
                      FrinoIcons.f_check,
                      color: (_men) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _men = !_men;
                      });
                    }),
                Divider(color: Colors.grey),
                ListTile(
                    leading: Icon(
                      FrinoIcons.f_lab,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'Trans Women',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: Icon(
                      FrinoIcons.f_check,
                      color: (_transWomen) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _transWomen = !_transWomen;
                      });
                    }),
                Divider(color: Colors.grey),
                ListTile(
                    leading: Icon(
                      FrinoIcons.f_lab,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'Trans Men',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: Icon(
                      FrinoIcons.f_check,
                      color: (_transMen) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _transMen = !_transMen;
                      });
                    }),
                Divider(color: Colors.grey),
                ListTile(
                    leading: Icon(
                      FrinoIcons.f_lab,
                      color: IconTheme.of(context).color,
                      size: IconTheme.of(context).size,
                    ),
                    title: Text(
                      'Others',
                      textAlign: TextAlign.left,
                      style: _biggerFont,
                    ),
                    trailing: Icon(
                      FrinoIcons.f_check,
                      color: (_others) ? Colors.green : Colors.transparent,
                    ),
                    onTap: () async {
                      setState(() {
                        _others = !_others;
                      });
                    }),
                Divider(color: Colors.grey),
              ],
            )));
  }

  Future<bool> _save() async {
    // If user made a choice, save it to the cloud
    if (_women || _men || _transWomen || _transMen || _others) {
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('data')
          .document('userSettings')
          .setData(<String, dynamic>{
        'searchGender': {
          'female': _women,
          'male': _men,
          'trans_female': _transWomen,
          'trans_male': _transMen,
          'other': _others,
        },
      }, merge: true).catchError((error) {
        print('Error writing document: ' + error.toString());
      });
      Navigator.pop(context);
    }
    return false;
  }
}
