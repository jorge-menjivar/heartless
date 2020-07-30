import 'package:lise/utils/database.dart';
import 'package:sqflite/sqflite.dart';

import 'models/messages_model.dart';

abstract class MessagesData {
  Future<Messages> fetchData(Database db, String room);
}

class MessagesRepository implements MessagesData {
  var storageReference;

  @override
  Future<Messages> fetchData(Database db, String room) async {
    final data = await loadMessagesData(db, room);
    return Messages(list: data);
  }

  Future<List> loadMessagesData(Database db, String room) async {
    return await db.rawQuery('SELECT * FROM $room ORDER BY ${Message.db_sTime} DESC');
  }
}
