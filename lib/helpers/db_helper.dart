import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database(table) async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'places.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE $table(id INTEGER PRIMARY KEY AUTOINCREMENT, remark TEXT)');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database(table);
    db.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getLocalRemarks(
      String table) async {
    final db = await DBHelper.database(table);
    return db.query(table);
  }

  static Future<void> delete(String table, int id) async {
    final db = await DBHelper.database(table);
    db.rawDelete('DELETE FROM $table WHERE id=$id');
  }
}
