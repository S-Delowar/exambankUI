import 'package:flutter/material.dart';

class TimerPill extends StatelessWidget {
  final Duration remaining;

  const TimerPill({super.key, required this.remaining});

  String get _label {
    final mm = remaining.inMinutes.toString().padLeft(2, '0');
    final ss = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Color _bg(ColorScheme cs) {
    if (remaining.inSeconds <= 30) return cs.errorContainer;
    if (remaining.inMinutes < 2) return Colors.amber.withValues(alpha: 0.25);
    return cs.surfaceContainerHigh;
  }

  Color _fg(ColorScheme cs) {
    if (remaining.inSeconds <= 30) return cs.onErrorContainer;
    if (remaining.inMinutes < 2) return Colors.amber.shade900;
    return cs.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg(cs),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: _fg(cs)),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: _fg(cs),
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
