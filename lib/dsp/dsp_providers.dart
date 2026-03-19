import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fft_processor.dart';
import 'peak_detector.dart';

/// Default FFT size (samples). Override by creating a scoped provider.
const defaultFftSize = 4096;

final fftProcessorProvider = Provider.family<FftProcessor, int>(
  (_, sampleRate) => FftProcessor(fftSize: defaultFftSize, sampleRate: sampleRate),
);

final peakDetectorProvider = Provider<PeakDetector>(
  (_) => const PeakDetector(),
);
