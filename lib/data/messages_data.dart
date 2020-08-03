import 'package:lise/utils/database.dart';
import 'package:sqflite/sqflite.dart';

import 'models/messages_model.dart';

abstract class MessagesData {
  Future<Messages> fetchData(Database db, String room, {int limit});
}

class MessagesRepository implements MessagesData {
  var storageReference;

  @override
  Future<Messages> fetchData(Database db, String room, {int limit}) async {
    var data;
    if (limit == null || limit < 1) {
      data = await loadAllMessagesData(db, room);
    } else if (limit > 0) {
      data = await loadPartialMessagesData(db, room, limit);
    }
    return Messages(list: data);
  }

  Future<List> loadAllMessagesData(Database db, String room) async {
    return await db.rawQuery('SELECT * FROM $room ORDER BY ${Message.db_sTime} DESC');
  }

  Future<List> loadPartialMessagesData(Database db, String room, int limit) async {
    return await db.rawQuery('SELECT * FROM $room ORDER BY ${Message.db_sTime} DESC LIMIT $limit');
  }
}
