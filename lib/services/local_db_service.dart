import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hitera_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        data_id TEXT NOT NULL,
        data_payload TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE tugas (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        judul TEXT,
        deskripsi TEXT,
        prioritas TEXT,
        status TEXT,
        tanggal_target TEXT,
        deadline TEXT,
        waktu_deadline TEXT,
        tanggal_selesai TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE keuangan (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        jenis TEXT,
        jumlah REAL,
        kategori TEXT,
        deskripsi TEXT,
        tanggal TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE kesehatan (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        tanggal TEXT,
        air_minum INTEGER,
        jam_tidur REAL,
        olahraga_jam INTEGER,
        olahraga_menit INTEGER,
        catatan TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');
  }
}
