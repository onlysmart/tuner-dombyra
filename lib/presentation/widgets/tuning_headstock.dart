import 'package:flutter/material.dart';

class TuningHeadstock extends StatelessWidget {
  final List<String> noteNames;
  final int activeStringIndex;
  final double cents;

  const TuningHeadstock({
    super.key,
    required this.noteNames,
    required this.activeStringIndex,
    this.cents = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 200,
      height: 300,
      child: CustomPaint(
        painter: _HeadstockPainter(
          noteNames: noteNames,
          activeStringIndex: activeStringIndex,
          cents: cents,
          colorScheme: colorScheme,
        ),
      ),
    );
  }
}

class _HeadstockPainter extends CustomPainter {
  final List<String> noteNames;
  final int activeStringIndex;
  final double cents;
  final ColorScheme colorScheme;

  _HeadstockPainter({
    required this.noteNames,
    required this.activeStringIndex,
    required this.cents,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = colorScheme.onSurface;

    final strokePaint = Paint()
      ..color = baseColor.withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final stringPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final activeStringPaint = Paint()
      ..color = const Color(0xFF1991D8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pegStrokePaint = Paint()
      ..color = baseColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final activePegPaint = Paint()
      ..color = const Color(0xFF1991D8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Headstock outline path
    final path = Path();
    path.moveTo(size.width * 0.375, size.height);
    path.lineTo(size.width * 0.375, size.height * 0.833);
    path.quadraticBezierTo(
      size.width * 0.375,
      size.height * 0.8,
      size.width * 0.25,
      size.height * 0.7,
    );
    path.lineTo(size.width * 0.3, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.133,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.1,
      size.width * 0.7,
      size.height * 0.2,
    );
    path.lineTo(size.width * 0.75, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.625,
      size.height * 0.8,
      size.width * 0.625,
      size.height * 0.833,
    );
    path.lineTo(size.width * 0.625, size.height);

    canvas.drawPath(path, strokePaint);

    // Horizontal lines inside headstock
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.9),
      Offset(size.width * 0.625, size.height * 0.9),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.933),
      Offset(size.width * 0.625, size.height * 0.933),
      strokePaint,
    );

    // String positions
    final stringXLeft = [0.45, 0.4, 0.35]; // D, A, E low (left side)
    final stringXRight = [0.55, 0.6, 0.65]; // G, B, E high (right side)
    final pegY = [size.height * 0.25, size.height * 0.45, size.height * 0.65]; // 3 pegs per side

    // Draw strings
    for (int i = 0; i < 3; i++) {
      final isActive = activeStringIndex == (2 - i); // Left side: 2,1,0
      final paint = isActive ? activeStringPaint : stringPaint;

      // String from nut (bottom) to peg
      final startX = size.width * 0.5;
      final endX = size.width * stringXLeft[i];
      final y = pegY[i];

      canvas.drawLine(
        Offset(startX, size.height),
        Offset(endX, y),
        paint,
      );

      // String glow effect for active
      if (isActive) {
        final glowPaint = Paint()
          ..color = const Color(0xFF1991D8).withValues(alpha: 0.3)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawLine(
          Offset(startX, size.height),
          Offset(endX, y),
          glowPaint,
        );
      }
    }

    for (int i = 0; i < 3; i++) {
      final isActive = activeStringIndex == (3 + i); // Right side: 3,4,5
      final paint = isActive ? activeStringPaint : stringPaint;

      final startX = size.width * 0.5;
      final endX = size.width * stringXRight[i];
      final y = pegY[i];

      canvas.drawLine(
        Offset(startX, size.height),
        Offset(endX, y),
        paint,
      );

      if (isActive) {
        final glowPaint = Paint()
          ..color = const Color(0xFF1991D8).withValues(alpha: 0.3)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawLine(
          Offset(startX, size.height),
          Offset(endX, y),
          glowPaint,
        );
      }
    }

    // Draw peg circles on headstock (small circles at string end)
    for (int i = 0; i < 3; i++) {
      final isActive = activeStringIndex == (2 - i);
      final paint = isActive ? activePegPaint : pegStrokePaint;
      final fillPaint = isActive
          ? (Paint()..color = Colors.white)
          : (Paint()..color = Colors.transparent);

      final x = size.width * stringXLeft[i];
      canvas.drawCircle(Offset(x, pegY[i]), 6, fillPaint);
      canvas.drawCircle(Offset(x, pegY[i]), 6, paint);
      canvas.drawCircle(Offset(x, pegY[i]), 2, paint);

      final rightX = size.width * stringXRight[i];
      final rightActive = activeStringIndex == (3 + i);
      final rightPaint = rightActive ? activePegPaint : pegStrokePaint;
      final rightFill = rightActive ? (Paint()..color = Colors.white) : (Paint()..color = Colors.transparent);
      canvas.drawCircle(Offset(rightX, pegY[i]), 6, rightFill);
      canvas.drawCircle(Offset(rightX, pegY[i]), 6, rightPaint);
      canvas.drawCircle(Offset(rightX, pegY[i]), 2, rightPaint);
    }

    // Peg connectors (lines from circle to edge)
    final connectorPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.3 - 5, pegY[0]), Offset(size.width * 0.15, pegY[0]), connectorPaint);
    canvas.drawLine(Offset(size.width * 0.3 - 5, pegY[1]), Offset(size.width * 0.15, pegY[1]), connectorPaint);
    canvas.drawLine(Offset(size.width * 0.3 - 5, pegY[2]), Offset(size.width * 0.15, pegY[2]), connectorPaint);
    canvas.drawLine(Offset(size.width * 0.7 + 5, pegY[0]), Offset(size.width * 0.85, pegY[0]), connectorPaint);
    canvas.drawLine(Offset(size.width * 0.7 + 5, pegY[1]), Offset(size.width * 0.85, pegY[1]), connectorPaint);
    canvas.drawLine(Offset(size.width * 0.7 + 5, pegY[2]), Offset(size.width * 0.85, pegY[2]), connectorPaint);

    // Peg shapes (rounded rectangles with note labels)
    _drawPegShape(canvas, Offset(size.width * 0.1, pegY[0]), true, noteNames[2], textPainter, isActive: activeStringIndex == 2);
    _drawPegShape(canvas, Offset(size.width * 0.1, pegY[1]), true, noteNames[1], textPainter, isActive: activeStringIndex == 1);
    _drawPegShape(canvas, Offset(size.width * 0.1, pegY[2]), true, noteNames[0], textPainter, isActive: activeStringIndex == 0);
    _drawPegShape(canvas, Offset(size.width * 0.9, pegY[0]), false, noteNames[3], textPainter, isActive: activeStringIndex == 3);
    _drawPegShape(canvas, Offset(size.width * 0.9, pegY[1]), false, noteNames[4], textPainter, isActive: activeStringIndex == 4);
    _drawPegShape(canvas, Offset(size.width * 0.9, pegY[2]), false, noteNames[5], textPainter, isActive: activeStringIndex == 5);
  }

  void _drawPegShape(Canvas canvas, Offset center, bool isLeft, String note, TextPainter textPainter, {bool isActive = false}) {
    final pegBaseColor = colorScheme.onSurface;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 30, height: 30),
      const Radius.circular(15),
    );

    final fillPaint = Paint()
      ..color = isActive ? Colors.white : Colors.transparent
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = isActive ? const Color(0xFF1991D8) : pegBaseColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, strokePaint);

    textPainter.text = TextSpan(
      text: note,
      style: TextStyle(
        color: isActive ? const Color(0xFF1991D8) : pegBaseColor,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _HeadstockPainter oldDelegate) {
    return oldDelegate.activeStringIndex != activeStringIndex ||
        oldDelegate.cents != cents;
  }
}