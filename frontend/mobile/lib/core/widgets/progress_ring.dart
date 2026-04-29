import 'dart:math' as math;

import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double stroke;
  final String? centerLabel;
  final Color? trackColor;
  final Color? valueColor;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 100,
    this.stroke = 10,
    this.centerLabel,
    this.trackColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0, 1).toDouble(),
          stroke: stroke,
          track: trackColor ?? cs.surfaceContainerHighest,
          valueColor: valueColor ?? cs.primary,
        ),
        child: Center(
          child: Text(
            centerLabel ?? '${(value * 100).round()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final Color track;
  final Color valueColor;

  _RingPainter({
    required this.value,
    required this.stroke,
    required this.track,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, trackPaint);

    final valuePaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, valuePaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.track != track ||
      old.valueColor != valueColor ||
      old.stroke != stroke;
}
