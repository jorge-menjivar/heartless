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

class InitScreen extends StatelessWidget {
  InitScreen({this.user, this.username});
  final FirebaseUser user;
  final String username;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  String _profilePicImageLink1;
  String _profilePicImageLink2;
  String _profilePicImageLink3;
  String _profilePicImageLink4;
  String _profilePicImageLink5;

  StorageReference _storageReference1;
  StorageReference _storageReference2;
  StorageReference _storageReference3;
  StorageReference _storageReference4;
  StorageReference _storageReference5;

  void _loadProfilePictures() async {
    try {
      _storageReference1 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic1.jpg');
    } catch (e) {
      print(e);
    }
    try {
      _storageReference2 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic2.jpg');
    } catch (e) {
      print(e);
    }
    try {
      _storageReference3 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic3.jpg');
    } catch (e) {
      print(e);
    }
    try {
      _storageReference4 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic4.jpg');
    } catch (e) {
      print(e);
    }
    try {
      _storageReference5 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic5.jpg');
    } catch (e) {
      print(e);
    }

    _profilePicImageLink1 = await _storageReference1.getDownloadURL();
    _profilePicImageLink2 = await _storageReference2.getDownloadURL();
    _profilePicImageLink3 = await _storageReference3.getDownloadURL();
    _profilePicImageLink4 = await _storageReference4.getDownloadURL();
    _profilePicImageLink5 = await _storageReference5.getDownloadURL();

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
