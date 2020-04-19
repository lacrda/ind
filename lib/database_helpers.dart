import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
final String tableInd = 'words';
final String columnId = '_id';
final String columnName = 'name';
final String columnUrl = 'url';
final String columnType = 'type';
final String columnInfo = 'info';

// data model class
class Ind {
  int id;
  String name;
  String url;
  String type;
  String info;

  Ind();

  // convenience constructor to create a Word object
  Ind.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    url = map[columnUrl];
    type = map[columnType];
    info = map[columnInfo];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnUrl: url,
      columnType: type,
      columnInfo: info,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "MyDatabase.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableInd (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnUrl TEXT,
                $columnType TEXT,
                $columnInfo TEXT
              )
              ''');
  }

  // Database helper methods:

  Future<int> insert(Ind item) async {
    Database db = await database;
    int id = await db.insert(tableInd, item.toMap());
    return id;
  }

  Future<Ind> queryWord(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableInd,
        columns: [columnId, columnName, columnUrl, columnType],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Ind.fromMap(maps.first);
    }
    return null;
  }

  // TODO: queryAllWords()
  Future<List<Map>> queryAllWords() async {
    Database db = await database;
    List<Map> maps = await db.query(tableInd);
    if (maps.length > 0) {
//      print(maps);
      return maps;
    }
    return null;
  }

  // TODO: delete(int id)
  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(tableInd, where: '$columnId = ?', whereArgs: [id]);
  }

  // TODO: update(Word word)
}
