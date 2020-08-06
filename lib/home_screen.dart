import 'dart:async';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/app_variables.dart';
import 'package:lise/bloc/p_matches_bloc.dart';
import 'package:lise/bloc/profile_bloc.dart';
import 'package:lise/pages/matches_page.dart';
import 'package:lise/pages/potential_matches_page.dart';
import 'package:lise/pages/profile_page.dart';
import 'package:lise/splash_screen.dart';
import 'package:lise/utils/database.dart';
import 'package:sqflite/sqflite.dart';
import 'bloc/conversation_bloc.dart';
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

  var _matchesList = [];
  var _pMatchesList = [];

  Map<String, StreamSubscription<QuerySnapshot>> _matchListener = {};
  Map<String, StreamSubscription<QuerySnapshot>> _pMatchListener = {};

  int _currentIndex = 0;
  PageController _pageController;

  var appVariables = AppVariables();

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // Creating the profile bloc and initializing it
    // ignore: close_sinks
    BlocProvider.of<ProfileBloc>(context)..add(GetProfile(alias: user.uid));

    startMatchesDatabase();
  }

  Future<void> startMatchesDatabase() async {
    _db = await getMessagesDb();
    getAlias();
    initPMatchesBloc();
    initMatchesBloc();
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
    Firestore.instance
        .collection('users')
        .document('${user.uid}')
        .collection('data_generated')
        .document('user_rooms')
        .collection('p_matches')
        .snapshots()
        .listen(
      (querySnapshot) async {
        var changes = querySnapshot.documentChanges;
        _pMatchesList = querySnapshot.documents;

        for (var change in changes) {
          var match = change.document;
          var matchRoom = match['room'];

          if (change.type == DocumentChangeType.added) {
            _pMatchListener[matchRoom] = await initListener(matchRoom);
            appVariables.convoOpen[matchRoom] = false;
          } else if (change.type == DocumentChangeType.removed) {
            _pMatchListener[matchRoom].cancel();
          }
        }
        // Adding the potential matches bloc
        BlocProvider.of<PMatchesBloc>(context)
          ..add(GetPMatches(
            db: _db,
            pMatchesDocs: _pMatchesList,
          ));
      },
    );
  }

  Future<void> initMatchesBloc() async {
    Firestore.instance
        .collection('users')
        .document('${user.uid}')
        .collection('data_generated')
        .document('user_rooms')
        .collection('matches')
        .snapshots()
        .listen(
      (querySnapshot) async {
        var changes = querySnapshot.documentChanges;
        _matchesList = querySnapshot.documents;

        for (var change in changes) {
          var match = change.document;
          var matchRoom = match['room'];

          if (change.type == DocumentChangeType.added) {
            _matchListener[matchRoom] = await initListener(matchRoom);
            appVariables.convoOpen[matchRoom] = false;
          } else if (change.type == DocumentChangeType.removed) {
            _matchListener[matchRoom].cancel();
          }
        }

        // Adding the matches bloc
        // ignore: close_sinks
        BlocProvider.of<MatchesBloc>(context)
          ..add(GetMatches(
            db: _db,
            matchesDocs: _matchesList,
          ));
      },
    );
  }

  Future<StreamSubscription<QuerySnapshot>> initListener(String room) async {
    var sqlRoom = '`' + room + '`';

    // Making sure table is created if does not exist;
    await checkMessageTable(_db, room);

    var messagesList = await _db.rawQuery('SELECT * FROM $sqlRoom ORDER BY ${Message.db_sTime} DESC');

    StreamSubscription<QuerySnapshot> listener;
    if (messagesList.isNotEmpty) {
      // Start a stream that listens for new messages
      listener = await listenerFunction(room);
    } else {
      // Pull any messages from the cloud
      await Firestore.instance
          .collection('messages')
          .document('rooms')
          .collection(room)
          .getDocuments()
          .then((snapshot) async {
        for (var doc in snapshot.documents) {
          if (doc.documentID != 'settings') {
            var values = {
              'message': doc['message'],
              'sTime': doc['time'],
              'birth': doc['from'],
              'image': (doc['image']) ? 1 : 0,
            };

            // Inserting the values into the table room
            await _db.insert(sqlRoom, values);
          }
        }
      });

      listener = await listenerFunction(room);
    }
    return listener;
  }

  Future<StreamSubscription<QuerySnapshot>> listenerFunction(String room) async {
    var sqlRoom = '`' + room + '`';

    var messagesList = await _db.rawQuery('SELECT * FROM $sqlRoom ORDER BY ${Message.db_sTime} DESC');

    var lastMessage;
    var lastMessageTime;
    if (messagesList.isNotEmpty) {
      lastMessage = messagesList[0];
      lastMessageTime = lastMessage['sTime'];
    } else {
      lastMessageTime = '0';
    }

    StreamSubscription<QuerySnapshot> listener;

    listener = Firestore.instance
        .collection('messages')
        .document('rooms')
        .collection(room)
        .where('time', isGreaterThan: int.tryParse(lastMessageTime))
        .orderBy('time', descending: false)
        .snapshots()
        .listen((event) async {
      var changes = event.documentChanges;
      for (var change in changes) {
        var doc = change.document;
        if (doc.documentID != 'settings') {
          var values = {
            'message': doc['message'],
            'sTime': doc['time'],
            'birth': doc['from'],
            'image': (doc['image']) ? 1 : 0,
          };

          // Inserting the values into the table room
          await _db.insert(sqlRoom, values);

          BlocProvider.of<MatchesBloc>(context)
            ..add(
              MatchUpdateLastMessage(
                db: _db,
                matchesList: _matchesList,
              ),
            );

          BlocProvider.of<PMatchesBloc>(context)
            ..add(PMatchUpdateLastMessage(
              db: _db,
              pMatchesList: _pMatchesList,
            ));
        }
      }

      // If this conversation is currently being displayed in UI
      if (appVariables.convoOpen[room] == true)
        // Adding the conversation event
        BlocProvider.of<ConversationBloc>(context)
          ..add(GetConversation(
            db: _db,
            room: room,
            limit: appVariables.convoRowCount,
          ));
    });
    return listener;
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.heartBroken,
                color: Colors.pink,
              ),
              Text(' Heartless')
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: <Widget>[
              ///------------------------------------ POTENTIAL MATCHES ------------------------------------------------
              MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: BlocProvider.of<ConversationBloc>(context)),
                  BlocProvider.value(value: BlocProvider.of<PMatchesBloc>(context)),
                ],
                child: PotentialMatchesScreen(
                  db: _db,
                  scaffoldKey: _scaffoldKey,
                  user: this.user,
                  alias: _alias,
                  appVariables: this.appVariables,
                ),
              ),

              ///------------------------------------------- MATCHES ---------------------------------------------------
              MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: BlocProvider.of<ConversationBloc>(context)),
                  BlocProvider.value(value: BlocProvider.of<MatchesBloc>(context)),
                ],
                child: MatchesScreen(
                  db: _db,
                  scaffoldKey: _scaffoldKey,
                  user: this.user,
                  alias: _alias,
                  appVariables: this.appVariables,
                ),
              ),

              ///------------------------------------------- PROFILE ---------------------------------------------------
              BlocProvider.value(
                value: BlocProvider.of<ProfileBloc>(context),
                child: ProfileScreen(
                  user: this.user,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: TabBar(
            indicatorColor: Colors.transparent,
            labelColor: Colors.blueGrey[800],
            unselectedLabelColor: Colors.blueGrey[100],
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
