import 'package:flutter/services.dart';

class HistoryItem {
  final String prompt;
  final Uint8List? imageData;
  final DateTime timestamp;

  HistoryItem({required this.prompt, required this.imageData, required this.timestamp});
}
