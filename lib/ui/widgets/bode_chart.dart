import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/state_providers.dart';
import '../painters/bode_painter.dart';

class BodeChart extends ConsumerWidget {
  const BodeChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodeData = ref.watch(bodeDataProvider);
    final peaks = ref.watch(spectralPeaksProvider);
    final isRecording = ref.watch(isRecordingProvider);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border: Border.all(color: const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              painter: BodePainter(bodeData: bodeData, peaks: peaks),
              child: const SizedBox.expand(),
            ),
          ),
          if (bodeData == null)
            Center(
              child: Text(
                isRecording ? 'Waiting for audio…' : 'Select a device and start recording',
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
