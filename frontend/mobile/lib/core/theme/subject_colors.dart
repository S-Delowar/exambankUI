import 'package:flutter/material.dart';

class SubjectColors {
  static const Map<String, Color> byName = {
    'physics': Color(0xFF5C6BC0),
    'chemistry': Color(0xFF00897B),
    'mathematics': Color(0xFFFFA000),
    'biology': Color(0xFF43A047),
    'bangla': Color(0xFFFF7043),
    'english': Color(0xFF1976D2),
    'ict': Color(0xFF8E24AA),
    'general_knowledge': Color(0xFF6D4C41),
  };

  static Color of(String? subject, {Color fallback = const Color(0xFF607D8B)}) {
    if (subject == null) return fallback;
    return byName[subject.toLowerCase()] ?? fallback;
  }

  static String prettyLabel(String? raw) {
    if (raw == null || raw.isEmpty) return 'Unknown';
    return raw
        .split('_')
        .map((s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }
}
