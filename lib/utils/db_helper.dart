import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/checkin_log.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  static const _dbName = 'event_manager.db';
  static const _dbVersion = 4; // Menyesuaikan versi dengan perubahan terbaru

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabel User
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'user'
      )
    ''');

    // Tabel Event
    await db.execute(''' 
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        location TEXT NOT NULL,
        hostName TEXT NOT NULL,
        imageUrl TEXT
      )
    ''');

    // Tabel Check-In Log
    await db.execute(''' 
      CREATE TABLE checkin_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER NOT NULL,
        guest_name TEXT NOT NULL,
        checkin_time TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events(id)
      )
    ''');

    // Tabel Pembayaran
    await db.execute(''' 
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        event_id INTEGER NOT NULL,
        is_paid INTEGER DEFAULT 0,  -- 0 untuk belum bayar, 1 untuk sudah bayar
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (event_id) REFERENCES events(id)
      )
    ''');

    // Tambah static admin jika belum ada
    final existingAdmin = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['admin'],
    );

    if (existingAdmin.isEmpty) {
      await db.insert('users', {
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
      });
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint('[DEBUG] Upgrading DB from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      await db.execute("ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'user'");
    }

    if (oldVersion < 3) {
      await db.execute("ALTER TABLE events ADD COLUMN imageUrl TEXT");
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          event_id INTEGER NOT NULL,
          is_paid INTEGER DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users(id),
          FOREIGN KEY (event_id) REFERENCES events(id)
        )
      ''');
    }
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
    // Pastikan hanya kolom yang ada di tabel events yang dimasukkan
    final eventData = {
      'title': event.title,
      'description': event.description,
      'date': event.date,
      'time': event.time,
      'location': event.location,
      'hostName': event.hostName,
      'imageUrl': event.imageUrl, // Jangan masukkan 'paidUsers'
    };

    return await db.insert('events', eventData);
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
      whereArgs: [event.id!],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // ================= PAYMENTS ================

  // Memeriksa apakah pengguna sudah membayar untuk acara tertentu
  Future<bool> isPaidForEvent(int userId, int eventId) async {
    final db = await instance.database;
    final result = await db.query(
      'payments',
      where: 'user_id = ? AND event_id = ? AND is_paid = 1',
      whereArgs: [userId, eventId],
    );
    return result.isNotEmpty;
  }

  // Menambahkan pembayaran untuk acara tertentu
  Future<int> insertPayment(int userId, int eventId) async {
    final db = await instance.database;

    // Memeriksa apakah pembayaran untuk acara ini sudah ada
    final existingPayment = await db.query(
      'payments',
      where: 'user_id = ? AND event_id = ?',
      whereArgs: [userId, eventId],
    );

    // Jika sudah ada, kita tidak menambahkannya lagi
    if (existingPayment.isNotEmpty) {
      return 0; // Tidak ada yang perlu dilakukan
    }

    // Jika belum ada, tambahkan pembayaran baru
    return await db.insert('payments', {
      'user_id': userId,
      'event_id': eventId,
      'is_paid': 1, // Tandai sebagai sudah bayar
    });
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

  Future<List<CheckInLog>> getAllLogs() async {
    final db = await instance.database;
    final result = await db.query('checkin_logs');
    return result.map((map) => CheckInLog.fromMap(map)).toList();
  }

  Future<int> deleteCheckInLog(int logId) async {
    final db = await instance.database;
    return await db.delete('checkin_logs', where: 'id = ?', whereArgs: [logId]);
  }

  // ================= DEBUG =================
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
    debugPrint('[DEBUG] Database deleted successfully');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
