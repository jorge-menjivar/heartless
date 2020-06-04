import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/messages/m_matches_screen.dart';
import 'package:lise/user_profile/personal_information_screen.dart';
import 'package:lise/user_profile/profile_pictures_screen.dart';
import 'package:lise/user_profile/search_information_screen.dart';
import 'package:lise/user_profile/wol_screen.dart';
import 'package:location/location.dart';
import 'package:pedantic/pedantic.dart';
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

final _biggerFont = const TextStyle(
  fontSize: 18.0,
  color: Colors.black,
);
final _subFont = const TextStyle(
  color: Colors.black,
);
final _trailFont = const TextStyle(
  color: Colors.black,
);
final _listTitleStyle =
    const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
var _iconColor = black;

Color _pictureCardColor = Colors.white;

bool isNew = false;

class InitPage extends StatefulWidget {
  InitPage({@required this.user, this.username});

  final FirebaseUser user;
  final String username;

  @override
  InitPageState createState() => InitPageState(user: user, username: username);
}

class InitPageState extends State<InitPage> with WidgetsBindingObserver {
  InitPageState({this.user, this.username});

  FirebaseUser user;
  final String username;

  final secureStorage = FlutterSecureStorage();

  ScrollController _scrollController;
  final double _profilePicSize = 280;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _profilePicImageLink1 = 'http://loading';

  StorageReference _storageReference1;

  var _matches = [];
  var _pMatches = [];

  var matchesInitialized = false;
  var pMatchesInitialized = false;
  final _matchImageLinks = [];
  final _matchLastMessages = [];
  final _pMatchLastMessages = [];

  @override
  void initState() {
    super.initState();
    _downloadData();
    _loadProfilePictures();
    _scrollController = ScrollController();
    //TODO _checkCurrentUser();
  }

  void _loadProfilePictures() async {
    try {
      _storageReference1 = FirebaseStorage()
          .ref()
          .child('users/${user.uid}/profile_pictures/pic1.jpg');
    } catch (e) {
      print(e);
    }

    _profilePicImageLink1 = await _storageReference1.getDownloadURL();

    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
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
                            'A new way to meet people',
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
                            )),
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
              body: TabBarView(children: [
                ///------------------------------------ POTENTIAL MATCHES -----------------------------------------
                _buildPMatchesTiles(),

                ///------------------------------------------- MATCHES ---------------------------------------------
                _buildMatchedConvos(),

                ///------------------------------------------- PROFILE ---------------------------------------------------------
                ListView(
                  padding: const EdgeInsets.all(1),
                  children: <Widget>[
                    ListTile(
                      leading: Text(
                        'PROFILE',
                        textAlign: TextAlign.left,
                        style: _listTitleStyle,
                      ),
                    ),
                    SizedBox(
                        height: _profilePicSize + 40,
                        child: ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment(0, 0.9),
                                end: Alignment.bottomCenter,
                                colors: [Colors.white, Colors.transparent],
                              ).createShader(
                                  Rect.fromLTRB(0, 0, rect.width, rect.height));
                            },
                            blendMode: BlendMode.dstIn,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment(0, -0.9),
                                  end: Alignment.topCenter,
                                  colors: [Colors.white, Colors.transparent],
                                ).createShader(Rect.fromLTRB(
                                    0, 0, rect.width, rect.height));
                              },
                              blendMode: BlendMode.dstIn,
                              child: ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.all(12),
                                primary: false,
                                physics: BouncingScrollPhysics(),
                                children: <Widget>[
                                  Center(
                                    child: Card(
                                      color: _pictureCardColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(1000))),
                                      child: SizedBox(
                                          width: _profilePicSize,
                                          height: _profilePicSize,
                                          child: RawMaterialButton(
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              padding: EdgeInsets.all(12),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: AdvancedNetworkImage(
                                                    _profilePicImageLink1,
                                                    useDiskCache: true,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                              onPressed: () async {
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfilePicturesScreen(
                                                              user: user,
                                                            ))).then((value) =>
                                                    _loadProfilePictures());
                                              })),
                                    ),
                                  ),
                                ],
                              ),
                            ))),
                    Divider(),
                    Divider(color: Colors.transparent),
                    Container(
                      decoration: BoxDecoration(),
                      child: ListTile(
                          dense: true,
                          leading: FaIcon(
                            FontAwesomeIcons.userAlt,
                            color: black,
                          ),
                          title: Text(
                            'Personal information',
                            textAlign: TextAlign.left,
                            style: _biggerFont,
                          ),
                          subtitle: Text(
                            'Age, gender, height, weight, etc.',
                            style: _subFont,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PersonalInformationScreen(
                                          user: user,
                                        )));
                          }),
                    ),
                    Divider(color: Colors.transparent),
                    Container(
                      decoration: BoxDecoration(),
                      child: ListTile(
                          dense: true,
                          leading: FaIcon(
                            FontAwesomeIcons.search,
                            color: black,
                          ),
                          title: Text(
                            'I am looking for',
                            textAlign: TextAlign.left,
                            style: _biggerFont,
                          ),
                          subtitle: Text(
                            'Gender, type of relationship, etc.',
                            style: _subFont,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SearchInformationScreen(
                                          user: user,
                                        )));
                          }),
                    ),
                    Divider(color: Colors.transparent),
                    Container(
                      decoration: BoxDecoration(),
                      child: ListTile(
                          dense: true,
                          leading: FaIcon(
                            FontAwesomeIcons.snowboarding,
                            color: black,
                          ),
                          title: Text(
                            'My way of living',
                            textAlign: TextAlign.left,
                            style: _biggerFont,
                          ),
                          subtitle: Text(
                            'Interests, passions, hobbies, kinks, etc.',
                            style: _subFont,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WayOfLivingScreen(
                                          user: user,
                                        )));
                          }),
                    ),
                    Divider(color: Colors.transparent),
                    Container(
                      decoration: BoxDecoration(),
                      child: ListTile(
                          dense: true,
                          leading: FaIcon(
                            FontAwesomeIcons.wrench,
                            color: black,
                          ),
                          title: Text(
                            'Settings',
                            textAlign: TextAlign.left,
                            style: _biggerFont,
                          ),
                          subtitle: Text(
                            'Notifications, Email, Phone Number, etc.',
                            style: _subFont,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                          ),
                          onTap: () {
                            setState(() {});
                          }),
                    ),
                    Divider(color: Colors.transparent),
                    Divider(),
                    Container(
                      decoration: BoxDecoration(),
                      child: ListTile(
                          dense: true,
                          leading: FaIcon(
                            FontAwesomeIcons.signOutAlt,
                            color: black,
                          ),
                          title: Text(
                            'SIGN OUT',
                            textAlign: TextAlign.left,
                            style: _biggerFont,
                          ),
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoadingPage()));
                          }),
                    ),
                    Divider(color: Colors.transparent),
                  ],
                ),
              ]),
            )));
  }

  Future<void> _downloadData() async {
    // Downloading data and synchronizing it with public variables

    if (!pMatchesInitialized) {
      Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data_generated')
          .document('user_rooms')
          .collection('p_matches')
          .snapshots()
          .listen((querySnapshot) {
        _pMatches = querySnapshot.documents;
        _loadPMatchesData();
      });

      pMatchesInitialized = true;
    }

    if (!matchesInitialized) {
      Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data_generated')
          .document('user_rooms')
          .collection('matches')
          .snapshots()
          .listen((querySnapshot) {
        _matches = querySnapshot.documents;
        _loadMatchesData();
      });

      matchesInitialized = true;
    }
  }

  void _loadMatchesData() async {
    if (_matchImageLinks.isNotEmpty) {
      _matchImageLinks.clear();
    }
    if (_matchLastMessages.isNotEmpty) {
      _matchLastMessages.clear();
    }

    for (var match in _matches) {
      try {
        // Getting the picture download URL for each user from the downloaded array
        _matchImageLinks.add(await FirebaseStorage()
            .ref()
            .child('users/${match['otherUserId']}/profile_pictures/pic1.jpg')
            .getDownloadURL());

        // Getting the last message sent in each conversation
        var lastMessage = await Firestore.instance
            .collection('messages')
            .document('rooms')
            .collection('${match['room']}')
            .where('time', isGreaterThanOrEqualTo: 0)
            .orderBy('time', descending: true)
            .limit(1)
            .getDocuments();
            
        _matchLastMessages.add(lastMessage.documents[0]);
      } catch (e) {
        print(e);
      }
    }
    
    setState(() {});
  }

  void _loadPMatchesData() async {
    if (_pMatchLastMessages.isNotEmpty) {
      _pMatchLastMessages.clear();
    }

    for (var match in _pMatches) {
      try {
        // Getting the last message sent in each conversation
        var lastMessage = await Firestore.instance
            .collection('messages')
            .document('rooms')
            .collection('${match['room']}')
            .where('time', isGreaterThanOrEqualTo: 0)
            .orderBy('time', descending: true)
            .limit(1)
            .getDocuments();
            

        _pMatchLastMessages.add(lastMessage.documents[0]);
      } catch (e) {
        print(e);
      }
    }

    setState(() {});

    return;
  }

  Widget _buildPMatchesTiles() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(1),
        controller: _scrollController,
        itemCount: _pMatches.length + 2,
        itemBuilder: (context, i) {
          if (i == 0) {
            return ListTile(
              leading: Text('POTENTIAL MATCHES',
                  textAlign: TextAlign.left, style: _listTitleStyle),
            );
          }

          if (i == _pMatches.length + 1) {
            return ListTile(
              title: Text(
                'Find someone new',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: FaIcon(
                FontAwesomeIcons.userPlus,
                color: black,
              ),
              onTap: _sendPotentialMatchRequest,
            );
          }

          final pMatch = _pMatches[i - 1];
          var lastMessage;
          var time;

          if (pMatch['pending'] == true) {
            return ListTile(
              title: Text(
                'Searching the world',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              subtitle: Text(
                'We will let you know when we find someone',
                style: _subFont,
                textAlign: TextAlign.left,
                maxLines: 1,
              ),
              trailing: FaIcon(
                FontAwesomeIcons.clock,
                color: black,
              ),
              onTap: () {},
              onLongPress: () {
                setState(() {
                  showDeleteDialog(context, 'Request').then((v) {
                    if (v) {
                      _deleteRequest(pMatch.documentID);
                    }
                  });
                });
              },
            );
          } else {
            if (_pMatchLastMessages.isNotEmpty) {
              time = _pMatchLastMessages[i - 1]['time'];
            }
            if (_pMatchLastMessages.isNotEmpty && time > 0) {
              if (_pMatchLastMessages[i - 1]['from'] == user.uid) {
                lastMessage = 'You: ${_pMatchLastMessages[i - 1]['message']}';
              } else {
                lastMessage = _pMatchLastMessages[i - 1]['message'];
              }
            } else {
              lastMessage = 'Start Conversation';
            }
            return ListTile(
              leading: CircleAvatar(
                  child: Text(pMatch['otherUser'].toUpperCase()[0])),
              title: Text(
                pMatch['otherUser'],
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              subtitle: Text(
                lastMessage,
                style: _subFont,
                textAlign: TextAlign.left,
              ),
              trailing: Text(
                convertPMatchTime(
                    int.parse(pMatch.documentID), pMatch.documentID),
                style: _trailFont,
                textAlign: TextAlign.left,
              ),
              onTap: () {
                (convertPMatchTime(int.parse(pMatch.documentID), pMatch.documentID) != 'COMPLETED')
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PMConversationScreen(
                                  user: user,
                                  matchName: pMatch['otherUser'],
                                  username: user.displayName,
                                  room: pMatch['room'],
                                ))).then((value) {
                        _loadPMatchesData();
                      })
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectMatchesScreen(
                                  user: user,
                                  room: pMatch['room'],
                                  roomKey: pMatch.documentID,
                                )));
              },
              onLongPress: () {
                setState(() {
                  showDeleteDialog(context, pMatch['otherUser'])
                      .then((v) {
                    if (v) {
                      _deletePotentialMatch(
                          int.parse(pMatch.documentID), pMatch['room']);
                    }
                  });
                });
              }
            );
          }
        });
    /*
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document('${user.uid}')
            .collection('data_generated')
            .document('user_rooms')
            .collection('p_matches')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            var header = <ListTile>[
              ListTile(
                leading: Text('POTENTIAL MATCHES',
                    textAlign: TextAlign.left, style: _listTitleStyle),
              )
            ];

            var listTiles = snapshot.data.documents
                .where((element) => element['otherUser'] != null)
                .map((DocumentSnapshot document) {
              return ListTile(
                  title: Text(
                    document['otherUser'],
                    style: _biggerFont,
                  ),
                  subtitle: Text(
                    '',
                    style: _subFont,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                  ),
                  trailing: Text(
                    convertPMatchTime(
                        int.parse(document.documentID), document.documentID),
                    style: _trailFont,
                    textAlign: TextAlign.left,
                  ),
                  onTap: () {
                    setState(() {
                      (convertPMatchTime(int.parse(document.documentID),
                                  document.documentID) !=
                              'COMPLETED')
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PMConversationScreen(
                                        user: user,
                                        matchName: document['otherUser'],
                                        username: user.displayName,
                                        room: document['room'],
                                      )))
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectMatchesScreen(
                                        user: user,
                                        room: document['room'],
                                        roomKey: document.documentID,
                                      )));
                    });
                  },
                  onLongPress: () {
                    setState(() {
                      showDeleteDialog(context, document['otherUser'])
                          .then((v) {
                        if (v) {
                          _deletePotentialMatch(
                              int.parse(document.documentID), document['room']);
                        }
                      });
                    });
                  });
            }).toList();

            var pendingTiles = snapshot.data.documents
                .where((element) => element['pending'] == true)
                .map((DocumentSnapshot document) {
              return ListTile(
                title: Text(
                  'Searching the world',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                subtitle: Text(
                  'We will let you know when we find someone',
                  style: _subFont,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                ),
                trailing: FaIcon(
                  FontAwesomeIcons.clock,
                  color: black,
                ),
                onTap: () {},
                onLongPress: () {
                  setState(() {
                    showDeleteDialog(context, 'Request').then((v) {
                      if (v) {
                        _deleteRequest(document.documentID);
                      }
                    });
                  });
                },
              );
            }).toList();

            var availableTiles = [
              ListTile(
                title: Text(
                  'Find someone new',
                  textAlign: TextAlign.left,
                  style: _biggerFont,
                ),
                trailing: FaIcon(
                  FontAwesomeIcons.userPlus,
                  color: black,
                ),
                onTap: _sendPotentialMatchRequest,
              )
            ];

            List<Object> completeList =
                header + listTiles + pendingTiles + availableTiles;

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else {
              return ListView(
                  padding: const EdgeInsets.all(1),
                  controller: _scrollController,
                  children: completeList);
            }
          }

          return Center(child: CircularProgressIndicator());
        });
        */
  }

  Widget _buildMatchedConvos() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(1),
      controller: _scrollController,
      itemCount: _matches.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return ListTile(
            leading: Text('MATCHES',
                textAlign: TextAlign.left, style: _listTitleStyle),
          );
        }

        final match = _matches[i - 1];
        var lastMessage;
        var time;
        if (_matchLastMessages.isNotEmpty) {
          time = _matchLastMessages[i - 1]['time'];
        }
        if (_matchLastMessages.isNotEmpty && time > 0) {
          if (_matchLastMessages[i - 1]['from'] == user.uid) {
            lastMessage = 'You: ${_matchLastMessages[i - 1]['message']}';
          } else {
            lastMessage = _matchLastMessages[i - 1]['message'];
          }
        } else {
          lastMessage = 'Start Conversation';
        }
        return ListTile(
            leading: Container(
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: SizedBox(
                height: 50,
                width: 50,
                child: Container(
                    decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: _matchImageLinks.isNotEmpty
                      ? DecorationImage(
                          image: AdvancedNetworkImage(
                            _matchImageLinks[i - 1],
                            useDiskCache: true,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                )),
              ),
            ),
            title: Text(
              match['otherUser'],
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              lastMessage,
              style: _subFont,
              textAlign: TextAlign.left,
            ),
            trailing: Text(
              (_matchLastMessages.isNotEmpty && time > 0)
                  ? convertMatchTime(
                      int.parse(_matchLastMessages[i - 1].documentID))
                  : '',
              style: _trailFont,
              textAlign: TextAlign.left,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MatchedConversationScreen(
                            user: user,
                            matchName: match['otherUser'],
                            otherUserId: match['otherUserId'],
                            username: user.displayName,
                            room: match['room'],
                          ))).then((value) {
                _loadMatchesData();
              });
            });
      }
    );
  }

  Widget _buildMatchesTiles(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasData) {
      var header = <ListTile>[
        ListTile(
          leading: Text('MATCHES',
              textAlign: TextAlign.left, style: _listTitleStyle),
        )
      ];

      var listTiles = snapshot.data.documents
          .where((element) => element['otherUser'] != null)
          .map((DocumentSnapshot document) {
        return ListTile(
            leading: Container(
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: SizedBox(
                height: 50,
                width: 50,
                child: Center(
                    child: FaIcon(
                  FontAwesomeIcons.userAlt,
                  color: black,
                )),
              ),
            ),
            title: Text(
              document['otherUser'],
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: Text(
              '48 mins',
              style: _trailFont,
              textAlign: TextAlign.left,
            ),
            onTap: () {
              setState(() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MatchedConversationScreen(
                              user: user,
                              otherUserId: document['otherUserId'],
                              matchName: document['otherUser'],
                              username: user.displayName,
                              room: document['room'],
                            )));
              });
            });
      }).toList();

      List<Object> completeList = header + listTiles;

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text('Loading...');
      } else {
        return ListView(
            padding: const EdgeInsets.all(1),
            controller: _scrollController,
            children: completeList);
      }
    }
    return Center(child: CircularProgressIndicator());
  }

  Future<bool> _deletePotentialMatch(int time, String room) async {
    final snackBar = SnackBar(
      content: Text(
        'Deleting Potential Match',
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'deletePotentialMatch',
    );

    // Adding variables to the server to the request and calling the function
    dynamic resp = await callable.call(<String, dynamic>{
      'time': time,
      'room': room,
    });

    print(resp.data['success']);

    _scaffoldKey.currentState.hideCurrentSnackBar();
    return (resp.data['success']);
  }

  Future<void> _deleteRequest(String id) async {
    final snackBar = SnackBar(
      content: Text(
        'Deleting Request',
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);

    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'deleteRequest',
    );

    // Adding variables to the server to the request and calling the function
    await callable.call(<String, dynamic>{
      'requestId': id,
    });

    _scaffoldKey.currentState.hideCurrentSnackBar();
    return;
  }

  /// Updates the location of the device to the database and sends a request for a potential match.
  Future<bool> _sendPotentialMatchRequest() async {
    var location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Checking is location is enabled in device
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        return false;
      }
    }

    // Checking if app has permission to get location
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();

      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    // Getting location form device.
    locationData = await location.getLocation();

    final snackBar = SnackBar(
      content: Text(
        'Sending Request',
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);

    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getPotentialMatch',
    );

    // Adding variables to the server to the request and calling the function
    dynamic resp = await callable.call(<String, dynamic>{
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
    });

    print(resp.data['success']);

    _scaffoldKey.currentState.hideCurrentSnackBar();
    return (resp.data['success']);
  }

  String convertMatchTime(int time) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(time);

    var minutes = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(time))
        .inMinutes;

    var hours = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(time))
        .inHours;

    var days = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(time))
        .inDays;

    if (minutes < 1) {
      return 'Just now';
    } else if (minutes < 60) {
      return (minutes > 1) ? '$minutes minutes ago' : '$minutes minute ago';
    } else if (hours < 24) {
      return (hours > 1) ? '$hours hours ago' : '$hours hour ago';
    } else if (days < 7) {
      return (days > 1) ? '${dateTime} days ago' : '${dateTime} day ago';
    } else if (days > 7) {
      return '${dateTime}';
    }

    return '';
  }

  String convertPMatchTime(int time, String roomKey) {
    var minutes = DateTime.fromMillisecondsSinceEpoch(time)
        .difference(DateTime.now())
        .inMinutes;

    var hours = DateTime.fromMillisecondsSinceEpoch(time)
        .difference(DateTime.now())
        .inHours;

    var days = DateTime.fromMillisecondsSinceEpoch(time)
        .difference(DateTime.now())
        .inDays;

    // Sending connection request 24 hours before the connection screen is shown to have profiles ready and prevent slowdown in the app
    if (hours < 36) {
      Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data_generated')
          .document('user_rooms')
          .collection('p_matches')
          .document('$roomKey')
          .get()
          .then((doc) {
        if (!doc.exists) {
          print('No data document!');
        } else {
          if (doc.data['connections'] == null ||
              doc.data['connections'].length == 0) {
            unawaited(_sendConnectionsRequest(roomKey));
          }
        }
      });
    }
    if (minutes < 0) {
      return 'COMPLETED';
    }

    if (minutes < 60) {
      return (minutes > 1) ? '$minutes mins left' : '$minutes min left';
    } else if (hours < 24) {
      return (hours > 1) ? '$hours hours left' : '$hours hour left';
    } else if (days > 0) {
      if (days > 1) {
        if (hours % 24 > 1) {
          return '$days days, ${hours % 24} hours left';
        } else {
          return '$days days, ${hours % 24} hour left';
        }
      } else {
        if (hours % 24 > 1) {
          return '$days day, ${hours % 24} hours left';
        } else {
          return '$days day, ${hours % 24} hour left';
        }
      }
    }

    return ' ';
  }

  Future<void> _sendConnectionsRequest(String roomKey) async {
    // If the connections array has not been created yet, request the server to create it
    var location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Checking is location is enabled in device
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        return false;
      }
    }

    // Checking if app has permission to get location
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();

      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    // Getting location form device.
    locationData = await location.getLocation();

    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getConnectionUsers',
    );

    // Adding variables to the server to the request and calling the function
    dynamic resp = await callable.call(<String, dynamic>{
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'key': roomKey
    });

    print(resp.data['connections']);
  }

  /// Shows the an alert asking the user if delete should really be done
  Future<bool> showDeleteDialog(BuildContext context, String name) async {
    var choice = false;

    // Await for the dialog to be dismissed before returning
    (Platform.isAndroid)
        ? await showDialog<bool>(
            context: context,
            barrierDismissible: true, // user can type outside box to dismiss
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text('Are you sure?'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                            'Do you really want to delete the conversation with $name?'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("I\'m sure"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        choice = true;
                      },
                    ),
                  ]);
            })
        : await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                  title: Text('Are you sure?'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                            'Do you really want to delete the conversation with $name?'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("I\'m sure"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        choice = true;
                      },
                    ),
                  ]);
            });
    return choice;
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

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headline,
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => null;
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}
