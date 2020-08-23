import 'package:lise/data/models/p_matches_model.dart';
import 'package:lise/utils/database.dart';
import 'package:sqflite/sqflite.dart';

abstract class PMatchesData {
  Future<PMatches> fetchData(Database db, var pMatchesDocs);
  Future<PMatches> updateData(Database db, var pMatchesList);
}

class PMatchesRepository implements PMatchesData {
  @override
  Future<PMatches> fetchData(Database db, var pMatchesDocs) async {
    final data = await loadPMatchesData(db, pMatchesDocs);
    return PMatches(list: data);
  }

  @override
  Future<PMatches> updateData(Database db, var matchesList) async {
    final data = await updatePMatchesData(db, matchesList);
    return PMatches(list: data);
  }

  Future<List> loadPMatchesData(Database db, var pMatchesDocs) async {
    var list = [];
    for (var match in pMatchesDocs) {
      try {
        if (match['room'] != null) {
          var sqlRoom = '`' + match['room'] + '`';
          var messagesList = await db.rawQuery('SELECT * FROM $sqlRoom ORDER BY ${Message.db_sTime} DESC');
          var values;
          if (messagesList.isNotEmpty) {
            var lastMessage = messagesList[0];
            values = {
              'key': match.documentID,
              'room': match['room'],
              'otherUser': match['otherUser'],
              'last_message': lastMessage['message'],
              'last_message_from': lastMessage['birth'],
              'last_message_time': int.parse(lastMessage['sTime']),
            };
          } else if (messagesList.isEmpty) {
            values = {
              'key': match.documentID,
              'room': match['room'],
              'otherUser': match['otherUser'],
              'last_message': '',
              'last_message_from': 'empty',
              'last_message_time': 0,
            };
          }
          list.add(values);
        } else {
          var values = {
            'key': match.documentID,
            'requestID': match['requestID'],
          };
          list.add(values);
        }
      } catch (e) {
        print(e);
      }
    }
    return list;
  }

  Future<List> updatePMatchesData(Database db, var pMatchesList) async {
    var list = [];
    for (var match in pMatchesList) {
      try {
        var sqlRoom = '`' + match['room'] + '`';
        var messagesList = await db.rawQuery('SELECT * FROM $sqlRoom ORDER BY ${Message.db_sTime} DESC');
        var values;
        if (messagesList.isNotEmpty) {
          var lastMessage = messagesList[0];
          values = {
            'key': match['key'],
            'room': match['room'],
            'otherUser': match['otherUser'],
            'last_message': lastMessage['message'],
            'last_message_from': lastMessage['birth'],
            'last_message_time': int.parse(lastMessage['sTime']),
          };
        } else if (messagesList.isEmpty) {
          values = {
            'key': match['key'],
            'room': match['room'],
            'otherUser': match['otherUser'],
            'last_message': '',
            'last_message_from': 'empty',
            'last_message_time': 0,
          };
        }
        list.add(values);
      } catch (e) {
        print(e);
      }
    }
    return list;
  }
}
