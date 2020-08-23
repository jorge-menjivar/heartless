import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'models/public_profile_model.dart';

abstract class PublicData {
  Future<PublicProfile> fetchProfile({
    @required String alias,
  });
}

class PublicDataRepository implements PublicData {
  var storageReference;
  @override
  Future<PublicProfile> fetchProfile({
    @required String alias,
  }) async {
    // Getting the pictures for this user
    var profileImages = [];
    try {
      for (int i = 1; i < 6; i++) {
        storageReference = FirebaseStorage().ref().child('users/$alias/profile_pictures/pic$i.jpg');
        profileImages.add(await storageReference.getDownloadURL());
        print(profileImages[i - 1]);
      }
    } catch (e) {
      print(e);
    }
    return PublicProfile(pictureURLs: profileImages);
  }
}
