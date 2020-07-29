import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/bloc/p_matches_bloc.dart';
import 'package:lise/bloc/profile_bloc.dart';
import 'package:lise/pages/matches_page.dart';
import 'package:lise/pages/potential_matches_page.dart';
import 'package:lise/pages/profile_page.dart';
import 'package:lise/splash_screen.dart';
import 'package:lise/utils/database.dart';
import 'package:sqflite/sqflite.dart';
import 'bloc/matches_bloc.dart';
import 'localizations.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
// Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  String _alias;

  final secureStorage = FlutterSecureStorage();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List pMatchesList = [];

  bool loadedProfile = false;
  bool loadedMatches = false;
  bool loadedPMatches = false;

  Database _db;

  @override
  void initState() {
    super.initState();

    // Creating the blocs and initializing them
    // ignore: close_sinks
    BlocProvider.of<ProfileBloc>(context)..add(GetProfile(alias: user.uid));

    startMatchesDatabase();

    getAlias();
    initPMatchesBloc();
    initMatchesBloc();
  }

  Future<void> startMatchesDatabase() async {
    _db = await getMessagesDb();
  }

  Future<void> getAlias() async {
    Firestore.instance
        .collection('users')
        .document('${user.uid}')
        .collection('data')
        .document('private')
        .get()
        .then((doc) {
      if (!doc.exists) {
        print('No data document!');
      } else {
        _alias = doc.data['alias'];
      }
    });
  }

  Future<void> initPMatchesBloc() async {
    var docs;
    Firestore.instance
        .collection('users')
        .document('${user.uid}')
        .collection('data_generated')
        .document('user_rooms')
        .collection('p_matches')
        .snapshots()
        .listen(
      (querySnapshot) {
        docs = querySnapshot.documents;
        // Adding the potential matches bloc
        // ignore: close_sinks
        BlocProvider.of<PMatchesBloc>(context)..add(GetPMatches(pMatchesDocs: docs));
      },
    );
  }

  Future<void> initMatchesBloc() async {
    var docs;
    Firestore.instance
        .collection('users')
        .document('${user.uid}')
        .collection('data_generated')
        .document('user_rooms')
        .collection('matches')
        .snapshots()
        .listen(
      (querySnapshot) {
        docs = querySnapshot.documents;
        // Adding the potential matches bloc
        // ignore: close_sinks
        BlocProvider.of<MatchesBloc>(context)..add(GetMatches(matchesDocs: docs));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loadedPMatches || !loadedMatches || !loadedProfile) {
      return BlocListener<PMatchesBloc, PMatchesState>(
        listener: (context, state) {
          if (state is PMatchesLoaded) {
            pMatchesList = state.pMatches.list;
            setState(() {
              loadedPMatches = true;
            });
            return;
          }
        },
        child: BlocListener<MatchesBloc, MatchesState>(
          listener: (context, state) {
            if (state is MatchesLoaded) {
              final list = state.matches.list;
              for (var match in list) {
                final profilePicture = NetworkImage(match['imageLink']);
                precacheImage(profilePicture, context);
              }
              setState(() {
                loadedMatches = true;
              });
              return;
            }
          },
          child: BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded) {
                final profilePicture = NetworkImage(state.profile.profilePictureURL);
                precacheImage(profilePicture, context);
                setState(() {
                  loadedProfile = true;
                });
                return;
              }
            },
            child: SplashScreen(),
          ),
        ),
      );
    }
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
              BlocProvider.value(
                value: BlocProvider.of<PMatchesBloc>(context),
                child: PotentialMatchesScreen(
                  scaffoldKey: _scaffoldKey,
                  user: this.user,
                  alias: _alias,
                ),
              ),

              ///------------------------------------------- MATCHES ---------------------------------------------------
              BlocProvider.value(
                value: BlocProvider.of<MatchesBloc>(context),
                child: MatchesScreen(
                  scaffoldKey: _scaffoldKey,
                  user: this.user,
                  alias: _alias,
                  db: _db,
                ),
              ),

              ///------------------------------------------- PROFILE ---------------------------------------------------
              BlocProvider.value(
                value: BlocProvider.of<ProfileBloc>(context),
                child: ProfileScreen(
                  user: this.user,
                ),
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
