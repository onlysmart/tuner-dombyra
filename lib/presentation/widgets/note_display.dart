import 'package:flutter/material.dart';

class NoteDisplay extends StatelessWidget {
  final String noteName;
  final String octave;
  final double frequency;
  final double targetFrequency;
  final bool isActive;

  const NoteDisplay({
    super.key,
    required this.noteName,
    required this.octave,
    required this.frequency,
    required this.targetFrequency,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Line 1: target/etalon frequency (small, muted)
        if (isActive && targetFrequency > 0)
          SizedBox(
            height: 14,
            child: Text(
              '${targetFrequency.toStringAsFixed(1)} Hz',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
          )
        else
          const SizedBox(height: 14),

        const SizedBox(height: 8),

        // Line 2: note name or prompt (large)
        if (isActive && noteName != '-')
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                noteName,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 50,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  octave,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            noteName,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),

        const SizedBox(height: 8),

        // Line 3: current/detected frequency
        Text(
          '${frequency.toStringAsFixed(2)} Hz',
          style: TextStyle(
            color: isActive && frequency > 0
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
