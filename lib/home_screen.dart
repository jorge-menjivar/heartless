import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/messages/m_matches_screen.dart';
import 'package:lise/screens/matches.dart';
import 'package:lise/screens/potential_matches.dart';
import 'package:lise/screens/profile.dart';
import 'package:lise/user_profile/personal_information_screen.dart';
import 'package:lise/user_profile/profile_pictures_screen.dart';
import 'package:lise/user_profile/search_information_screen.dart';
import 'package:lise/user_profile/wol_screen.dart';
import 'package:location/location.dart';
import 'localizations.dart';
import 'main.dart';
import 'messages/m_p_matches_screen.dart';
import 'convo_completion/select_matches_screen.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

// Tools
import 'package:flutter/cupertino.dart';

Map<int, Color> color = {
  50: Color.fromRGBO(0, 0, 0, .1),
  100: Color.fromRGBO(0, 0, 0, .2),
  200: Color.fromRGBO(0, 0, 0, .3),
  300: Color.fromRGBO(0, 0, 0, .4),
  400: Color.fromRGBO(0, 0, 0, .5),
  500: Color.fromRGBO(0, 0, 0, .6),
  600: Color.fromRGBO(0, 0, 0, .7),
  700: Color.fromRGBO(0, 0, 0, .8),
  800: Color.fromRGBO(0, 0, 0, .9),
  900: Color.fromRGBO(0, 0, 0, 1),
};
MaterialColor black = MaterialColor(0xFF000000, color);
MaterialColor white = MaterialColor(0xFFFFFFFF, color);

bool isNew = false;

class HomeScreen extends StatefulWidget {
  HomeScreen({@required this.user, this.username});

  final FirebaseUser user;
  final String username;

  @override
  HomeScreenState createState() => HomeScreenState(user: user, username: username);
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  HomeScreenState({this.user, this.username});

  FirebaseUser user;
  final String username;

  final secureStorage = FlutterSecureStorage();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverSafeArea(
                  bottom: false,
                  top: false,
                  sliver: SliverAppBar(
                    primary: true,
                    centerTitle: true,
                    title: ListTile(
                      title: Text(
                        'LISA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context).translate('app_moto'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    expandedHeight: 100.0,
                    floating: true,
                    pinned: true,
                    snap: false,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Container(
                        decoration: BoxDecoration(color: white),
                      ),
                    ),
                    bottom: TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(
                          icon: FaIcon(
                            FontAwesomeIcons.search,
                          ),
                        ),
                        Tab(
                          icon: FaIcon(
                            FontAwesomeIcons.solidCommentDots,
                          ),
                        ),
                        Tab(
                          icon: FaIcon(
                            FontAwesomeIcons.userAlt,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ];
          },
          body: TabBarView(
            children: [
              ///------------------------------------ POTENTIAL MATCHES ------------------------------------------------
              PotentialMatchesScreen(
                scaffoldKey: _scaffoldKey,
                user: this.user,
              ),

              ///------------------------------------------- MATCHES ---------------------------------------------------
              MatchesScreen(
                scaffoldKey: _scaffoldKey,
                user: this.user,
              ),

              ///------------------------------------------- PROFILE ---------------------------------------------------
              ProfileScreen(
                user: this.user,
              )
            ],
          ),
        ),
      ),
    );
  }

  /**
  Future<void> _checkCurrentUser() async {
    await _auth.currentUser().then((u) async{
      user = u;
      if (user == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
      }
      
      else {
        String token = await common.checkToken(user);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(firebaseUser: user, token: token)));
      }
    });
  }
  */
}
