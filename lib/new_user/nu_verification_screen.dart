import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lise/main.dart';

class VerifyScreen extends StatefulWidget {
  final FirebaseUser user;
  final String email, password;

  VerifyScreen({this.user, this.email, this.password});

  @override
  VerifyScreenState createState() => new VerifyScreenState(user: this.user, email: this.email, password: this.password);
}

class VerifyScreenState extends State<VerifyScreen> {
  String email, password;
  FirebaseUser user;

  VerifyScreenState({this.user, this.email, this.password});

  final FirebaseAuth _auth = FirebaseAuth.instance;


  bool _notVerified = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    String email = user.email;
    // wait 5 secs and _sendVerification();
    _sendVerification();
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("LISA"),
        elevation: 4.0,
      ),
      body: Container (
        padding: const EdgeInsets.all(16.0),
        decoration: new BoxDecoration(color: Colors.white),
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "A VERIFICATION EMAIL WAS SENT TO $email",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 32.0,
            ),
            Text(
              (_notVerified)
              ? "Account not verified"
              : " ",
              style: TextStyle(
                color: Colors.red
              ),
            ),
            RaisedButton(
              child: new Text("CONTINUE TO LISA"), 
              onPressed: () async {
                user = await _auth.currentUser();
                await user.reload();
                if (user.isEmailVerified) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoadingPage()));
                }
                else {
                  setState(() {
                    _notVerified = true;
                  });
                }
              }
            ),
            SizedBox(
              height: 32.0,
            ),
            MaterialButton(
              child: Text(
                "RESEND VERIFICATION LINK",
                style: TextStyle(
                  fontSize: 14
                ),
              ),
              onPressed: () async {
                final snackBar = SnackBar(
                  content: Text(
                    'Sending new verification email',
                  ),
                  duration: Duration(
                    seconds: 2
                  ),
                );
                _scaffoldKey.currentState.showSnackBar(snackBar);
                _sendVerification();
              }
            ),
          ],
        ),
      )
    );
  }

  /// Send Email Verification to the email on file for this user account.
  Future<FirebaseUser> _sendVerification() async {
    try {
      await user.sendEmailVerification();
      print("Verification email sent");
      final snackBar = SnackBar(
        content: Text(
          'Email sent',
        ),
        duration: Duration(
          seconds: 4
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
    catch (e) {
      print (e.toString());
      final snackBar = SnackBar(
        content: Text(
          'Wait a few seconds and try again',
        ),
        duration: Duration(
          seconds: 4
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
    
    return user;
  }
}