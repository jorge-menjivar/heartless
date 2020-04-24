import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'messages/m_p_matches_screen.dart';
import 'convo_completion/select_matches_screen.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';

// Tools
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

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
  color: Colors.white,
);
final _subFont = const TextStyle(
  color: Colors.white,
);
final _trailFont = const TextStyle(
  color: Colors.white,
);

bool isNew = false;

class InitPage extends StatefulWidget {
  final FirebaseUser user;
  final String username;
  InitPage({this.user, this.username});

  @override
  InitPageState createState() => InitPageState(user: user, username: username);
}

class InitPageState extends State<InitPage> with WidgetsBindingObserver {
  File _image;

  InitPageState({this.user, this.username});

  FirebaseUser user;
  final String username;

  final secureStorage = FlutterSecureStorage();

  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    //TODO _checkCurrentUser();
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        centerTitle: true,
                        title: Text(
                          'LISA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        expandedHeight: 140.0,
                        floating: true,
                        pinned: true,
                        snap: false,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          background: Image.network(
                            'https://c2.staticflickr.com/6/5283/5321712546_e9c3d4d4c1_b.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        bottom: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(
                              icon: Icon(Icons.search),
                            ),
                            Tab(
                              icon: Icon(Icons.message),
                            ),
                            Tab(
                              icon: Icon(Icons.person),
                            ),
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
                      .document('user1')
                      .collection('data_generated')
                      .document('user_rooms')
                      .collection('p_matches')
                      .snapshots(),
                  builder: _buildPMatchesTiles
                ),
                
                
                ///------------------------------------------- MATCHES ---------------------------------------------
                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('users')
                      .document('user1')
                      .collection('data_generated')
                      .document('user_rooms')
                      .collection('matches')
                      .snapshots(),
                  builder: _buildMatchesTiles
                ),
                
                ///------------------------------------------- PROFILE ---------------------------------------------
                ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(1),
                  children: <Widget>[
                    ListTile(
                      leading: Text(
                        'PROFILE',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                          width: 200,
                          height: 200,
                          child: CupertinoButton(
                            child: Container(
                                decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: FirebaseImage(
                                  'gs://lise-99703.appspot.com/users/profile_pictures/pic1.jpg',
                                  shouldCache: false),
                                fit: BoxFit.cover,
                              ),
                            )),
                            onPressed: getImageFromGallery
                          )),
                    ),
                    Divider(),
                    Divider(color: white),
                    Container(
                      decoration: BoxDecoration(),
                      child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.person,
                            color: white,
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
                          onLongPress: () {},
                          onTap: () {
                            setState(() {});
                          }),
                    ),
                    Divider(),
                    Container(
                      decoration: BoxDecoration(),
                      child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.search,
                            color: white,
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
                          onLongPress: () {},
                          onTap: () {
                            setState(() {});
                          }),
                    ),
                    Divider(),
                    Container(
                      decoration: BoxDecoration(),
                      child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.compare_arrows,
                            color: white,
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
                          onLongPress: () {},
                          onTap: () {
                            setState(() {});
                          }),
                    ),
                    Container(
                      decoration: BoxDecoration(),
                      child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.exit_to_app,
                            color: white,
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
                  ],
                ),
              ]),
            )));
  }

  Widget _buildPMatchesTiles(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    
      if (snapshot.hasData) {
      var header = <ListTile>[
        ListTile(
          leading: Text(
            'POTENTIAL MATCHES',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ];

      var listTiles =
          snapshot.data.documents.where((element) => element['otherUser'] != null).map((DocumentSnapshot document) {
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
          onLongPress: () {},
          onTap: () {
            setState(() {
              (convertTime(int.parse(document.documentID)) != 'COMPLETED') ?
                Navigator.push(context, MaterialPageRoute(builder:
                (context) => PMConversationScreen(
                  user: user,
                  matchName: document['otherUser'],
                  username: user.displayName,
                  room: document['room'],
                )))
              
              : Navigator.push(context, MaterialPageRoute(builder:
                (context) => SelectMatchesScreen(
                  room: document['room'],
                )));
            });
          });
      }).toList();
      
      var pendingTiles =
          snapshot.data.documents.where((element) => element['pending'] == true).map((DocumentSnapshot document) {
        return ListTile(
          title: Text(
            'Searching the world',
            textAlign: TextAlign.left,
            style: _biggerFont,
          ),
          subtitle: Text(
            'We will let you know when we find someone for you',
            style: _subFont,
            textAlign: TextAlign.left,
            maxLines: 1,
          ),
          trailing: Icon(
            Icons.access_time,
            color: white,
          ),
          onLongPress: () {},
          onTap: () {},
        );
      }).toList();
      
      
      var availableTiles =
          snapshot.data.documents.where((element) => element['available'] == true).map((DocumentSnapshot document) {
        return ListTile(
          title: Text(
            'Find someone new',
            textAlign: TextAlign.left,
            style: _biggerFont,
          ),
          trailing: Icon(
            Icons.person_add,
            color: white,
          ),
          onLongPress: () {},
          onTap: _sendPotentialMatchRequest,
        );
      }).toList();
      
      
      List<Object> completeList = header + listTiles + pendingTiles + availableTiles;

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
    
    return CircularProgressIndicator();
  }
  
  
  
  Widget _buildMatchesTiles(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    
      if (snapshot.hasData) {
      var header = <ListTile>[
        ListTile(
          leading: Text(
            'MATCHES',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ];

      var listTiles =
          snapshot.data.documents.where((element) => element['otherUser'] != null).map((DocumentSnapshot document) {
        return ListTile(
          dense: true,
          leading: Container(
            decoration: BoxDecoration(
                color: Colors.red, shape: BoxShape.circle),
            child: Icon(Icons.person),
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
          onLongPress: () {},
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
    
    return CircularProgressIndicator();
  }
  
  
  void _sendPotentialMatchRequest() async {
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getPotentialMatch',
    );
    
    dynamic resp = await callable.call();
    
    print(resp);
    
    /**
     * Calling function with parameters
    dynamic resp = await callable.call(<String, dynamic>{
        'YOUR_PARAMETER_NAME': 'YOUR_PARAMETER_VALUE',
    });
    **/
  }
  
  
  String convertTime(int time) {
    var minutes = DateTime.fromMillisecondsSinceEpoch(time).difference(DateTime.now()).inMinutes;
    
    var hours = DateTime.fromMillisecondsSinceEpoch(time).difference(DateTime.now()).inHours;
    
    var days = DateTime.fromMillisecondsSinceEpoch(time).difference(DateTime.now()).inDays;
    
    if (minutes < 0) {
      return 'COMPLETED';
    }
    
    if (minutes < 60) {
      return '$minutes mins left';
    }
    
    else if (hours < 24) {
      return '$hours hours left';
    }
    
    else if (days > 0){
      return '$days days left';
    }
    
    return ' ';
    
  }
  
  
  /// Gets image from gallery and uploads it to firebase storage
  Future getImageFromGallery() async {
    setState(() {
    });
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    
    if (image == null) {
      return;
    }
    
    
    final storageReference = FirebaseStorage().ref().child('users/profile_pictures/pic1.jpg');
    
    final uploadTask = storageReference.putFile(image);
    
    await uploadTask.onComplete;
    print('image uploaded');
    
    await FirebaseImage('gs://lise-99703.appspot.com/users/profile_pictures/pic1_700x700.jpg').evict();
    
    setState(() {
    });
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
