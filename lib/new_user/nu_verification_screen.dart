import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/main.dart';
import 'package:lise/new_user/nu_information_screen.dart';

class VerifyScreen extends StatefulWidget {
  final FirebaseUser user;
  final bool newUser;

  VerifyScreen({@required this.user, @required this.newUser});

  @override
  VerifyScreenState createState() => VerifyScreenState(user: user, newUser: newUser);
}

class VerifyScreenState extends State<VerifyScreen> {
  FirebaseUser user;
  final bool newUser;

  VerifyScreenState({@required this.user, @required this.newUser});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _notVerified = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _alias;

  @override
  void initState() {
    super.initState();
    _sendVerification();
  }

  @override
  Widget build(BuildContext context) {
    var email = user.email;
    return Scaffold(
        key: _scaffoldKey,
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
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'A VERIFICATION EMAIL WAS SENT TO $email',
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
                (_notVerified) ? 'Account not verified' : ' ',
                style: TextStyle(color: Colors.red),
              ),
              RaisedButton(
                  // TODO automatically check every 5 seconds if verified.
                  child: Text('CONTINUE'),
                  onPressed: () async {
                    user = await _auth.currentUser();
                    await user.reload();
                    var token = await user.getIdToken(refresh: true);
                    user = await _auth.currentUser();
                    _alias = token.claims['alias'];
                    if (user.isEmailVerified) {
                      (!newUser)
                          ? await Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => LoadingPage()))
                          : await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewUserInformationScreen(
                                  user: user,
                                  alias: _alias,
                                ),
                              ),
                            );
                    } else {
                      setState(() {
                        _notVerified = true;
                      });
                    }
                  }),
              SizedBox(
                height: 32.0,
              ),
              MaterialButton(
                  child: Text(
                    'RESEND VERIFICATION LINK',
                    style: TextStyle(fontSize: 14),
                  ),
                  onPressed: () async {
                    final snackBar = SnackBar(
                      content: Text(
                        'Sending new verification email',
                      ),
                      duration: Duration(seconds: 2),
                    );
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                    await _sendVerification();
                  }),
            ],
          ),
        ));
  }

  /// Send Email Verification to the email on file for this user account.
  Future<FirebaseUser> _sendVerification() async {
    try {
      await user.sendEmailVerification();
      print('Verification email sent');
      final snackBar = SnackBar(
        content: Text(
          'Email sent',
        ),
        duration: Duration(seconds: 4),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } catch (e) {
      print(e.toString());
      final snackBar = SnackBar(
        content: Text(
          'Wait a few seconds and try again',
        ),
        duration: Duration(seconds: 4),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }

    return user;
  }
}
