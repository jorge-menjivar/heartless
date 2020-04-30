import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:lise/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Server
import 'package:http/http.dart' as http;

// Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class UsernameScreen extends StatefulWidget {
  final FirebaseUser user;

  UsernameScreen(this.user);
  @override
  UsernameScreenState createState() => UsernameScreenState(user: user);
}

class UsernameScreenState extends State<UsernameScreen> {
  final FirebaseUser user;
  final secureStorage = new FlutterSecureStorage();


  UsernameScreenState({this.user});

  bool _available = true;
  bool _firstTry = true;
  int _counter = 0;

  final TextEditingController _controllerPassword = new TextEditingController();
  final TextEditingController _controllerUsername = new TextEditingController();
  final _formFieldKey = GlobalKey<FormFieldState>();

  final _passwordFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
        child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Create Username"),
          elevation: 4.0,
        ),
        body: new Builder(
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: new BoxDecoration(color: Colors.amber),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new TextFormField(
                    key: _formFieldKey,
                    controller: _controllerUsername,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    autofocus: true,
                    autovalidate: true,
                    decoration: new InputDecoration(
                      labelText: "What will be your username?",
                      hintText: "Friends will find you with this",
                      ),
                    validator: (username) {
                      if (_firstTry == false && username.length < 4 || username.length > 20)
                        return 'Usernames are lower case. 4 to 20 characters long.';
                      if (username.contains(new RegExp(r'\W')))
                        return 'Only letter, digits, and _';
                      if (_available == false){
                        _counter++; //For first run on Validate() call
                        if (_counter > 1){
                          _counter = 0;
                          _available = true; //For second(last) run on Validate() call
                        }
                        return 'Username is unavailable';
                      }
                    },
                    
                  ),

                  new TextFormField(
                    key: _passwordFieldKey,
                    controller: _controllerPassword,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    autofocus: true,
                    autovalidate: true,
                    decoration: new InputDecoration(
                      labelText: "Password",
                      hintText: "Password",
                    ),
                    validator: (password) {
                      if (_firstTry == false && password.length < 8 || password.length > 100)
                        return 'Check length';
                      else if (password.contains(new RegExp(r'^[a-z]')))
                        return 'At least one lowercase letter';
                      else if (password.contains(new RegExp(r'^[A-Z]')))
                        return 'At least one uppercase letter';
                      else if (password.contains(new RegExp(r'[^D]')))
                        return 'At least one number';
                      else {
                        return null;
                      }
                    },
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      
                    ],
                  ),
                  new SizedBox(
                    height: 32.0,
                  ),
                  new RaisedButton(
                      child: new Text("CONTINUE TO LISA"), onPressed: (){
                        _firstTry = false;
                        if (_formFieldKey.currentState.validate() == true){
                          Scaffold
                          .of(context)
                          .showSnackBar(
                            SnackBar(
                              content: Text('Processing Data'),
                              duration: new Duration(seconds: 4)));
                          _tryRegistration();
                        }
                      }
                  )
                ],
              )
            );
          },
        )
      )
    );
  } 

  //Sending registration post to server. If username is taken then display error. Otherwise continue.
  void _tryRegistration() async{
    final username = _controllerUsername.text.toString().toLowerCase();
    try {
      var client = new http.Client();
      var token = await user.getIdToken();
      await client.post(
        "https://us-central1-raven-bd517.cloudfunctions.net/usernameFunctions/" +  username,
        headers: {HttpHeaders.AUTHORIZATION: token.toString()})
        .then((response) async{
          final responseJson = json.decode(response.body);
          print(responseJson);
          if (response.statusCode == 402){
              // _available is bool that gets set to false to throw error. Gets set back to true when another letter is inputted.
              // For benefit of doubt that username is unavailable and to not make it confusing for user.
              _available = false;
              _formFieldKey.currentState.validate();
          }
          else if (response.statusCode == 420) {
            //TODO when username is accepted and user info is in database.
            await secureStorage.write(key: 'username', value: username);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InitPage(user: user, username: username)));
          }
          else if (response.statusCode == 500){
            //TODO use firebase to collect error data.
            print('SERVER ERROR');
          }
        })
      .whenComplete(client.close);
    }
    catch(e){
      print('CONNECTION ERROR');
      print(e);
    }
  }
}