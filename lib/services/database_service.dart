import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/auraroute.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table for scheduled walk reminders
        await db.execute('''
          CREATE TABLE reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            scheduled_at TEXT NOT NULL,
            activity_type TEXT NOT NULL,
            mood TEXT NOT NULL,
            is_enabled INTEGER NOT NULL,
            notification_id INTEGER NOT NULL
          )
        ''');

        // Table for completed walk history
        await db.execute('''
          CREATE TABLE walk_history (
            id TEXT PRIMARY KEY,
            completed_at TEXT NOT NULL,
            distance_meters REAL NOT NULL,
            duration_seconds REAL NOT NULL,
            activity_type TEXT NOT NULL,
            mood TEXT NOT NULL,
            destination_name TEXT NOT NULL
          )
        ''');

        // Table for saved favorite routes
        await db.execute('''
          CREATE TABLE favorite_routes (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            destination_name TEXT NOT NULL,
            dest_lat REAL NOT NULL,
            dest_lon REAL NOT NULL,
            distance_meters REAL NOT NULL,
            duration_seconds REAL NOT NULL,
            mood TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // --- Reminders Database Operations ---
  Future<List<Map<String, dynamic>>> getReminders() async {
    final db = await database;
    return await db.query('reminders', orderBy: 'scheduled_at ASC');
  }

  Future<void> insertReminder(Map<String, dynamic> row) async {
    final db = await database;
    await db.insert('reminders', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateReminderStatus(String id, bool isEnabled) async {
    final db = await database;
    await db.update(
      'reminders',
      {'is_enabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // --- Walk History Database Operations ---
  Future<List<Map<String, dynamic>>> getWalkHistory() async {
    final db = await database;
    return await db.query('walk_history', orderBy: 'completed_at DESC');
  }

  Future<void> insertWalkHistory(Map<String, dynamic> row) async {
    final db = await database;
    await db.insert('walk_history', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Favorite Routes Database Operations ---
  Future<List<Map<String, dynamic>>> getFavoriteRoutes() async {
    final db = await database;
    return await db.query('favorite_routes', orderBy: 'created_at DESC');
  }

  Future<void> insertFavoriteRoute(Map<String, dynamic> row) async {
    final db = await database;
    await db.insert('favorite_routes', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteFavoriteRoute(String id) async {
    final db = await database;
    await db.delete('favorite_routes', where: 'id = ?', whereArgs: [id]);
  }
}
