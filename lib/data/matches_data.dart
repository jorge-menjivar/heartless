import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'models/matches_model.dart';

abstract class MatchesData {
  Future<Matches> fetchData(var MatchesDocs);
}

class MatchesRepository implements MatchesData {
  var storageReference;

  @override
  Future<Matches> fetchData(var MatchesDocs) async {
    final data = await loadMatchesData(MatchesDocs);
    return Matches(list: data);
  }

  Future<List> loadMatchesData(var MatchesDocs) async {
    var list = [];
    for (var match in MatchesDocs) {
      try {
        storageReference = FirebaseStorage().ref().child('users/${match['otherUserId']}/profile_pictures/pic1.jpg');
        final imageLink = await storageReference.getDownloadURL();

        // Getting the last message sent in each conversation
        var lastMessage = await Firestore.instance
            .collection('messages')
            .document('rooms')
            .collection('${match['room']}')
            .where('time', isGreaterThanOrEqualTo: 0)
            .orderBy('time', descending: true)
            .limit(1)
            .getDocuments();
        list.add(
          {
            'key': match.documentID,
            'room': match['room'],
            'imageLink': imageLink,
            'otherUser': match['otherUser'],
            'otherUserId': match['otherUserId'],
            'last_message': lastMessage.documents[0]['message'],
            'last_message_from': lastMessage.documents[0]['from'],
            'last_message_time': lastMessage.documents[0]['time'],
          },
        );
      } catch (e) {
        print(e);
      }
    }
    return list;
  }
}
