import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';

import 'bode_data.dart';

/// Converts a chunk of raw 16-bit PCM bytes into a [BodeData] frame.
///
/// Usage:
/// ```dart
/// final processor = FftProcessor(sampleRate: 44100);
/// final bode = processor.process(FftProcessor.pcmBytesToSamples(pcmBytes));
/// ```
class FftProcessor {
  final int fftSize;
  final int sampleRate;

  late final FFT _fft;
  late final Float64List _window;

  FftProcessor({this.fftSize = 4096, required this.sampleRate})
      : assert(_isPowerOfTwo(fftSize), 'fftSize must be a power of two') {
    _fft = FFT(fftSize);
    _window = Window.hanning(fftSize);
  }

  /// Process [samples] (float64, normalised –1..1) and return a [BodeData] frame.
  ///
  /// If [samples] is longer than [fftSize], the most recent [fftSize] samples are
  /// used. If shorter, the frame is zero-padded on the left.
  BodeData process(Float64List samples) {
    final windowed = Float64List(fftSize);

    final srcLen = samples.length.clamp(0, fftSize);
    final srcOffset = samples.length > fftSize ? samples.length - fftSize : 0;
    final dstOffset = fftSize - srcLen;

    for (var i = 0; i < srcLen; i++) {
      windowed[dstOffset + i] = samples[srcOffset + i] * _window[dstOffset + i];
    }

    final complex = _fft.realFft(windowed);

    final numBins = fftSize ~/ 2 + 1;
    final frequencies = Float64List(numBins);
    final magnitudes = Float64List(numBins);

    for (var i = 0; i < numBins; i++) {
      frequencies[i] = i * sampleRate / fftSize;
      final re = complex[i].x;
      final im = complex[i].y;
      magnitudes[i] = sqrt(re * re + im * im) / fftSize;
    }

    return BodeData(
      frequencies: frequencies,
      magnitudes: magnitudes,
      sampleRate: sampleRate,
      fftSize: fftSize,
    );
  }

  /// Decode raw 16-bit little-endian PCM bytes into normalised float64 samples.
  static Float64List pcmBytesToSamples(Uint8List bytes) {
    final numSamples = bytes.length ~/ 2;
    final samples = Float64List(numSamples);
    final byteData = ByteData.sublistView(bytes);
    for (var i = 0; i < numSamples; i++) {
      samples[i] = byteData.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return samples;
  }

  static bool _isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;
}
