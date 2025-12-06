import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'services/database_service.dart';
import 'controllers/notes_controller.dart';
import 'controllers/recording_controller.dart';
import 'screens/notes_screen.dart';
import 'services/foreground_recording_task.dart';

/// Initialize the foreground task system.
/// In your version of flutter_foreground_task this is a synchronous call (returns void).
void _initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'velvet_recorder_channel',
      channelName: 'Velvet Recorder',
      channelDescription: 'Shows when audio recording is running',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
      eventAction: ForegroundTaskEventAction.repeat(5000),
    ),
    // IMPORTANT: do NOT pass printDevLog here since your version doesn't support it
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Synchronous init (no await, no assignment of its result)
  _initForegroundTask();

  final db = await DatabaseService.init();

  runApp(
    // DO NOT make this const – WithForegroundTask is not a const constructor
    WithForegroundTask(
      child: MultiProvider(
        providers: [
          Provider<DatabaseService>.value(value: db),
          ChangeNotifierProvider(
            create: (_) => NotesController(db: db),
          ),
          ChangeNotifierProvider(
            create: (_) => RecordingController(db: db),
          ),
        ],
        child: const VelvetRecorderApp(),
      ),
    ),
  );
}

class VelvetRecorderApp extends StatelessWidget {
  const VelvetRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velvet Recorder',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      home: const NotesScreen(),
    );
  }
}