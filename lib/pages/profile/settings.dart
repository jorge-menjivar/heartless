import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:lise/widgets/switch.dart';

final _biggerFont = const TextStyle(
  fontSize: 18.0,
);

class SettingsScreen extends StatefulWidget {
  SettingsScreen({@required this.user});

  final FirebaseUser user;

  @override
  SettingsScreenState createState() => SettingsScreenState(user: user);
}

class SettingsScreenState extends State<SettingsScreen> {
  SettingsScreenState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  bool enablePIN = false;
  bool enableNotifications = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: (Platform.isIOS)
          ? CupertinoNavigationBar(
              middle: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.normal,
                ),
              ),
            )
          : AppBar(
              title: Text('Settings'),
            ),
      body: ListView(
        shrinkWrap: true,
        primary: false,
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          ListTile(
            leading: Icon(
              FrinoIcons.f_bell,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            title: Text(
              'Enable notifications',
              style: _biggerFont,
            ),
            trailing: settingsSwitch(
              value: enableNotifications,
              onChanged: (newValue) {
                setState(() {
                  enableNotifications = newValue;
                });
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              FrinoIcons.f_at,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            title: Text(
              'My Email',
              style: _biggerFont,
            ),
            subtitle: Text(user.email),
            onTap: () async {
              //TODO
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              FrinoIcons.f_iphone,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            title: Text(
              'Phone Number',
              style: _biggerFont,
            ),
            subtitle: Text((user.phoneNumber != null) ? user.phoneNumber : 'No number listed'),
            onTap: () async {
              //TODO
            },
          ),
        ],
      ),
    );
  }
}
