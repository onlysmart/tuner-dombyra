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

    // Nut line — bottom of headstock, top of neck
    final nutY = size.height * 0.85;

    // Headstock outline path — covers full height
    final path = Path();
    path.moveTo(size.width * 0.4, size.height);
    path.lineTo(size.width * 0.4, nutY);
    path.lineTo(size.width * 0.4, size.height * 0.75);
    // Inner curve from neck to flare
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.72,
      size.width * 0.36,
      size.height * 0.64,
    );
    // Round the sharp bottom-left corner
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.63,
      size.width * 0.355,
      size.height * 0.585,
    );
    path.lineTo(size.width * 0.4, size.height * 0.18);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.09,
      size.width * 0.5,
      size.height * 0.12,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.09,
      size.width * 0.6,
      size.height * 0.18,
    );
    // Line down to just above the corner
    path.lineTo(size.width * 0.645, size.height * 0.585);
    // Round the sharp bottom-right corner
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.63,
      size.width * 0.64,
      size.height * 0.64,
    );
    // Inner curve back to neck
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.72,
      size.width * 0.6,
      size.height * 0.75,
    );
    path.lineTo(size.width * 0.6, nutY);
    path.lineTo(size.width * 0.6, size.height);

    canvas.drawPath(path, strokePaint);

    // Nut lines
    canvas.drawLine(
      Offset(size.width * 0.4, nutY),
      Offset(size.width * 0.6, nutY),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.88),
      Offset(size.width * 0.6, size.height * 0.88),
      strokePaint,
    );

    // String positions with vertical tilt
    // String 0 (D): lower peg, string 1 (G): higher peg
    final dPegX = size.width * 0.45;
    final dPegY = size.height * 0.4;
    final dNutX = size.width * 0.45;
    final gPegX = size.width * 0.55;
    final gPegY = size.height * 0.6;
    final gNutX = size.width * 0.55;

    // Draw string 0 (D)
    bool isLeftActive = activeStringIndex == 0;
    canvas.drawLine(
      Offset(dNutX, nutY),
      Offset(dPegX, dPegY),
      isLeftActive ? activeStringPaint : stringPaint,
    );
    if (isLeftActive) {
      final glowPaint = Paint()
        ..color = const Color(0xFF1991D8).withValues(alpha: 0.3)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(
        Offset(dNutX, nutY),
        Offset(dPegX, dPegY),
        glowPaint,
      );
    }

    // Draw string 1 (G)
    bool isRightActive = activeStringIndex == 1;
    canvas.drawLine(
      Offset(gNutX, nutY),
      Offset(gPegX, gPegY),
      isRightActive ? activeStringPaint : stringPaint,
    );
    if (isRightActive) {
      final glowPaint = Paint()
        ..color = const Color(0xFF1991D8).withValues(alpha: 0.3)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(
        Offset(gNutX, nutY),
        Offset(gPegX, gPegY),
        glowPaint,
      );
    }

    // Draw peg circles on headstock
    final leftCirclePaint = isLeftActive ? activePegPaint : pegStrokePaint;
    final leftCircleFill = isLeftActive ? (Paint()..color = Colors.white) : (Paint()..color = Colors.transparent);
    canvas.drawCircle(Offset(dPegX, dPegY), 6, leftCircleFill);
    canvas.drawCircle(Offset(dPegX, dPegY), 6, leftCirclePaint);
    canvas.drawCircle(Offset(dPegX, dPegY), 2, leftCirclePaint);

    final rightCirclePaint = isRightActive ? activePegPaint : pegStrokePaint;
    final rightCircleFill = isRightActive ? (Paint()..color = Colors.white) : (Paint()..color = Colors.transparent);
    canvas.drawCircle(Offset(gPegX, gPegY), 6, rightCircleFill);
    canvas.drawCircle(Offset(gPegX, gPegY), 6, rightCirclePaint);
    canvas.drawCircle(Offset(gPegX, gPegY), 2, rightCirclePaint);

    // Peg connectors
    final connectorPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.35 - 5, dPegY), Offset(size.width * 0.25, dPegY), connectorPaint);
    canvas.drawLine(Offset(size.width * 0.65 + 5, gPegY), Offset(size.width * 0.75, gPegY), connectorPaint);

    // Peg shapes
    if (noteNames.isNotEmpty) {
      _drawPegShape(canvas, Offset(size.width * 0.2, dPegY), true, noteNames[0], textPainter, isActive: isLeftActive);
    }
    if (noteNames.length > 1) {
      _drawPegShape(canvas, Offset(size.width * 0.8, gPegY), false, noteNames[1], textPainter, isActive: isRightActive);
    }

    // Neck strings — 2 parallel vertical lines from nut to bottom
    final neckPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(dNutX, nutY), Offset(dNutX, size.height), neckPaint);
    canvas.drawLine(Offset(gNutX, nutY), Offset(gNutX, size.height), neckPaint);
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
