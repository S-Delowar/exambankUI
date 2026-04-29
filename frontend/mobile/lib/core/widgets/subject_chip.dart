import 'package:flutter/material.dart';

import '../theme/subject_colors.dart';

class SubjectChip extends StatelessWidget {
  final String? subject;
  final double fontSize;

  const SubjectChip({super.key, required this.subject, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final color = SubjectColors.of(subject);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        SubjectColors.prettyLabel(subject),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
