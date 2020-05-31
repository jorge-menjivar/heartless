import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SelectMatchesScreen extends StatefulWidget {
  final String room;

  SelectMatchesScreen({@required this.room});

  @override
  SelectMatchesScreenState createState() =>
      SelectMatchesScreenState(room: room);
}

class SelectMatchesScreenState extends State<SelectMatchesScreen> {
  final String room;

  SelectMatchesScreenState({@required this.room});

  final secureStorage = FlutterSecureStorage();

  FirebaseUser user;

  ScrollController _scrollController;

  var _profiles;
  final _picSize = 370.0;

  String _profilePicImageLink1 = 'http://loading';
  String _profilePicImageLink2 = 'http://loading';
  String _profilePicImageLink3 = 'http://loading';

  StorageReference _storageReference1;
  StorageReference _storageReference2;
  StorageReference _storageReference3;

  @override
  void initState() {
    super.initState();
    _loadProfilePictures();
    _scrollController = ScrollController();
    _profiles = [false, false, false];
  }

  void _loadProfilePictures() async {
    var users = ['Tm53aKmKQ0Vhn96xzNvHI1VtzF33', 'XbVHY0RTMfXP21iKUrmcOVhd2gt1', 'cv2JV8SgQugSLwHkhWFW334rca03'];

    try {
      _storageReference1 = FirebaseStorage()
          .ref()
          .child('users/${users[0]}/profile_pictures/pic1.jpg');
    } catch (e) {
      print(e);
    }
    try {
      _storageReference2 = FirebaseStorage()
          .ref()
          .child('users/${users[1]}/profile_pictures/pic1.jpg');
    } catch (e) {
      print(e);
    }
    try {
      _storageReference3 = FirebaseStorage()
          .ref()
          .child('users/${users[2]}/profile_pictures/pic1.jpg');
    } catch (e) {
      print(e);
    }

    _profilePicImageLink1 = await _storageReference1.getDownloadURL();
    _profilePicImageLink2 = await _storageReference2.getDownloadURL();
    _profilePicImageLink3 = await _storageReference3.getDownloadURL();

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
                            child: ListView(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              controller: _scrollController,
                              children: <Widget>[
                                Center(
                                  child: Card(
                                    color: (_profiles[0])
                                        ? Colors.green
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(1000))),
                                    child: SizedBox(
                                        width: _picSize,
                                        height: _picSize,
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
                                              )
                                            ),
                                            onPressed: () {
                                                setState(() {
                                                  _profiles[0] =
                                                      !_profiles[0];
                                                });
                                            })),
                                  ),
                                ),
                                Center(
                                  child: Card(
                                    color: (_profiles[1])
                                        ? Colors.green
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(1000))),
                                    child: SizedBox(
                                        width: _picSize,
                                        height: _picSize,
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
                                            onPressed: () {
                                                setState(() {
                                                  _profiles[1] =
                                                      !_profiles[1];
                                                });
                                            })),
                                  ),
                                ),
                                Center(
                                  child: Card(
                                    color: (_profiles[2])
                                        ? Colors.green
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(1000))),
                                    child: SizedBox(
                                        width: _picSize,
                                        height: _picSize,
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
                                            onPressed: () {
                                                setState(() {
                                                  _profiles[2] =
                                                      !_profiles[2];
                                                });
                                            })),
                                  ),
                                ),
                              ]
                            )
                          ),
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

  @override
  void dispose() {
    super.dispose();
  }
}
