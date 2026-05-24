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

    // Headstock outline path - thinner for dombyra
    final path = Path();
    path.moveTo(size.width * 0.4, size.height);
    path.lineTo(size.width * 0.4, size.height * 0.833);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.8,
      size.width * 0.35,
      size.height * 0.7,
    );
    path.lineTo(size.width * 0.4, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.133,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.1,
      size.width * 0.6,
      size.height * 0.2,
    );
    path.lineTo(size.width * 0.65, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.8,
      size.width * 0.6,
      size.height * 0.833,
    );
    path.lineTo(size.width * 0.6, size.height);

    canvas.drawPath(path, strokePaint);

    // Horizontal lines inside headstock
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.9),
      Offset(size.width * 0.6, size.height * 0.9),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.933),
      Offset(size.width * 0.6, size.height * 0.933),
      strokePaint,
    );

    // String positions
    final stringXLeft = size.width * 0.45;
    final stringXRight = size.width * 0.55;
    final pegY = size.height * 0.45;

    // Draw left string (index 0)
    bool isLeftActive = activeStringIndex == 0;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height),
      Offset(stringXLeft, pegY),
      isLeftActive ? activeStringPaint : stringPaint,
    );
    if (isLeftActive) {
      final glowPaint = Paint()
        ..color = const Color(0xFF1991D8).withValues(alpha: 0.3)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(
        Offset(size.width * 0.5, size.height),
        Offset(stringXLeft, pegY),
        glowPaint,
      );
    }

    // Draw right string (index 1)
    bool isRightActive = activeStringIndex == 1;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height),
      Offset(stringXRight, pegY),
      isRightActive ? activeStringPaint : stringPaint,
    );
    if (isRightActive) {
      final glowPaint = Paint()
        ..color = const Color(0xFF1991D8).withValues(alpha: 0.3)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(
        Offset(size.width * 0.5, size.height),
        Offset(stringXRight, pegY),
        glowPaint,
      );
    }

    // Draw peg circles on headstock
    final leftCirclePaint = isLeftActive ? activePegPaint : pegStrokePaint;
    final leftCircleFill = isLeftActive ? (Paint()..color = Colors.white) : (Paint()..color = Colors.transparent);
    canvas.drawCircle(Offset(stringXLeft, pegY), 6, leftCircleFill);
    canvas.drawCircle(Offset(stringXLeft, pegY), 6, leftCirclePaint);
    canvas.drawCircle(Offset(stringXLeft, pegY), 2, leftCirclePaint);

    final rightCirclePaint = isRightActive ? activePegPaint : pegStrokePaint;
    final rightCircleFill = isRightActive ? (Paint()..color = Colors.white) : (Paint()..color = Colors.transparent);
    canvas.drawCircle(Offset(stringXRight, pegY), 6, rightCircleFill);
    canvas.drawCircle(Offset(stringXRight, pegY), 6, rightCirclePaint);
    canvas.drawCircle(Offset(stringXRight, pegY), 2, rightCirclePaint);

    // Peg connectors
    final connectorPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.4 - 5, pegY), Offset(size.width * 0.25, pegY), connectorPaint);
    canvas.drawLine(Offset(size.width * 0.6 + 5, pegY), Offset(size.width * 0.75, pegY), connectorPaint);

    // Peg shapes
    if (noteNames.isNotEmpty) {
      _drawPegShape(canvas, Offset(size.width * 0.2, pegY), true, noteNames[0], textPainter, isActive: isLeftActive);
    }
    if (noteNames.length > 1) {
      _drawPegShape(canvas, Offset(size.width * 0.8, pegY), false, noteNames[1], textPainter, isActive: isRightActive);
    }
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
