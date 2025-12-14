import 'dart:io';
import 'package:path/path.dart';
import 'package:pothole_detection_app/db/potholes.dart';
import 'package:sqflite/sqflite.dart';

class PotholeDatabase {
  static final PotholeDatabase instance = PotholeDatabase._init();
  static Database? _database;

  PotholeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('potholes.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE potholes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        speed_kmh REAL NOT NULL,
        severity INTEGER NOT NULL,
        image_path TEXT,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // INSERT
  Future<int> insertPothole(PotholeEvent event) async {
    final db = await instance.database;
    return await db.insert('potholes', event.toMap());
  }

  // READ ALL
  Future<List<PotholeEvent>> getAllPotholes() async {
    final db = await instance.database;
    final result = await db.query('potholes', orderBy: 'timestamp DESC');
    return result.map((e) => PotholeEvent.fromMap(e)).toList();
  }

  // CLEAR (optional)
  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('potholes');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
