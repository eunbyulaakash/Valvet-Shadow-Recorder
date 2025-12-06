enum RecordingType {
  audio,
  video,
}

class RecordingItem {
  int? id;
  RecordingType type;
  String filePath;
  int? durationSeconds;
  DateTime createdAt;

  RecordingItem({
    this.id,
    required this.type,
    required this.filePath,
    this.durationSeconds,
    required this.createdAt,
  });

  factory RecordingItem.fromMap(Map<String, dynamic> map) {
    return RecordingItem(
      id: map['id'] as int?,
      type: (map['type'] as String) == 'video'
          ? RecordingType.video
          : RecordingType.audio,
      filePath: map['file_path'] as String,
      durationSeconds: map['duration_seconds'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type == RecordingType.video ? 'video' : 'audio',
      'file_path': filePath,
      'duration_seconds': durationSeconds,
      'created_at': createdAt.toIso8601String(),
    };
  }
}