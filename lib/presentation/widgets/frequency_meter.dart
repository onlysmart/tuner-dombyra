import 'package:flutter/material.dart';

class FrequencyMeter extends StatefulWidget {
  final double cents;
  final bool isActive;

  const FrequencyMeter({
    super.key,
    required this.cents,
    this.isActive = false,
  });

  @override
  State<FrequencyMeter> createState() => _FrequencyMeterState();
}

class _FrequencyMeterState extends State<FrequencyMeter> {
  double _displayedCents = 0;

  @override
  void didUpdateWidget(FrequencyMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cents != widget.cents) {
      setState(() {
        _displayedCents = widget.cents;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final meterColor = colorScheme.onSurface.withValues(alpha: 0.4);

    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(13, (index) {
                final isCenter = index == 6;
                final isMajor = index == 3 || index == 9;
                return Container(
                  width: 1.5,
                  height: isCenter ? 48 : (isMajor ? 32 : 20),
                  color: isCenter
                      ? meterColor.withValues(alpha: 0.5)
                      : (isMajor
                          ? meterColor.withValues(alpha: 0.3)
                          : meterColor.withValues(alpha: 0.2)),
                );
              }),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 100),
            alignment: Alignment(
              (_displayedCents.clamp(-50.0, 50.0) / 50.0),
              -1.0,
            ),
            child: _buildNeedle(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedle(ColorScheme colorScheme) {
    final clampedCents = _displayedCents.clamp(-50.0, 50.0);
    final needleColor = colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                needleColor,
                colorScheme.onSurface.withValues(alpha: 0.6),
                colorScheme.onSurface.withValues(alpha: 0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: needleColor.withValues(alpha: 0.8),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB4AB),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            clampedCents.abs().toStringAsFixed(0),
            style: const TextStyle(
              color: Color(0xFF131313),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}