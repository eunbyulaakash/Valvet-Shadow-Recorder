import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../models/recording_item.dart';

class RecordingListTile extends StatelessWidget {
  final RecordingItem item;
  final VoidCallback? onDelete;

  const RecordingListTile({
    super.key,
    required this.item,
    this.onDelete,
  });

  Future<void> _open() async {
    await OpenFilex.open(item.filePath);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, HH:mm').format(item.createdAt);
    final isVideo = item.type == RecordingType.video;

    return ListTile(
      leading: Icon(
        isVideo ? Icons.videocam : Icons.mic,
        color: isVideo ? Colors.lightBlueAccent : const Color(0xFFE91E63),
      ),
      title: Text(isVideo ? 'Video recording' : 'Audio recording'),
      subtitle: Text(
        dateStr,
        style: const TextStyle(color: Colors.white54),
      ),
      onTap: _open,
      trailing: onDelete == null
          ? null
          : IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}