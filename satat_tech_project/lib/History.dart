import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Future<Database> setDatabase() async {
      var dict = await getApplicationDocumentsDirectory();
      
      var path = join(dict.path, "MyDatabase");
      

      var database = await openDatabase(path, version: 1, onCreate: createTable);
      return database;
    }

  

  Future<void> createTable(Database database, int version) async {
      String? sql;
      sql = "CREATE TABLE History(id INTEGER PRIMARY KEY AUTOINCREMENT, adder1 TEXT, adder2 TEXT, result TEXT)";
      await database.execute(sql);
    }
  

  Future<void> insertHistory(String adder1, String adder2, String result) async {
    Database db = await setDatabase();
    await db.insert(
      'History',
      {'adder1': adder1, 'adder2': adder2, 'result': result}
    );
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    Database db = await setDatabase();
    return await db.query('History', orderBy: "id DESC");
  }
}