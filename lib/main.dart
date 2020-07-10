import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lise/home_screen.dart';
import 'package:lise/init_screen.dart';
import 'package:lise/localizations.dart';
import 'new_user/nu_information_screen.dart';
import 'new_user/nu_welcome_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

// Storage
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
MaterialColor black = MaterialColor(0xFF1c1c1c, color);
MaterialColor white = MaterialColor(0xFFFFFFFF, color);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Root Widget.
  //TODO add terms and conditions
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
        Locale('es', ''),
        Locale('fr', ''),
      ],
      title: 'LISA',
      theme: ThemeData(
        primarySwatch: black,
        canvasColor: white,
        accentColor: black,
      ),
      home: LoadingPage(),
    );
  }
}

class LoadingPage extends StatefulWidget {
  LoadingPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  final secureStorage = FlutterSecureStorage();

  var _profileCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  void _checkCurrentUser() async {
    await _auth.currentUser().then((u) async {
      user = u;
      (user != null)
          ? await _checkVerification()
          : await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(
                  user: user,
                ),
              ),
            );
    });
  }

  Future<void> _checkVerification() async {
    // Downloading data and synchronizing it with public variables
    if (user.isEmailVerified) {
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('data')
          .document('private')
          .get()
          .then((doc) {
        if (!doc.exists) {
          print('USER SETTINGS DOES NOT EXIST');
        } else {
          _profileCompleted = doc.data['profileCompleted'];
        }
      });

      if (_profileCompleted) {
        await Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen(user: user, username: user.email)));
      } else {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewUserInformationScreen(
              user: user,
            ),
          ),
        );
      }
    } else {
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen(user: user)));
    }
  }

  //--------------------------------------FIREBASE TOKEN---------------------------------------------------
  void _checkToken() async {
    try {
      // Future to get user token
      var token = await user.getIdToken();
      _checkRefreshedToken(token);
    } catch (e) {
      // Handling error
      print(e.toString());
    }
  }

  void _checkRefreshedToken(var token) async {
    var id = user.uid.toString();
    var ds = await Firestore.instance.collection('users').document(id).get();
    var dbToken = ds['t'];
    if (dbToken is String) {
      if (token == dbToken) {
        //Token matches database. Token is up to date.
        print('TOKEN IS UP TO DATE');
      } else {
        print('TOKEN IS NOT UP TO DATE');
        updateToken(id, token);
      }
    } else {
      print('TOKEN IS NOT A STRING');
    }
  }

  void updateToken(var id, var token) async {
    print('UPDATING TOKEN...');
    try {
      await Firestore.instance.collection('users').document(id).updateData({'t': token});
      print('UPDATING TOKEN: SUCCESS');
    } catch (e) {
      print(e.toString());
      print('UPDATING TOKEN: FAILURE');
    }
  }
}
