import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lise/data/models/p_matches_model.dart';

abstract class PMatchesData {
  Future<PMatches> fetchData(var pMatchesDocs);
}

class PMatchesRepository implements PMatchesData {
  var storageReference;

  @override
  Future<PMatches> fetchData(var pMatchesDocs) async {
    final data = await loadPMatchesData(pMatchesDocs);
    return PMatches(list: data);
  }

  Future<List> loadPMatchesData(var pMatchesDocs) async {
    var list = [];
    for (var match in pMatchesDocs) {
      try {
        if (match['pending'] != null) {
          list.add(
            {
              'key': match.documentID,
              'pending': match['pending'],
            },
          );
        } else {
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
              'otherUser': match['otherUser'],
              'last_message': lastMessage.documents[0]['message'],
              'last_message_from': lastMessage.documents[0]['from'],
              'last_message_time': lastMessage.documents[0]['time'],
            },
          );
        }
      } catch (e) {
        print(e);
      }
    }
    return list;
  }
}
