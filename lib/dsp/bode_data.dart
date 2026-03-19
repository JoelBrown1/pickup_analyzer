import 'dart:math';
import 'dart:typed_data';

/// Frequency-domain data from a single FFT frame, suitable for Bode plot rendering.
class BodeData {
  /// Frequency of each bin in Hz. Length = fftSize ~/ 2 + 1.
  final Float64List frequencies;

  /// Linear magnitude of each bin (normalised to [0, 1]). Same length as [frequencies].
  final Float64List magnitudes;

  final int sampleRate;
  final int fftSize;

  const BodeData({
    required this.frequencies,
    required this.magnitudes,
    required this.sampleRate,
    required this.fftSize,
  });

  int get numBins => frequencies.length;

  /// Magnitude in dB (20·log₁₀). Returns -∞ for zero magnitude.
  double magnitudeDb(int bin) {
    final m = magnitudes[bin];
    if (m <= 0) return double.negativeInfinity;
    return 20 * log(m) / ln10;
  }

  /// Nyquist frequency for this configuration.
  double get nyquist => sampleRate / 2.0;
}
