import 'package:firebase_storage/firebase_storage.dart';

import 'models/profile_model.dart';

abstract class UserData {
  Future<Profile> fetchProfile(String alias);
}

class UserDataRepository implements UserData {
  var storageReference;
  @override
  Future<Profile> fetchProfile(String alias) async {
    try {
      storageReference = FirebaseStorage().ref().child('users/$alias/profile_pictures/pic1.jpg');
    } catch (e) {
      print(e);
    }

    final profilePicImageLink = await storageReference.getDownloadURL();

    return Profile(profilePictureURL: profilePicImageLink);
  }
}
