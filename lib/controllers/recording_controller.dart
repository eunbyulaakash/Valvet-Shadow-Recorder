import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../models/recording_item.dart';
import '../services/database_service.dart';
import '../services/foreground_recording_task.dart';

class RecordingController extends ChangeNotifier {
  final DatabaseService db;

  final AudioRecorder _recorder = AudioRecorder();

  RecordingController({required this.db}) {
    _loadRecordings();
  }

  List<RecordingItem> _recordings = [];
  bool _audioRecordingActive = false;
  bool _videoRecordingActive = false;
  RecordingType _currentType = RecordingType.audio;

  List<RecordingItem> get recordings => _recordings;
  bool get isAudioRecording => _audioRecordingActive;
  bool get isVideoRecording => _videoRecordingActive;
  bool get isAnyRecording => _audioRecordingActive || _videoRecordingActive;
  RecordingType get currentType => _currentType;

  RecordingType? get currentActiveType {
    if (_audioRecordingActive) return RecordingType.audio;
    if (_videoRecordingActive) return RecordingType.video;
    return null;
  }

  Future<void> _loadRecordings() async {
    _recordings = await db.getRecordings();
    notifyListeners();
  }

  void setType(RecordingType type) {
    _currentType = type;
    notifyListeners();
  }

  Future<bool> _ensureAudioPermission() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      return false;
    }

    final pluginOk = await _recorder.hasPermission();
    return pluginOk;
  }

  Future<void> _startForegroundServiceForAudio() async {
    try {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Velvet Recorder',
        notificationText: 'Audio recording in progress',
        callback: foregroundRecordingStartCallback,
      );
    } catch (e, st) {
      debugPrint('Error starting foreground service: $e\n$st');
    }
  }

  Future<void> _stopForegroundServiceForAudio() async {
    await FlutterForegroundTask.stopService();
  }

  Future<bool> startAudioRecording() async {
    if (_audioRecordingActive) return true;

    final ok = await _ensureAudioPermission();
    if (!ok) return false;

    final dir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(p.join(dir.path, 'recordings'));
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    final fileName =
        'audio_${DateTime.now().millisecondsSinceEpoch.toString()}.m4a';
    final filePath = p.join(recordingsDir.path, fileName);

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );

    await _recorder.start(config, path: filePath);
    await _startForegroundServiceForAudio();

    _audioRecordingActive = true;
    _currentType = RecordingType.audio;
    notifyListeners();
    return true;
  }

  Future<void> stopAudioRecording() async {
    if (!_audioRecordingActive) return;

    final path = await _recorder.stop();
    await _stopForegroundServiceForAudio();

    _audioRecordingActive = false;

    if (path != null) {
      final item = RecordingItem(
        type: RecordingType.audio,
        filePath: path,
        durationSeconds: null,
        createdAt: DateTime.now(),
      );
      final id = await db.insertRecording(item);
      item.id = id;
      _recordings.insert(0, item);
    }
    notifyListeners();
  }

  void setVideoRecordingActive(bool active) {
    _videoRecordingActive = active;
    if (active) {
      _currentType = RecordingType.video;
    }
    notifyListeners();
  }

  Future<void> addRecording(RecordingItem item) async {
    final id = await db.insertRecording(item);
    item.id = id;
    _recordings.insert(0, item);
    notifyListeners();
  }

  Future<void> deleteRecording(RecordingItem item) async {
    if (item.id != null) {
      await db.deleteRecording(item.id!);
    }
    final file = File(item.filePath);
    if (await file.exists()) {
      await file.delete();
    }
    _recordings.removeWhere((r) => r.id == item.id);
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}