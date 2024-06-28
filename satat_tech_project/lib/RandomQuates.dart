import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

  class DatabaseConnection {
    
    //Database Connection
    Future<Database> setDatabase() async {
      var dict = await getApplicationDocumentsDirectory();
      
      var path = join(dict.path, "Database");
      

      var database = await openDatabase(path, version: 1, onCreate: createTable);
      return database;
    }

    //Database Creation and Table Creation
    Future<void> createTable(Database database, int version) async {
      String? sql;
      sql =
          "create table Quote(id INTEGER PRIMARY KEY AUTOINCREMENT, quotes TEXT , Date TEXT)";
      await database.execute(sql);
    }

    //Get Daily Quotes
    Future<String?> getQuoteByDate(String date) async {
      Database db = await setDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        'Quote',
        where: 'Date = ?',
        whereArgs: [date],
      );

      if (maps.isNotEmpty) {
        return maps.first['quotes'];
      } else {
        return null;
      }
    }

    //Inser new quate of the day
    Future<void> insertQuote(String quote, String date) async {
      final db = await setDatabase();
      await db.insert(
        'Quote',
        {'quotes': quote, 'Date': date},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    //Fetch NEw Quote
    Future<String> fetchQuote() async {
    final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse[0]['q'] + " - " + jsonResponse[0]['a'];
    } else {
      throw Exception('Failed to load quote');
    }
  }



}

//Main Call Function T Get Quote
Future<String> getDailyQuote() async {
  final dbHelper = DatabaseConnection();
  DateTime now = DateTime.now();
  String today = DateFormat('yyyy-MM-dd').format(now); // Format the date

  String? quote = await dbHelper.getQuoteByDate(today);

  if (quote != null) {
    return quote;
  } else {
    
    quote = await dbHelper.fetchQuote();
    await dbHelper.insertQuote(quote, today);
    return quote;
  }
}

  