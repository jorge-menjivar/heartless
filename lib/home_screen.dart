import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/user_profile/personal_information_screen.dart';
import 'package:lise/user_profile/profile_pictures_screen.dart';
import 'package:lise/user_profile/search_information_screen.dart';
import 'package:lise/user_profile/wol_screen.dart';
import 'package:location/location.dart';
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
  String _profilePicImageLink2 = 'http://loading';
  String _profilePicImageLink3 = 'http://loading';
  String _profilePicImageLink4 = 'http://loading';
  String _profilePicImageLink5 = 'http://loading';

  StorageReference _storageReference1;
  StorageReference _storageReference2;
  StorageReference _storageReference3;
  StorageReference _storageReference4;
  StorageReference _storageReference5;

  @override
  void initState() {
    super.initState();
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
    try {
      _storageReference2 = FirebaseStorage()
          .ref()
          .child('users/${user.uid}/profile_pictures/pic2.jpg');
    } catch (e) {
      print(e);
    }
    try {
      _storageReference3 = FirebaseStorage()
          .ref()
          .child('users/${user.uid}/profile_pictures/pic3.jpg');
    } catch (e) {
      print(e);
    }
    try {
      _storageReference4 = FirebaseStorage()
          .ref()
          .child('users/${user.uid}/profile_pictures/pic4.jpg');
    } catch (e) {
      print(e);
    }
    try {
      _storageReference5 = FirebaseStorage()
          .ref()
          .child('users/${user.uid}/profile_pictures/pic5.jpg');
    } catch (e) {
      print(e);
    }

    _profilePicImageLink1 = await _storageReference1.getDownloadURL();
    _profilePicImageLink2 = await _storageReference2.getDownloadURL();
    _profilePicImageLink3 = await _storageReference3.getDownloadURL();
    _profilePicImageLink4 = await _storageReference4.getDownloadURL();
    _profilePicImageLink5 = await _storageReference5.getDownloadURL();

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
                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('users')
                        .document('${user.uid}')
                        .collection('data_generated')
                        .document('user_rooms')
                        .collection('p_matches')
                        .snapshots(),
                    builder: _buildPMatchesTiles),

                ///------------------------------------------- MATCHES ---------------------------------------------
                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('users')
                        .document(user.uid)
                        .collection('data_generated')
                        .document('user_rooms')
                        .collection('matches')
                        .snapshots(),
                    builder: _buildMatchesTiles),

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
                                                    _profilePicImageLink2,
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
                                                    _profilePicImageLink3,
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
                                                    _profilePicImageLink4,
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
                                                    _profilePicImageLink5,
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

  Widget _buildPMatchesTiles(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
              convertTime(int.parse(document.documentID)),
              style: _trailFont,
              textAlign: TextAlign.left,
            ),
            onTap: () {
              setState(() {
                (convertTime(int.parse(document.documentID)) != 'COMPLETED')
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
                                  room: document['room'],
                                )));
              });
            },
            onLongPress: () {
              setState(() {
                showDeleteDialog(context, document['otherUser']).then((v) {
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
            subtitle: Text(
              'At the park behind the tree with the big white flowers',
              style: _subFont,
              textAlign: TextAlign.left,
              maxLines: 1,
            ),
            trailing: Text(
              '48 mins',
              style: _trailFont,
              textAlign: TextAlign.left,
            ),
            onTap: () {
              setState(() {});
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

  Future<bool> _deleteRequest(String id) async {
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
    dynamic resp = await callable.call(<String, dynamic>{
      'requestId': id,
    });

    print(resp.data['success']);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    return (resp.data['success']);
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

  String convertTime(int time) {
    var minutes = DateTime.fromMillisecondsSinceEpoch(time)
        .difference(DateTime.now())
        .inMinutes;

    var hours = DateTime.fromMillisecondsSinceEpoch(time)
        .difference(DateTime.now())
        .inHours;

    var days = DateTime.fromMillisecondsSinceEpoch(time)
        .difference(DateTime.now())
        .inDays;

    if (minutes < 0) {
      return 'COMPLETED';
    }

    if (minutes < 60) {
      return '$minutes mins left';
    } else if (hours < 24) {
      return '$hours hours left';
    } else if (days > 0) {
      return '$days days, ${hours % 24} hours left';
    }

    return ' ';
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
