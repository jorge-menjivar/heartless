import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// Tools
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_package;

// Storage
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePicturesScreen extends StatefulWidget {
  ProfilePicturesScreen({@required this.user});

  final FirebaseUser user;

  @override
  ProfilePicturesScreenState createState() =>
      ProfilePicturesScreenState(user: user);
}

class ProfilePicturesScreenState extends State<ProfilePicturesScreen> {
  ProfilePicturesScreenState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Public Profile'),
        elevation: 4.0,
        /* actions: <Widget>[
          MaterialButton(
            child: Icon (
              Icons.flag,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO report user
            },
          )
        ],*/
      ),
      body: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(0, 0.9),
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.transparent],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.dstIn,
          child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment(0, -0.9),
                  end: Alignment.topCenter,
                  colors: [Colors.white, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: ListView(
                shrinkWrap: true,
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Divider(color: Colors.transparent),
                  Center(
                    child: SizedBox(
                        width: 390,
                        height: 390,
                        child: RawMaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          padding: EdgeInsets.all(4),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18.0),
                                  color: Colors.red),
                              padding: EdgeInsets.all(10),
                              child: Container(
                                  decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Colors.transparent,
                                image: DecorationImage(
                                  image: AdvancedNetworkImage(
                                    _profilePicImageLink1,
                                    useDiskCache: true,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ))),
                          onLongPress: () {},
                          onPressed: () {
                            getImageFromGallery(1);
                          },
                        )),
                  ),
                  Center(
                    child: SizedBox(
                        width: 350,
                        height: 350,
                        child: RawMaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          padding: EdgeInsets.all(4),
                          child: Container(
                              decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            image: DecorationImage(
                              image: AdvancedNetworkImage(
                                _profilePicImageLink2,
                                useDiskCache: true,
                              ),
                              fit: BoxFit.cover,
                            ),
                          )),
                          onLongPress: () {},
                          onPressed: () {
                            getImageFromGallery(2);
                          },
                        )),
                  ),
                  Center(
                    child: SizedBox(
                        width: 350,
                        height: 350,
                        child: RawMaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          padding: EdgeInsets.all(4),
                          child: Container(
                              decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            image: DecorationImage(
                              image: AdvancedNetworkImage(
                                _profilePicImageLink3,
                                useDiskCache: true,
                              ),
                              fit: BoxFit.cover,
                            ),
                          )),
                          onLongPress: () {},
                          onPressed: () {
                            getImageFromGallery(3);
                          },
                        )),
                  ),
                  Center(
                    child: SizedBox(
                        width: 350,
                        height: 350,
                        child: RawMaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          padding: EdgeInsets.all(4),
                          child: Container(
                              decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            image: DecorationImage(
                              image: AdvancedNetworkImage(
                                _profilePicImageLink4,
                                useDiskCache: true,
                              ),
                              fit: BoxFit.cover,
                            ),
                          )),
                          onLongPress: () {},
                          onPressed: () {
                            getImageFromGallery(4);
                          },
                        )),
                  ),
                  Center(
                    child: SizedBox(
                        width: 350,
                        height: 350,
                        child: RawMaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          padding: EdgeInsets.all(4),
                          child: Container(
                              decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            image: DecorationImage(
                              image: AdvancedNetworkImage(
                                _profilePicImageLink5,
                                useDiskCache: true,
                              ),
                              fit: BoxFit.cover,
                            ),
                          )),
                          onLongPress: () {},
                          onPressed: () {
                            getImageFromGallery(5);
                          },
                        )),
                  ),
                  Divider(color: Colors.transparent),
                ],
              ))),
    );
  }

  /// Gets image from gallery and uploads it to firebase storage.
  /// [pictureNumber] represent the number of the card of where the picture is at.
  Future getImageFromGallery(int pictureNumber) async {
    // Open gallery to select picture
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    // making sure a picture was selected from the gallery
    if (image == null) {
      return;
    }

    // Decoding Image before resizing
    var decodedImage = image_package.decodeImage(image.readAsBytesSync());

    // Making a copy of the copy and cropping and resizing
    var editedImage = image_package.copyResizeCropSquare(decodedImage, 850);

    var appDocDirectory = await getApplicationDocumentsDirectory();
    var croppedResizedImage =
        File('${appDocDirectory.path}/croppedResizedImage.jpg');
    croppedResizedImage.writeAsBytesSync(image_package.encodeJpg(editedImage));

    // Compressing the resized file
    var compressedCroppedResizedFile =
        await FlutterImageCompress.compressAndGetFile(
      '${appDocDirectory.path}/croppedResizedImage.jpg',
      '${appDocDirectory.path}/compressedCroppedResizedImage.jpg',
      quality: 35,
    );

    // Notifying user that the image is being uploaded through snackbar
    final snackBar = SnackBar(
      content: Text(
        'Uploading image',
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);

    // Deciding where to upload the picture to
    StorageReference reference;
    switch (pictureNumber) {
      case 1:
        reference = _storageReference1;
        break;

      case 2:
        reference = _storageReference2;
        break;

      case 3:
        reference = _storageReference3;
        break;

      case 4:
        reference = _storageReference4;
        break;

      case 5:
        reference = _storageReference5;
        break;
    }

    // Uploading picture to the storage reference
    final uploadTask = reference.putFile(compressedCroppedResizedFile);

    // Wait until has been completely uploaded
    await uploadTask.onComplete;
    print('image uploaded');

    // Get the link to the picture we just uploaded
    var link = await reference.getDownloadURL();

    // Update the link in global variable
    switch (pictureNumber) {
      case 1:
        _profilePicImageLink1 = link;
        break;

      case 2:
        _profilePicImageLink2 = link;
        break;

      case 3:
        _profilePicImageLink3 = link;
        break;

      case 4:
        _profilePicImageLink4 = link;
        break;

      case 5:
        _profilePicImageLink5 = link;
        break;
    }

    // Update the image widget
    setState(() {
      print('updating state');
      // Hide snackbar notification
      _scaffoldKey.currentState.hideCurrentSnackBar();
    });
  }
}
