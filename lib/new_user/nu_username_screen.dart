import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:lise/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Server
import 'package:http/http.dart' as http;

// Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lise/init_screen.dart';

class UsernameScreen extends StatefulWidget {
  final FirebaseUser user;

  UsernameScreen(this.user);
  @override
  UsernameScreenState createState() => UsernameScreenState(user: user);
}

class UsernameScreenState extends State<UsernameScreen> {
  final FirebaseUser user;
  final secureStorage = FlutterSecureStorage();

  UsernameScreenState({this.user});

  bool _available = true;
  bool _firstTry = true;
  int _counter = 0;

  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  final _formFieldKey = GlobalKey<FormFieldState>();

  final _passwordFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Username'),
          elevation: 4.0,
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: Colors.amber),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    key: _formFieldKey,
                    controller: _controllerUsername,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    autofocus: true,
                    autovalidate: true,
                    decoration: InputDecoration(
                      labelText: 'What will be your username?',
                      hintText: 'Friends will find you with this',
                    ),
                    validator: (username) {
                      if (_firstTry == false && username.length < 4 || username.length > 20) {
                        return 'Usernames are lower case. 4 to 20 characters long.';
                      }
                      if (username.contains(RegExp(r'\W'))) {
                        return 'Only letter, digits, and _';
                      }
                      if (_available == false) {
                        _counter++; //For first run on Validate() call
                        if (_counter > 1) {
                          _counter = 0;
                          _available = true; //For second(last) run on Validate() call
                        }
                        return 'Username is unavailable';
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
                      labelText: 'Password',
                      hintText: 'Password',
                    ),
                    validator: (password) {
                      if (_firstTry == false && password.length < 8 || password.length > 100) {
                        return 'Check length';
                      } else if (password.contains(RegExp(r'^[a-z]'))) {
                        return 'At least one lowercase letter';
                      } else if (password.contains(RegExp(r'^[A-Z]'))) {
                        return 'At least one uppercase letter';
                      } else if (password.contains(RegExp(r'[^D]'))) {
                        return 'At least one number';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[],
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  RaisedButton(
                    child: Text('CONTINUE TO LISA'),
                    onPressed: () {
                      _firstTry = false;
                      if (_formFieldKey.currentState.validate() == true) {
                        Scaffold.of(context)
                            .showSnackBar(SnackBar(content: Text('Processing Data'), duration: Duration(seconds: 4)));
                        _tryRegistration();
                      }
                    },
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  //Sending registration post to server. If username is taken then display error. Otherwise continue.
  void _tryRegistration() async {
    final username = _controllerUsername.text.toString().toLowerCase();
    try {
      var client = http.Client();
      var token = await user.getIdToken();
      await client.post(
        "https://us-central1-raven-bd517.cloudfunctions.net/usernameFunctions/" + username,
        headers: {
          HttpHeaders.authorizationHeader: token.toString(),
        },
      ).then((response) async {
        final responseJson = json.decode(response.body);
        print(responseJson);
        if (response.statusCode == 402) {
          // _available is bool that gets set to false to throw error. Gets set back to true when another letter is inputted.
          // For benefit of doubt that username is unavailable and to not make it confusing for user.
          _available = false;
          _formFieldKey.currentState.validate();
        } else if (response.statusCode == 420) {
          //TODO when username is accepted and user info is in database.
          await secureStorage.write(key: 'username', value: username);
          await Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen(user: user, username: username)));
        } else if (response.statusCode == 500) {
          //TODO use firebase to collect error data.
          print('SERVER ERROR');
        }
      }).whenComplete(client.close);
    } catch (e) {
      print('CONNECTION ERROR');
      print(e);
    }
  }
}
