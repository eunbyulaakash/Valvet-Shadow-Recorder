# Velvet Recorder (Flutter – Android)

Velvet Recorder is a Flutter app that looks like a simple notes application but includes a hidden recorder interface. Users can create and manage notes, and via a secret tap gesture access an audio/video recorder. Audio recording can continue in the background using an Android foreground service with a persistent notification.

---

## Project Structure & File Purposes

Below is an overview of the main files and what logic they implement.

---

## Root

### `pubspec.yaml`

- Declares app metadata and all dependencies.
- Key packages:
  - `provider` – state management for controllers.
  - `record` – audio recording via `AudioRecorder`.
  - `camera` – video capture and preview.
  - `sqflite` – local SQLite database for notes and recordings.
  - `path` / `path_provider` – building and obtaining file paths.
  - `permission_handler` – runtime permission requests (mic, camera).
  - `open_filex` – open recorded media files with system apps.
  - `flutter_foreground_task` – Android foreground service for stable background audio.

---

## `lib/` Entry & Theme

### `lib/main.dart`

- App entry point.
- Initializes Flutter bindings.
- Initializes `flutter_foreground_task` with:
  - Android notification options (channel, priority).
  - iOS options (for completeness, though app is Android-only).
  - Foreground task options (repeat event configuration).
- Initializes local database via `DatabaseService.init()`.
- Wraps the whole app in:
  - `WithForegroundTask` – required wrapper for `flutter_foreground_task`.
  - `MultiProvider` – injects `DatabaseService`, `NotesController`, and `RecordingController`.
- Sets `VelvetRecorderApp` as root widget:
  - Configures dark theme via `buildDarkTheme()`.
  - Sets `NotesScreen` as the home screen.

### `lib/theme.dart`

- Defines a dark Material `ThemeData` for the app:
  - Base theme: `ThemeData.dark()`.
  - Primary/secondary: pink accent (`Color(0xFFE91E63)`).
  - Custom app bar, scaffold, card, FAB, and snackbar styling.
- Central place to tweak overall look-and-feel without touching individual screens.

---

## Models (`lib/models/`)

### `lib/models/note.dart`

- Data model for a text note.
- Fields:
  - `id`, `title`, `content`, `createdAt`, `updatedAt`.
- Methods:
  - `Note.fromMap(Map<String, dynamic>)` – parse DB row into `Note`.
  - `toMap()` – convert `Note` into a map suitable for SQLite insert/update.

### `lib/models/recording_item.dart`

- Data model for a recording (audio or video).
- `enum RecordingType { audio, video }`.
- Fields:
  - `id`, `type`, `filePath`, `durationSeconds`, `createdAt`.
- Methods:
  - `RecordingItem.fromMap(Map<String, dynamic>)` – parse DB row.
  - `toMap()` – convert to SQLite-friendly map.

---

## Services (`lib/services/`)

### `lib/services/database_service.dart`

- Encapsulates all direct SQLite access.
- Uses `sqflite` to manage a single database `velvet_recorder.db`.
- On first run, creates:
  - `notes` table (id, title, content, created_at, updated_at).
  - `recordings` table (id, type, file_path, duration_seconds, created_at).
- Exposes methods:
  - `getNotes()`, `insertNote()`, `updateNote()`, `deleteNote()`.
  - `getRecordings()`, `insertRecording()`, `deleteRecording()`.

### `lib/services/foreground_recording_task.dart`

- Defines the background task handler for the Android foreground service.
- Contains the required entrypoint callback:
  - `foregroundRecordingStartCallback()` – registers `ForegroundRecordingTaskHandler` with `FlutterForegroundTask`.
  - `ForegroundRecordingTaskHandler` implements `TaskHandler`:
  - `onStart` – called when foreground service starts.
  - `onRepeatEvent` – called periodically (we currently don’t do heavy logic here).
  - `onDestroy` – cleanup hook.
  - `onNotificationPressed` – launches the app when user taps the notification.

This file is responsible for wiring the foreground service (notification + periodic callbacks) that keeps audio recording more stable when the app is backgrounded or the screen is off.

---

## Controllers (`lib/controllers/`)

### `lib/controllers/notes_controller.dart`

- `ChangeNotifier` responsible for all notes logic.
- Injected with `DatabaseService`.
- Responsibilities:
  - Load notes from DB (`fetchNotes()`).
  - Insert/update notes (`saveNote()`).
  - Delete notes (`deleteNote()`).
- Holds:
  - `_notes` list (in-memory cache).
  - `_loading` flag for UI to show loading states.
- Notifies listeners on any change so UI updates automatically.

### `lib/controllers/recording_controller.dart`

- `ChangeNotifier` responsible for all recording-related logic.
- Injected with `DatabaseService`.
- Uses:
  - `AudioRecorder` (from `record` package) for audio.
  - `FlutterForegroundTask` for managing foreground service.
- Key state:
  - `_recordings` list – all saved recordings.
  - `_audioRecordingActive` / `_videoRecordingActive` – flags for active recording.
  - `_currentType` – currently selected mode (audio/video).
- Core methods:
  - `_loadRecordings()` – initial load from DB.
  - `setType(RecordingType)` – switch between audio and video mode (when idle).
  - `_ensureAudioPermission()` – request microphone permission (via `permission_handler`).
  - `_startForegroundServiceForAudio()` / `_stopForegroundServiceForAudio()`:
    - Start/stop Android foreground service with a notification.
  - `startAudioRecording()`:
    - Ensure permissions.
    - Create a `recordings` folder in app documents directory.
    - Build file path and recording config.
    - Start `AudioRecorder`.
    - Start foreground service and mark `_audioRecordingActive = true`.
  - `stopAudioRecording()`:
    - Stop `AudioRecorder`.
    - Stop foreground service.
    - Save resulting file path into DB and in-memory list.
  - `setVideoRecordingActive(bool)` – track video recording activity state.
  - `addRecording(RecordingItem)` – save externally created recordings (e.g., video).
  - `deleteRecording(RecordingItem)` – remove from DB and delete file.
- `dispose()` disposes the `AudioRecorder` to free native resources.

---

## Screens (`lib/screens/`)

### `lib/screens/notes_screen.dart`

- Main/home screen of the app – **fake notes UI**.
- UI responsibilities:
  - AppBar titled “Velvet Notes” with heart icon action.
  - Love-themed background:
    - Dark gradient.
    - Large, faint heart icons drawn with low opacity.
  - List of notes using `NoteCard` widgets.
  - Floating action button to create a new note.
- Secret gesture:
  - Wraps the whole content in a `GestureDetector`.
  - Tracks taps and time window; when user taps 5 times quickly, navigates to `RecorderScreen`.
- Recording awareness:
  - Shows a `RecordingIndicator` banner at the top if any recording is active, with the active recording type (audio/video).

### `lib/screens/edit_note_screen.dart`

- Screen for creating or editing a note.
- Receives an optional `Note`:
  - If provided → edit mode.
  - If not → new note.
- UI:
  - AppBar title: “New Note” or “Edit Note”.
  - Check icon to save.
  - Text field for title.
  - Expanded text field for content.
- Logic:
  - On save:
    - If both title and content are empty → simply closes.
    - Otherwise creates or updates a `Note` and delegates to `NotesController.saveNote()`.

### `lib/screens/recorder_screen.dart`

- Hidden **Recorder** interface, opened only via secret taps on `NotesScreen`.
- Background theme: “ghost” style:
  - Dark gradient.
  - Faint icons (`emoji_objects`, `nightlight_round`, `visibility`) with low opacity.
- Mode toggle:
  - `ToggleButtons` for **Audio** and **Video** modes:
    - Changes `RecordingController.currentType` when idle.
- Audio mode:
  - Provides instructions:
    > Start audio recording, the app will switch back to notes while recording continues.  
    > Come back here (secret taps) to stop.
  - “Start Recording” button:
    - Calls `startAudioRecording()` in `RecordingController`.
    - On success, pops back to `NotesScreen` while recording and foreground service continue.
  - “Stop Recording” button when active:
    - Calls `stopAudioRecording()` and shows a snackbar “Audio recording saved”.
- Video mode:
  - Uses `camera` plugin:
    - `availableCameras()` to select back camera.
    - `CameraController` for preview and recording.
  - Shows live preview in an `AspectRatio`.
  - Red dot indicator overlaid while video is recording.
  - “Start Recording”:
    - Requests camera + microphone permission.
    - Starts video recording on the camera controller.
  - “Stop Recording”:
    - Stops recording and moves file into the `recordings` folder.
    - Creates a `RecordingItem` (type=video) via `RecordingController.addRecording()` and shows a snackbar.
- Bottom recordings list:
  - Uses `RecordingListTile` to show all recordings (audio + video) from the controller.
  - Allows user to delete entries via `RecordingController.deleteRecording()`.

---

## Widgets (`lib/widgets/`)

### `lib/widgets/note_card.dart`

- Presentational component for a single `Note` in the notes list.
- Shows:
  - Heart‑colored notes icon.
  - Note title (single line).
  - Content preview (2 lines).
  - Last updated date/time using `intl` formatting.
- Supports:
  - `onTap` – open for editing.
  - `onDelete` – delete note (optional trailing delete button).

### `lib/widgets/recording_indicator.dart`

- Small banner displayed at the top of `NotesScreen` when recording is active.
- Shows:
  - Red dot icon.
  - Text: `"Audio recording..."` or `"Video recording..."` based on `RecordingType`.
- Visually informs the user inside the notes UI that recording is ongoing.

### `lib/widgets/recording_list_tile.dart`

- Presentational list item for a `RecordingItem`.
- Shows:
  - Icon: microphone (audio) or camera (video).
  - Title: “Audio recording” or “Video recording”.
  - Subtitle: timestamp using `intl` formatting.
- Tapping:
  - Uses `OpenFilex.open(item.filePath)` to open the recording with the system app.
- Optional delete button to remove the recording and its underlying file.

---

## Android-Specific (conceptual)

Although not Dart files, these are important for the project:

- **`AndroidManifest.xml`:**
  - Declares permissions:
    - `RECORD_AUDIO`, `CAMERA`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MICROPHONE`, `WAKE_LOCK`, (optionally `POST_NOTIFICATIONS`).
  - Declares the foreground service:
    ```xml
    <service
        android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
        android:exported="false"
        android:foregroundServiceType="microphone" />
    ```

---

## Summary

- **Notes functionality** is handled by:
  - `Note` model, `DatabaseService`, `NotesController`, `NotesScreen`, `EditNoteScreen`, and `NoteCard`.
- **Recording functionality** is handled by:
  - `RecordingItem` model, `DatabaseService`, `RecordingController`, `RecorderScreen`, `RecordingIndicator`, `RecordingListTile`, `foreground_recording_task.dart`, and the foreground service configuration.
- **Theming and UI polish** are centralised in `theme.dart` and expressed in the love‑themed notes screen and ghost‑themed recorder screen.

This README should give you a clear map of what logic lives in each file you added or modified, and how the pieces fit together.
```