import 'bode_data.dart';

class SpectralPeak {
  final double frequency;
  final double magnitude;

  const SpectralPeak({required this.frequency, required this.magnitude});

  @override
  String toString() =>
      'SpectralPeak(freq: ${frequency.toStringAsFixed(1)} Hz, '
      'mag: ${magnitude.toStringAsFixed(6)})';
}

/// Finds local maxima in a [BodeData] magnitude spectrum.
class PeakDetector {
  /// Minimum separation between peaks in FFT bins.
  final int minBinDistance;

  /// Minimum linear magnitude to be considered a peak.
  final double minMagnitude;

  /// Maximum number of peaks to return (highest magnitude first).
  final int maxPeaks;

  const PeakDetector({
    this.minBinDistance = 5,
    this.minMagnitude = 0.001,
    this.maxPeaks = 10,
  });

  List<SpectralPeak> detect(BodeData data) {
    final mags = data.magnitudes;
    final freqs = data.frequencies;
    final n = mags.length;

    final candidates = <SpectralPeak>[];

    // Collect local maxima (ignoring DC bin 0 and Nyquist bin n-1).
    for (var i = 1; i < n - 1; i++) {
      if (mags[i] > mags[i - 1] &&
          mags[i] > mags[i + 1] &&
          mags[i] >= minMagnitude) {
        candidates.add(SpectralPeak(frequency: freqs[i], magnitude: mags[i]));
      }
    }

    // Sort descending by magnitude.
    candidates.sort((a, b) => b.magnitude.compareTo(a.magnitude));

    // Suppress peaks that are too close to a stronger neighbour.
    final binWidth = data.sampleRate / data.fftSize;
    final minFreqDistance = minBinDistance * binWidth;
    final accepted = <SpectralPeak>[];

    for (final candidate in candidates) {
      if (accepted.length >= maxPeaks) break;

      final tooClose = accepted.any(
        (p) => (p.frequency - candidate.frequency).abs() < minFreqDistance,
      );

      if (!tooClose) accepted.add(candidate);
    }

    return accepted;
  }
}
