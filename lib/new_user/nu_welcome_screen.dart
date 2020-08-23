import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'nu_register_screen.dart';
import 'nu_sign_in_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.heartBroken,
              color: Colors.redAccent[400],
              size: 25,
            ),
            Text(
              ' Heartless',
              style: TextStyle(fontSize: 25),
            )
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome!',
                style: TextStyle(fontSize: 25),
              )
            ],
          ),
          SizedBox(
            height: 32.0,
          ),
          RaisedButton(
              child: Text('SIGN IN'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MySignInScreen()));
              }),
          RaisedButton(
              child: Text('Register'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
              })
        ],
      ),
    );
  }
}
