import 'dart:async';

import 'package:flutter/material.dart';
import 'nu_information_screen.dart';
import 'nu_verification_screen.dart';
import 'package:lise/main.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MySignInScreen extends StatefulWidget {
  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<MySignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final secureStorage = FlutterSecureStorage();

  FirebaseUser user;

  bool wrong = false;

  bool _firstTry = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final _emailFieldKey = GlobalKey<FormFieldState>();
  final _passwordFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
            appBar: AppBar(
              title: Text('SIGN IN'),
              elevation: 4.0,
            ),
            body: Container(
                decoration: BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      key: _emailFieldKey,
                      controller: _controllerEmail,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      autofocus: true,
                      autovalidate: true,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: 'Email',
                      ),
                      validator: (email) {
                        if (_firstTry == false && email.length < 4) {
                          return 'Check length';
                        } else if (_firstTry == false &&
                            (!email.contains(RegExp(r'[@]')) ||
                                !email.contains(RegExp(r'[.]')))) {
                          return 'Email not valid';
                        } else {
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                      key: _passwordFieldKey,
                      controller: _controllerPassword,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      autofocus: true,
                      autovalidate: true,
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: 'Password',
                        hintText: 'Password',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          (wrong) ? 'Information not valid' : '',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        )
                      ],
                    ),
                    RaisedButton(
                        child: Text('CONTINUE TO LISA'),
                        onPressed: () {
                          _firstTry = false;
                          _handleSignIn(_controllerEmail.text.toString(),
                              _controllerPassword.text.toString());
                        })
                  ],
                ))));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<FirebaseUser> _handleSignIn(String e, String p) async {
    try {
      var signInWithEmailAndPassword =
          _auth.signInWithEmailAndPassword(email: e, password: p);

      var authResult = await signInWithEmailAndPassword;
      final user = (authResult).user;

      if (user.isEmailVerified) {
        var profileCompleted = false;
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .collection('data')
            .document('private')
            .get()
            .then((doc) {
          if (!doc.exists) {
            print('No data document!');
          } else {
            profileCompleted = doc.data['profileCompleted'];
          }
        });
        if (profileCompleted) {
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoadingPage()),
              (route) => false);
        } else {
          await Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(
                  builder: (context) => NewUserInformationScreen(
                        user: user,
                      )),
              (route) => false);
        }
      } else {
        await Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(
                builder: (context) => VerifyScreen(
                      user: user,
                      newUser: false,
                    )),
            (route) => false);
      }
    } catch (e) {
      print(e.toString());
      wrong = true;
      setState(() {});
    }

    return user;
  }

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
    DocumentSnapshot ds =
        await Firestore.instance.collection('users').document(id).get();
    var dbToken = await ds['t'];
    if (dbToken is String) {
      if (token == dbToken) {
        //Token matches database. Token is up to date.
        print("TOKEN IS UP TO DATE");
      } else {
        print("TOKEN IS NOT UP TO DATE");
        updateToken(id, token);
      }
    } else {
      print("TOKEN IS NOT A STRING");
    }
  }

  void updateToken(var id, var token) async {
    print("UPDATING TOKEN...");
    try {
      Firestore.instance
          .collection('users')
          .document(id)
          .updateData({'t': token});
      print("UPDATING TOKEN: SUCCESS");
    } catch (e) {
      print(e.toString());
      print("UPDATING TOKEN: FAILURE");
    }
  }
}
