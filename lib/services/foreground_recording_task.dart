import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void foregroundRecordingStartCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundRecordingTaskHandler());
}

class ForegroundRecordingTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Initialize if needed
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // We currently don't need periodic logic.
    // You can update notification text here if desired.
    // await FlutterForegroundTask.updateService(
    //   notificationTitle: 'Velvet Recorder',
    //   notificationText: 'Audio recording is active',
    // );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // Cleanup if needed
  }

  @override
  void onNotificationPressed() {
    // Bring app to foreground when user taps notification
    FlutterForegroundTask.launchApp();
  }
}