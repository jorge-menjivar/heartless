import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:pedantic/pedantic.dart';

class SelectMatchesScreen extends StatefulWidget {
  final FirebaseUser user;
  final String room;
  final String roomKey;

  SelectMatchesScreen(
      {@required this.user, @required this.room, @required this.roomKey});

  @override
  SelectMatchesScreenState createState() =>
      SelectMatchesScreenState(user: user, room: room, roomKey: roomKey);
}

class SelectMatchesScreenState extends State<SelectMatchesScreen> {
  FirebaseUser user;
  final String room;
  final String roomKey;

  SelectMatchesScreenState(
      {@required this.user, @required this.room, @required this.roomKey});

  final secureStorage = FlutterSecureStorage();

  ScrollController _scrollController;

  var _profiles;
  final _picSize = 370.0;

  final _profilePicImageLinks = [];

  var _users = [];

  @override
  void initState() {
    super.initState();
    _downloadData();
    _loadProfilePictures();
    _scrollController = ScrollController();
    _profiles = [false, false, false];
  }

  Future<void> _downloadData() async {
    // Downloading data and synchronizing it with public variables
    await Firestore.instance
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
        _users = doc.data['connections'];
      }
    });

    // If the connections array has not been created yet, request the server to create it
    if (_users == null || _users.isEmpty) {
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

      unawaited(_downloadData());
      return;
    }

    _loadProfilePictures();
  }

  void _loadProfilePictures() async {
    // Getting the picture download URL for each user from the downloaded array
    for (var userId in _users) {
      try {
        _profilePicImageLinks.add(await FirebaseStorage()
            .ref()
            .child('users/${userId}/profile_pictures/pic1.jpg')
            .getDownloadURL());
      } catch (e) {
        print(e);
      }
    }

    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Looks'),
          elevation: 4.0,
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select the persons you find attractive',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        height: _picSize + 20,
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
                              child: _buildCards()),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoButton(
                                  color: Colors.black,
                                  child: Text(
                                    'CONTINUE',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {},
                                )
                              ]))
                    ]));
          },
        ));
  }

  Widget _buildCards() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      itemCount: _profilePicImageLinks.length,
      itemBuilder: (context, i) {
        return Center(
          child: Card(
            color: (_profiles[i]) ? Colors.green : Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(1000))),
            child: SizedBox(
                width: _picSize,
                height: _picSize,
                child: RawMaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    padding: EdgeInsets.all(12),
                    child: Container(
                        decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: _profilePicImageLinks.isNotEmpty
                          ? DecorationImage(
                              image: AdvancedNetworkImage(
                                _profilePicImageLinks[i],
                                useDiskCache: true,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    )),
                    onPressed: () {
                      setState(() {
                        _profiles[i] = !_profiles[i];
                      });
                    })),
          ),
        );
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
