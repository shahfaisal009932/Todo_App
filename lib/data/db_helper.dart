import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._();
  static DbHelper getInstance() => DbHelper._();
  Future<Database>? mDB;

  static const TABLE_NAME = "todo";
  static const COLUMN_ID = "t_id";
  static const COLUMN_TITLE = "t_title";
  static const COLUMN_DESC = "t_desc";
  static const COLUMN_CREATED_AT = "t_created_at";
  static const PRIORITY = "t_priority";
  static const IS_COMPLETED = "t_isCompleted";

  Future<Database> initDb() async {
    mDB ??= openDB();
    return mDB!;
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "create table $TABLE_NAME($COLUMN_ID integer primary key autoincrement, $COLUMN_TITLE text, $COLUMN_DESC text, $COLUMN_CREATED_AT text, $PRIORITY text, $IS_COMPLETED integer default 0) ",
        );
      },
    );
  }

  //Query

  //Add
  Future<bool> addNote({
    required String title,
    required String desc,
    required String priority,
  }) async {
    var db = await initDb();
    int rowsEffected = await db.insert(TABLE_NAME, {
      COLUMN_TITLE: title,
      COLUMN_DESC: desc,
      COLUMN_CREATED_AT: DateTime.now().millisecondsSinceEpoch.toString(),
      PRIORITY: priority,
      IS_COMPLETED: 0,
    });
    return rowsEffected > 0;
  }

  //Update
  Future<bool> updateNote({
    required int ID,
    required String title,
    required String desc,
    required String priority,
    required int isCompleted,
  }) async {
    var db = await initDb();
    int rowsEffected = await db.update(
      TABLE_NAME,
      {
        COLUMN_TITLE: title,
        COLUMN_DESC: desc,
        PRIORITY: priority,
        IS_COMPLETED: isCompleted,
      },
      where: "$COLUMN_ID =?",
      whereArgs: [ID],
    );
    return rowsEffected > 0;
  }

  Future<bool> updateCompleted({
    required int ID,
    required int isCompleted,
  }) async {
    var db = await initDb();
    int rowsEffected = await db.update(
      TABLE_NAME,
      {IS_COMPLETED: isCompleted},
      where: "$COLUMN_ID =?",
      whereArgs: [ID],
    );
    return rowsEffected > 0;
  }

  //Delete
  Future<bool> deleteNote({required int ID}) async {
    var db = await initDb();
    int rowsEffected = await db.delete(
      TABLE_NAME,
      where: "$COLUMN_ID = ?",
      whereArgs: [ID],
    );
    return rowsEffected > 0;
  }

  //Fetch
  Future<List<Map<String, dynamic>>> fetchNote({String query = ""}) async {
    var db = await initDb();
    if (query.isEmpty) {
      return await db.query(TABLE_NAME);
    } else {
      return await db.query(
        TABLE_NAME,
        where: "$COLUMN_TITLE LIKE ? OR $COLUMN_DESC LIKE ?",
        whereArgs: ["%$query%", "%$query%"],
      );
    }
  }

  //Search
  Future<List<Map<String, dynamic>>> searchNote() async {
    var db = await initDb();
    List<Map<String, dynamic>> allData = await db.query(
      TABLE_NAME,
      where: "$COLUMN_TITLE = ?",
      whereArgs: ["updated Note"],
    );
    return allData;
  }
}
//