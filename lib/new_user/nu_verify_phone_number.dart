import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frino_icons/frino_icons.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  @override
  VerifyPhoneNumberScreenState createState() => VerifyPhoneNumberScreenState();
}

class VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final secureStorage = FlutterSecureStorage();

  FirebaseUser user;

  bool wrong = false;

  bool _firstTry = true;

  final TextEditingController _controllerPhoneNumber = TextEditingController();
  final _phoneNumberFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verify Phone Number'),
          elevation: 4.0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              key: _phoneNumberFieldKey,
              controller: _controllerPhoneNumber,
              keyboardType: TextInputType.phone,
              autocorrect: false,
              autofocus: true,
              autovalidate: true,
              decoration: InputDecoration(
                icon: Icon(
                  FrinoIcons.f_iphone,
                  color: Colors.pink,
                ),
                hintText: 'Phone Number',
                fillColor: Theme.of(context).splashColor,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white54 : Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white12 : Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white12 : Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
              ),
              validator: (phoneNumber) {
                if (_firstTry == false && phoneNumber.length < 4) {
                  return 'Check length';
                } else if (_firstTry == false && (!phoneNumber.contains(RegExp(r'[0-9]+')))) {
                  return 'Phone Number not valid';
                } else {
                  return null;
                }
              },
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
                child: Text('CONTINUE'),
                onPressed: () {
                  _firstTry = false;
                  _handleSignIn(_controllerPhoneNumber.text.toString());
                })
          ],
        ),
      ),
    );
  }

  Future<FirebaseUser> _handleSignIn(String phoneNumber) async {
    phoneNumber = '+1$phoneNumber';
    try {
      // Verify phone number
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeAutoRetrievalTimeout: (String verificationId) {},
        codeSent: (String verificationId, [int forceResendingToken]) {},
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential phoneAuthCredential) async {
          user = await _auth.currentUser();
          user.linkWithCredential(phoneAuthCredential);
        },
        verificationFailed: (AuthException error) {
          print(error.message);
        },
      );
    } catch (e) {
      print(e.toString());
      wrong = true;
      setState(() {});
    }

    return user;
  }
}
