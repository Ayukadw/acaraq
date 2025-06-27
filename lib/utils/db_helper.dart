import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/checkin_log.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('event_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // User Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Event Table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        date TEXT,
        time TEXT,
        location TEXT,
        hostName TEXT,
        notes TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');

    // Check-In Log Table
    await db.execute('''
      CREATE TABLE checkin_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER,
        guest_name TEXT,
        checkin_time TEXT,
        FOREIGN KEY (event_id) REFERENCES events(id)
      )
    ''');
  }

  // ================= USER =================
  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // ================= EVENT =================
  Future<int> insertEvent(Event event) async {
    final db = await instance.database;
    return await db.insert('events', event.toMap());
  }

  Future<List<Event>> getAllEvents() async {
    final db = await instance.database;
    final result = await db.query('events');
    return result.map((map) => Event.fromMap(map)).toList();
  }

  Future<int> updateEvent(Event event) async {
    final db = await instance.database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= CHECK-IN LOG =================
  Future<int> insertCheckIn(CheckInLog log) async {
    final db = await instance.database;
    return await db.insert('checkin_logs', log.toMap());
  }

  Future<List<CheckInLog>> getLogsByEvent(int eventId) async {
    final db = await instance.database;
    final result = await db.query(
      'checkin_logs',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return result.map((map) => CheckInLog.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}