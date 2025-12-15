import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RoadSensorDB {
  static Database? _db;

  static const _dbName = 'road_sensor.db';
  static const _tableName = 'imu_data';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await _createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTable(db);
        }
      },
    );
  }

  static Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp_us INTEGER,
        accel_x REAL,
        accel_y REAL,
        accel_z REAL,
        gyro_x REAL,
        gyro_y REAL,
        gyro_z REAL,
        latitude REAL,
        longitude REAL,
        speed REAL
      )
    ''');
  }

  static Future<void> insertBatch(List<Map<String, dynamic>> rows) async {
    final db = await database;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(_tableName, row);
    }
    await batch.commit(noResult: true);
  }
}
