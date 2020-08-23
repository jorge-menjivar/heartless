import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'models/profile_model.dart';

abstract class UserData {
  Future<Profile> fetchProfile({
    @required FirebaseUser user,
    @required String alias,
  });
}

class UserDataRepository implements UserData {
  var storageReference;
  @override
  Future<Profile> fetchProfile({
    @required FirebaseUser user,
    @required String alias,
  }) async {
    try {
      storageReference = FirebaseStorage().ref().child('users/$alias/profile_pictures/pic1.jpg');
    } catch (e) {
      print(e);
    }

    var name;
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('data')
        .document('userSettings')
        .get()
        .then((doc) {
      if (!doc.exists) {
        print('No data document!');
      } else {
        if (doc.data['name'] != null) {
          name = doc.data['name'];
        }
      }
    });

    var email = user.email;

    final profilePicImageLink = await storageReference.getDownloadURL();

    return Profile(name: name, email: email, profilePictureURL: profilePicImageLink);
  }
}
