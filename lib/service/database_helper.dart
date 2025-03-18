import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:text_to_image/models/image_model.dart';

class DatabaseHelper {
  static Database? _database;
  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    final path = await getDatabasesPath();
    final dbPath = '${path}generated_images.db';
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prompt TEXT NOT NULL,
            image BLOB NOT NULL
          )
        ''');
      },
    );
  }

  static Future<int> insertImage(String prompt, Uint8List imageBytes) async {
    final db = await database;
    return db.insert('images', {'prompt': prompt, 'image': imageBytes});
  }

  static Future<List<ImageModel>> getImages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('images', orderBy: 'id DESC');
    return maps.map((map) => ImageModel.fromMap(map)).toList();
  }

  static Future<int> deleteImage(int id) async {
    final db = await database;
    return db.delete('images', where: 'id = ?', whereArgs: [id]);
  }
}
