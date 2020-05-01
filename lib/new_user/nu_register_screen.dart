import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lise/new_user/nu_information_screen.dart';
import 'nu_verification_screen.dart';
import 'package:lise/main.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterScreen extends StatefulWidget {

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final secureStorage = FlutterSecureStorage();
  
  FirebaseUser user;
  
  bool notMatched = false;
  
  bool _firstTry = true;
  
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();
  final _emailFieldKey = GlobalKey<FormFieldState>();
  final _passwordFieldKey = GlobalKey<FormFieldState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState>();
  
  String error = '';
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
        child: Scaffold(
        appBar: AppBar(
          title: Text('Register'),
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
                      } 
                      else if (_firstTry == false && (!email.contains(RegExp(r'[@]')) || !email.contains(RegExp(r'[.]')))) {
                        return 'Email not valid';
                      } 
                      else {
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
                  TextFormField(
                    key: _confirmPasswordFieldKey,
                    controller: _controllerConfirmPassword,
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
                  Container (
                    padding: EdgeInsets.all(10),
                    child: Flexible(
                        child: 
                          Center(
                            child: Text(
                              (notMatched) ? error: '',
                              textAlign: TextAlign.center,
                            )
                      ),
                    ),
                  ),
                  RaisedButton(
                      child: Text('Register'),
                      onPressed: () {
                          _firstTry = false;
                          _handleRegistration(_controllerEmail.text.toString(), _controllerPassword.text.toString(), _controllerConfirmPassword.text.toString());
                        }
                  )
                ],
              )
            )
      )
    );
  }

  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose(); 
  }

  Future<FirebaseUser> _handleRegistration(String email, String password, String confirmPassword) async {
    if (password == confirmPassword) {
      try {
        
        // TODO firebase function to automatically set bool profileCompleted = false in the firestore
        var register = _auth.createUserWithEmailAndPassword(email: email, password: password);
        
        var registrationResult = await register;
        final user = (registrationResult).user;
        
        await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerifyScreen(user: user, newUser: true,)));
      }
      catch (e) {
        notMatched = true;
        error = e.toString();
        setState(() {});
      }
    }
    else {
      notMatched = true;
      error = 'Passwords does not match confirmation';
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
    DocumentSnapshot ds = await Firestore.instance.collection('users').document(id).get();
    var dbToken = await ds['t'];
    if (dbToken is String) {
      if (token == dbToken){ //Token matches database. Token is up to date.
        print("TOKEN IS UP TO DATE");
      }
      else {
        print("TOKEN IS NOT UP TO DATE");
        updateToken(id, token);
      }
    }
    else {
      print("TOKEN IS NOT A STRING");
    }
  }

  void updateToken(var id, var token) async {
    print("UPDATING TOKEN...");
    try {
      Firestore.instance.collection('users').document(id)
      .updateData({'t': token});  
      print("UPDATING TOKEN: SUCCESS");
    } catch (e) {
      print(e.toString());
      print("UPDATING TOKEN: FAILURE");
    }
  }
}