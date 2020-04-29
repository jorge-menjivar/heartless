import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'nu_sign_in_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final FirebaseUser user;

  WelcomeScreen({this.user});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {

  FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LISA'),
        elevation: 4.0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Welcome to LISA'),
              ],
            ),
            SizedBox(
              height: 32.0,
            ),
            RaisedButton(
              child: Text('SIGN IN'), onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MySignInScreen()));
              }
            )
          ],
        )
      )
    );
  }
}