import 'package:flutter/material.dart';

class NoteDisplay extends StatelessWidget {
  final String noteName;
  final String octave;
  final double frequency;
  final bool isActive;

  const NoteDisplay({
    super.key,
    required this.noteName,
    required this.octave,
    required this.frequency,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
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
            if (noteName != '-')
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
        ),
        const SizedBox(height: 16),
        if (isActive && frequency > 0)
          Text(
            '${frequency.toStringAsFixed(2)} Hz',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          )
        else
          const SizedBox(height: 10),
      ],
    );
  }
}
