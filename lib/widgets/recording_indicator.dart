import 'package:flutter/material.dart';

import '../models/recording_item.dart';

class RecordingIndicator extends StatelessWidget {
  final RecordingType type;

  const RecordingIndicator({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final label =
    type == RecordingType.audio ? 'Your privacy is protected...' : 'Keep private moment here...';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF2A1A26),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE91E63), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}