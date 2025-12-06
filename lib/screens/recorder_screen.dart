import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../controllers/recording_controller.dart';
import '../models/recording_item.dart';
import '../services/database_service.dart';
import '../widgets/recording_list_tile.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;
  bool _initializingCamera = false;
  bool _videoRecording = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _ensureVideoPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (!statuses[Permission.camera]!.isGranted ||
        !statuses[Permission.microphone]!.isGranted) {
      return false;
    }
    return true;
  }

  Future<void> _initCameraIfNeeded() async {
    if (_cameraController != null) return;
    setState(() {
      _initializingCamera = true;
    });

    try {
      final cams = await availableCameras();
      final back = cams.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      _cameraController = controller;
      _initializeCameraFuture = controller.initialize();
      await _initializeCameraFuture;
    } finally {
      if (mounted) {
        setState(() {
          _initializingCamera = false;
        });
      }
    }
  }

  Future<void> _startAudioRecording(
      RecordingController controller,
      ) async {
    final ok = await controller.startAudioRecording();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    // Immediately go back to notes screen while audio continues
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _stopAudioRecording(
      RecordingController controller,
      ) async {
    await controller.stopAudioRecording();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio recording saved')),
    );
  }

  Future<void> _startVideoRecording(
      RecordingController controller,
      ) async {
    if (_videoRecording) return;

    final permOk = await _ensureVideoPermissions();
    if (!permOk) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera or mic permission denied')),
      );
      return;
    }

    await _initCameraIfNeeded();
    if (_cameraController == null) return;

    await _initializeCameraFuture;
    await _cameraController!.startVideoRecording();
    setState(() {
      _videoRecording = true;
    });
    controller.setVideoRecordingActive(true);
  }

  Future<void> _stopVideoRecording(
      RecordingController controller,
      DatabaseService db,
      ) async {
    if (!_videoRecording || _cameraController == null) return;

    final xFile = await _cameraController!.stopVideoRecording();
    setState(() {
      _videoRecording = false;
    });
    controller.setVideoRecordingActive(false);

    final dir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(p.join(dir.path, 'recordings'));
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    final newPath = p.join(
      recordingsDir.path,
      'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );
    final file = File(xFile.path);
    await file.copy(newPath);
    await file.delete();

    final item = RecordingItem(
      type: RecordingType.video,
      filePath: newPath,
      durationSeconds: null,
      createdAt: DateTime.now(),
    );
    await controller.addRecording(item);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video recording saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordingController = context.watch<RecordingController>();
    final db = context.read<DatabaseService>();

    final isAudioRecording = recordingController.isAudioRecording;
    final anyRecording = recordingController.isAnyRecording;
    final isVideoSelected =
        recordingController.currentType == RecordingType.video;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recorder'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050510),
              Color(0xFF0B0B1A),
              Color(0xFF141428),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ghost-like background silhouettes
            Positioned(
              top: -40,
              left: -20,
              child: Opacity(
                opacity: 0.09,
                child: Icon(
                  Icons.emoji_objects, // stylized "ghostly" bulb
                  size: 200,
                  color: Colors.blueGrey.shade300,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -10,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.nightlight_round,
                  size: 220,
                  color: Colors.indigo.shade200,
                ),
              ),
            ),
            Positioned(
              bottom: 140,
              left: 40,
              child: Opacity(
                opacity: 0.06,
                child: Icon(
                  Icons.visibility,
                  size: 80,
                  color: Colors.white70,
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 12),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(24),
                  isSelected: [
                    recordingController.currentType == RecordingType.audio,
                    recordingController.currentType == RecordingType.video,
                  ],
                  onPressed: (index) async {
                    if (anyRecording) return; // do not switch mid-recording
                    if (index == 0) {
                      recordingController.setType(RecordingType.audio);
                    } else {
                      recordingController.setType(RecordingType.video);
                      await _initCameraIfNeeded();
                    }
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Audio'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Video'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isVideoSelected)
                  Expanded(
                    child: _initializingCamera
                        ? const Center(child: CircularProgressIndicator())
                        : _cameraController == null
                        ? const Center(
                      child: Text('Camera not available'),
                    )
                        : FutureBuilder(
                      future: _initializeCameraFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return Stack(
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: _cameraController!
                                    .value.aspectRatio,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                            if (_videoRecording)
                              const Positioned(
                                top: 16,
                                right: 16,
                                child: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Colors.red,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  )
                else
                  const Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: Text(
                      'Start audio recording, the app will switch back to notes while recording continues.\n\n'
                          'Come back here (secret taps) to stop.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      anyRecording ? Colors.redAccent : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    icon: Icon(
                        anyRecording ? Icons.stop : Icons.fiber_manual_record),
                    label: Text(
                      anyRecording ? 'Stop Recording' : 'Start Recording',
                      style: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () async {
                      if (!anyRecording) {
                        if (recordingController.currentType ==
                            RecordingType.audio) {
                          await _startAudioRecording(recordingController);
                        } else {
                          await _startVideoRecording(recordingController);
                        }
                      } else {
                        if (isAudioRecording) {
                          await _stopAudioRecording(recordingController);
                        } else if (recordingController.isVideoRecording) {
                          await _stopVideoRecording(
                            recordingController,
                            db,
                          );
                        }
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: recordingController.recordings.isEmpty
                      ? const Center(
                    child: Text(
                      'No recordings yet.',
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    itemCount: recordingController.recordings.length,
                    itemBuilder: (context, index) {
                      final item =
                      recordingController.recordings[index];
                      return RecordingListTile(
                        item: item,
                        onDelete: () =>
                            recordingController.deleteRecording(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}