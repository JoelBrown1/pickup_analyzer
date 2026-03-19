import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/state_providers.dart';

class PeakList extends ConsumerWidget {
  const PeakList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peaks = ref.watch(spectralPeaksProvider);

    if (peaks.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: peaks.map((p) {
        final db = 20 * log(p.magnitude) / ln10;
        return Chip(
          visualDensity: VisualDensity.compact,
          backgroundColor: const Color(0xFF21262D),
          side: const BorderSide(color: Color(0xFFF78166), width: 0.5),
          label: Text(
            '${p.frequency.toStringAsFixed(1)} Hz  ${db.toStringAsFixed(1)} dB',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFF78166),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      }).toList(),
    );
  }
}
