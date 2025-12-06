import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/notes_controller.dart';
import '../controllers/recording_controller.dart';
import '../widgets/note_card.dart';
import '../widgets/recording_indicator.dart';
import 'edit_note_screen.dart';
import 'recorder_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  int _tapCount = 0;
  DateTime? _firstTapTime;
  static const Duration _gestureWindow = Duration(milliseconds: 1200);

  void _handleSecretTap() {
    final now = DateTime.now();

    if (_firstTapTime == null ||
        now.difference(_firstTapTime!) > _gestureWindow) {
      _firstTapTime = now;
      _tapCount = 1;
    } else {
      _tapCount += 1;
    }

    if (_tapCount >= 5) {
      _tapCount = 0;
      _firstTapTime = null;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RecorderScreen()),
      );
    }
  }

  void _openEditor([note]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditNoteScreen(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesController = context.watch<NotesController>();
    final recordingController = context.watch<RecordingController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Velvet Notes'),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.favorite,
              color: Color(0xFFE91E63),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleSecretTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF101018),
                Color(0xFF1C1020),
                Color(0xFF201024),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Soft heart pattern in the background
              Positioned(
                top: -20,
                right: -10,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(
                    Icons.favorite,
                    size: 160,
                    color: Colors.pinkAccent.shade100,
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -10,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(
                    Icons.favorite,
                    size: 200,
                    color: Colors.pink.shade200,
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                right: 40,
                child: Opacity(
                  opacity: 0.04,
                  child: Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.redAccent.shade100,
                  ),
                ),
              ),
              Column(
                children: [
                  if (recordingController.isAnyRecording &&
                      recordingController.currentActiveType != null)
                    RecordingIndicator(
                      type: recordingController.currentActiveType!,
                    ),
                  Expanded(
                    child: notesController.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : notesController.notes.isEmpty
                        ? const Center(
                      child: Text(
                        'No notes yet.\nTap + to add a note.',
                        textAlign: TextAlign.center,
                      ),
                    )
                        : ListView.builder(
                      itemCount: notesController.notes.length,
                      itemBuilder: (context, index) {
                        final note = notesController.notes[index];
                        return NoteCard(
                          note: note,
                          onTap: () => _openEditor(note),
                          onDelete: () =>
                              notesController.deleteNote(note),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}