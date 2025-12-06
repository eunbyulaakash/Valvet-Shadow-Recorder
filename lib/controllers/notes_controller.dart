import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/database_service.dart';

class NotesController extends ChangeNotifier {
  final DatabaseService db;

  NotesController({required this.db}) {
    fetchNotes();
  }

  List<Note> _notes = [];
  bool _loading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _loading;

  Future<void> fetchNotes() async {
    _loading = true;
    notifyListeners();
    _notes = await db.getNotes();
    _loading = false;
    notifyListeners();
  }

  Future<void> saveNote(Note note) async {
    if (note.id == null) {
      final now = DateTime.now();
      note.createdAt = now;
      note.updatedAt = now;
      final id = await db.insertNote(note);
      note.id = id;
      _notes.insert(0, note);
    } else {
      note.updatedAt = DateTime.now();
      await db.updateNote(note);
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
      }
    }
    notifyListeners();
  }

  Future<void> deleteNote(Note note) async {
    if (note.id != null) {
      await db.deleteNote(note.id!);
      _notes.removeWhere((n) => n.id == note.id);
      notifyListeners();
    }
  }
}