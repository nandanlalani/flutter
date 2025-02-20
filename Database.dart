import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabase {
  static final MyDatabase instance = MyDatabase._init();
  static Database? _database;

  MyDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'darshanMatrimony.db');
    print("Database Path: $path");
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE Users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_firstName TEXT NOT NULL,
        user_lastName TEXT NOT NULL,
        user_Name TEXT NOT NULL UNIQUE,
        user_email TEXT NOT NULL UNIQUE,
        user_number TEXT CHECK(length(user_number) = 10),
        dob DATE NOT NULL,
        city TEXT NOT NULL,
        gender TEXT NOT NULL,
        password TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE Hobbies (
        hobby_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        hobby TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES Users (user_id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('Users', user);
  }

  Future<int> updateUser(int userId, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update('Users', user, where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete('Users', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('Users');
  }

  Future<List<Map<String, Object?>>> getAllUsername() async {
    final db = await database;
    return await db.rawQuery('Select user_Name from Users');
  }

  Future<List<Map<String, dynamic>>> getHobbiesByUser(int userId) async {
    final db = await database;
    return await db.query('Hobbies', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> insertHobby(Map<String, dynamic> hobby) async {
    final db = await database;
    return await db.insert('Hobbies', hobby);
  }
}
