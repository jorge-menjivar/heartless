import 'package:firebase_storage/firebase_storage.dart';
import 'package:lise/utils/database.dart';
import 'package:sqflite/sqflite.dart';
import 'models/matches_model.dart';

abstract class MatchesData {
  Future<Matches> fetchData(Database db, var matchesDocs);
  Future<Matches> updateData(Database db, var matchesList);
}

class MatchesRepository implements MatchesData {
  @override
  Future<Matches> fetchData(Database db, var matchesDocs) async {
    final data = await loadMatchesData(db, matchesDocs);
    return Matches(list: data);
  }

  @override
  Future<Matches> updateData(Database db, var matchesList) async {
    final data = await updateMatchesData(db, matchesList);
    return Matches(list: data);
  }

  Future<List> loadMatchesData(Database db, var matchesDocs) async {
    var list = [];
    for (var match in matchesDocs) {
      try {
        var storageReference =
            FirebaseStorage().ref().child('users/${match['otherUserAlias']}/profile_pictures/pic1.jpg');
        final imageLink = await storageReference.getDownloadURL();
        var sqlRoom = '`' + match['room'] + '`';
        var messagesList = await db.rawQuery('SELECT * FROM $sqlRoom ORDER BY ${Message.db_sTime} DESC');

        var lastMessage = messagesList[0];
        var values = {
          'key': match.documentID,
          'room': match['room'],
          'imageLink': imageLink,
          'otherUser': match['otherUser'],
          'otherUserId': match['otherUserId'],
          'otherUserAlias': match['otherUserAlias'],
          'last_message': lastMessage['message'],
          'last_message_from': lastMessage['birth'],
          'last_message_time': int.parse(lastMessage['sTime']),
        };
        list.add(values);
      } catch (e) {
        print(e);
      }
    }
    return list;
  }

  Future<List> updateMatchesData(Database db, var matchesList) async {
    var list = [];
    for (var match in matchesList) {
      try {
        var storageReference =
            FirebaseStorage().ref().child('users/${match['otherUserAlias']}/profile_pictures/pic1.jpg');
        final imageLink = await storageReference.getDownloadURL();
        var sqlRoom = '`' + match['room'] + '`';
        var messagesList = await db.rawQuery('SELECT * FROM $sqlRoom ORDER BY ${Message.db_sTime} DESC');

        var lastMessage = messagesList[0];
        var values = {
          'key': match['key'],
          'room': match['room'],
          'imageLink': imageLink,
          'otherUser': match['otherUser'],
          'otherUserId': match['otherUserId'],
          'otherUserAlias': match['otherUserAlias'],
          'last_message': lastMessage['message'],
          'last_message_from': lastMessage['birth'],
          'last_message_time': int.parse(lastMessage['sTime']),
        };
        list.add(values);
      } catch (e) {
        print(e);
      }
    }
    return list;
  }
}
