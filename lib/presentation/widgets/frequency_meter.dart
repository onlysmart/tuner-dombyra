import 'dart:math';
import 'package:flutter/material.dart';

class FrequencyMeter extends StatefulWidget {
  final double cents;
  final double? targetFrequency;
  final bool isActive;

  const FrequencyMeter({
    super.key,
    required this.cents,
    this.targetFrequency,
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

    final targetFreq = widget.targetFrequency ?? 440.0;
    final showHz = widget.targetFrequency != null && widget.targetFrequency! > 0;
    final effectiveCents = widget.isActive ? _displayedCents : 0.0;

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(13, (index) {
                final isCenter = index == 6;
                final isMajor = index % 3 == 0;
                return Container(
                  width: 1.5,
                  height: isCenter ? 36 : (isMajor ? 24 : 16),
                  color: isCenter
                      ? meterColor.withValues(alpha: 0.5)
                      : (isMajor
                          ? meterColor.withValues(alpha: 0.3)
                          : meterColor.withValues(alpha: 0.2)),
                );
              }),
            ),
          ),
          if (showHz)
            Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(13, (index) {
                  if (index % 3 == 0) {
                    final cents = (index - 6) * 200.0 / 6;
                    final hzDev =
                        targetFreq * (pow(2, cents / 1200) - 1);
                    final label = index == 6
                        ? '0'
                        : '${hzDev >= 0 ? '+' : ''}${hzDev.abs().toStringAsFixed(0)}';
                    return Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        color: meterColor.withValues(alpha: 0.3),
                      ),
                    );
                  }
                  return const SizedBox(width: 0);
                }),
              ),
            ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 100),
            alignment: Alignment(
              (effectiveCents.clamp(-200.0, 200.0) / 200.0),
              -1.0,
            ),
            child: _buildNeedle(colorScheme, targetFreq, showHz, effectiveCents),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedle(ColorScheme colorScheme, double targetFreq, bool showHz, double effectiveCents) {
    final clampedCents = effectiveCents.clamp(-200.0, 200.0);
    final needleColor = colorScheme.primary;
    final hzDev = targetFreq * (pow(2, clampedCents / 1200) - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                needleColor,
                colorScheme.primary.withValues(alpha: 0.6),
                colorScheme.primary.withValues(alpha: 0.6),
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            showHz
                ? '${clampedCents.abs().toStringAsFixed(0)}¢\n${hzDev >= 0 ? '+' : ''}${hzDev.toStringAsFixed(1)}Hz'
                : '${clampedCents.abs().toStringAsFixed(0)}¢',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}