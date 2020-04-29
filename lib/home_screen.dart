
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/user_profile/personal_information_screen.dart';
import 'package:lise/user_profile/profile_pictures_screen.dart';
import 'package:lise/user_profile/search_information_screen.dart';
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
final _listTitleStyle = const TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold
);
var _iconColor = black;

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
  
  String _profilePicImageLink = 'http://loading';
  
  final double _profilePicSize = 200;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
    _scrollController = ScrollController();
    //TODO _checkCurrentUser();
  }
  
  
  Future<void> _loadProfilePicture() async {
    final storageReference = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic1.jpg');
    _profilePicImageLink = await storageReference.getDownloadURL();
    print(_profilePicImageLink);
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
                    width: _profilePicSize,
                    height: _profilePicSize,
                    child: CupertinoButton(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AdvancedNetworkImage(
                                _profilePicImageLink,
                                useDiskCache: true,
                              ),
                              fit: BoxFit.cover,
                            ),
                          )
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePicturesScreen(user: user,)
                            )
                          ).then((value) => _loadProfilePicture());
                        }
                    )
                  ),
                ),
                Divider(),
                Divider(
                  color: Colors.transparent
                ),
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
                    onLongPress: () {},
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalInformationScreen(user: user,)
                        )
                      );
                    }
                  ),
                ),
                Divider(
                  color: white
                ),
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
                      onLongPress: () {},
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchInformationScreen(user: user,)
                          )
                        );
                      }),
                ),
                Divider(
                  color: white
                ),
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
                      onLongPress: () {},
                      onTap: () {
                        setState(() {});
                      }),
                ),
                Divider(
                  color: Colors.transparent
                ),
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
                    onLongPress: () {},
                    onTap: () {
                      setState(() {});
                    }
                  ),
                ),
                Divider(
                  color: Colors.transparent
                ),
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
                          builder: (context) => LoadingPage()
                        )
                      );
                    }
                  ),
                ),
              ],
            ),
          ]),
        )
      )
    );
  }

  Widget _buildPMatchesTiles(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    
      if (snapshot.hasData) {
      var header = <ListTile>[
        ListTile(
          leading: Text(
            'POTENTIAL MATCHES',
            textAlign: TextAlign.left,
            style: _listTitleStyle
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
          trailing: FaIcon(
            FontAwesomeIcons.clock,
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
          trailing: FaIcon(
            FontAwesomeIcons.userPlus,
            color: black,
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
            style: _listTitleStyle
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
            child: Icon(
              Icons.person
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
