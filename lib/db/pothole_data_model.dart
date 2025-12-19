import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pothole_detection_app/model/potholes.dart';
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
  static Future<List<PotholeEvent>> getAllPotholes() async {
    final db = await instance.database;
    final result = await db.query('potholes', orderBy: 'timestamp DESC');
    return result.map((e) => PotholeEvent.fromMap(e)).toList();
  }

  // CLEAR (optional)
  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('potholes');
  }

  // BULK DELETE WITH IMAGES
  Future<int> deletePotholesByIds(List<int> ids) async {
    if (ids.isEmpty) return 0;

    final db = await instance.database;
    final placeholders = List.filled(ids.length, '?').join(',');

    try {
      return await db.transaction<int>((txn) async {
        // 1️⃣ Fetch image paths inside transaction
        final result = await txn.query(
          'potholes',
          columns: ['id', 'image_path'],
          where: 'id IN ($placeholders)',
          whereArgs: ids,
        );

        // 2️⃣ Delete image files (outside DB but before commit)
        for (final row in result) {
          final imagePath = row['image_path'] as String?;
          if (imagePath != null && imagePath.isNotEmpty) {
            final file = File(imagePath);
            if (await file.exists()) {
              await file.delete();
            }
          }
        }

        // 3️⃣ Batch delete DB rows
        final batch = txn.batch();
        batch.delete(
          'potholes',
          where: 'id IN ($placeholders)',
          whereArgs: ids,
        );

        final results = await batch.commit();

        // Number of deleted rows
        return results.isNotEmpty && results.first is int
            ? results.first as int
            : ids.length;
      });
    } catch (e, stack) {
      // 🔴 Transaction auto-rollbacks DB changes on exception
      debugPrint('❌ Delete potholes failed: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
