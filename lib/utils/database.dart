import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future addToDb(Database db, String room, Map values) async {
  var sqlRoom = '`' + room + '`';
  await db.insert(sqlRoom, values);
}

Future<Database> getMessagesDb() async {
  // Get a location using path_provider
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, 'convos', 'messages');
  return await openDatabase(
    path,
    version: 1,
  );
}

Future<void> checkMessageTable(Database db, String room) async {
  var sqlRoom = '`' + room + '`';
  await db.execute("CREATE TABLE IF NOT EXISTS $sqlRoom ("
      "${Message.db_sTime} TEXT PRIMARY KEY, "
      "${Message.db_message} TEXT, "
      "${Message.db_image} NUMERIC, "
      "${Message.db_from} TEXT "
      ")");
}

Future<void> dropTable(Database db, String room) async {
  var sqlRoom = '`' + room + '`';
  await db.execute("DROP TABLE IF EXISTS $sqlRoom");
}

class Message {
  static final db_sTime = "sTime";
  static final db_message = "message";
  static final db_image = "image";
  static final db_from = "birth";

  String sTime, message, image, from;

  Message({
    @required this.sTime,
    @required this.message,
    @required this.image,
    @required this.from,
  });

  Message.fromMap(Map<String, dynamic> map)
      : this(
          sTime: map[db_sTime],
          message: map[db_message],
          image: map[db_image],
          from: map[db_from],
        );

  // Currently not used
  static Map<String, dynamic> toMap(map) => {
        db_sTime: map.sTime,
        db_message: map.message,
        db_image: map.image,
        db_from: map.from,
      };
}
