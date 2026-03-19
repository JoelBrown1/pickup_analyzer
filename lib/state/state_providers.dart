import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/domain/audio_device.dart';
import '../dsp/bode_data.dart';
import '../dsp/peak_detector.dart';
import 'analyzer_notifier.dart';
import 'analyzer_state.dart';

final analyzerProvider =
    NotifierProvider<AnalyzerNotifier, AnalyzerState>(AnalyzerNotifier.new);

// Convenience derived providers — widgets can watch these instead of the full state.

final selectedDeviceProvider = Provider<AudioDevice?>(
  (ref) => ref.watch(analyzerProvider).selectedDevice,
);

final isRecordingProvider = Provider<bool>(
  (ref) => ref.watch(analyzerProvider).isRecording,
);

final bodeDataProvider = Provider<BodeData?>(
  (ref) => ref.watch(analyzerProvider).bodeData,
);

final spectralPeaksProvider = Provider<List<SpectralPeak>>(
  (ref) => ref.watch(analyzerProvider).peaks,
);
