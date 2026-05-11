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

  /// 특정 날짜의 일기 목록 (YYYY-MM-DD 기준)
  static Future<List<DiaryEntry>> getByDate(DateTime date) async {
    final db = await _instance;
    final prefix =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final rows = await db.query(
      _table,
      where: 'created_at LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'created_at ASC',
    );
    return rows.map(DiaryEntry.fromMap).toList();
  }

  /// 일기가 존재하는 날짜 집합 ("yyyy-MM-dd" 형식)
  static Future<Set<String>> getWrittenDates() async {
    final db = await _instance;
    final rows = await db.rawQuery(
      'SELECT SUBSTR(created_at, 1, 10) AS d FROM $_table GROUP BY d',
    );
    return rows.map((r) => r['d'] as String).toSet();
  }
}
