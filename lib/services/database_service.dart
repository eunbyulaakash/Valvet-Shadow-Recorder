import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';
import '../models/recording_item.dart';

class DatabaseService {
  final Database _db;

  DatabaseService._(this._db);

  static Future<DatabaseService> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'velvet_recorder.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE recordings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            file_path TEXT NOT NULL,
            duration_seconds INTEGER,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );

    return DatabaseService._(db);
  }

  // NOTES

  Future<List<Note>> getNotes() async {
    final maps = await _db.query(
      'notes',
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<int> insertNote(Note note) async {
    return _db.insert('notes', note.toMap());
  }

  Future<int> updateNote(Note note) async {
    return _db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    await _db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // RECORDINGS

  Future<List<RecordingItem>> getRecordings() async {
    final maps = await _db.query(
      'recordings',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => RecordingItem.fromMap(m)).toList();
  }

  Future<int> insertRecording(RecordingItem item) async {
    return _db.insert('recordings', item.toMap());
  }

  Future<void> deleteRecording(int id) async {
    await _db.delete('recordings', where: 'id = ?', whereArgs: [id]);
  }
}