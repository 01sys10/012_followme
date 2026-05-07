import 'package:sqflite/sqflite.dart';
import '../models/diary_entry.dart';

class DiaryDatabase {
  DiaryDatabase._();

  static const _dbName = 'followme.db';
  static const _table = 'diary_entries';

  static Database? _db;

  static Future<Database> get _instance async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      '$dir/$_dbName',
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          text      TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      '''),
    );
  }

  static Future<int> insert(DiaryEntry entry) async {
    final db = await _instance;
    return db.insert(_table, entry.toMap());
  }

  static Future<List<DiaryEntry>> getAll() async {
    final db = await _instance;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(DiaryEntry.fromMap).toList();
  }

  static Future<void> delete(int id) async {
    final db = await _instance;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
