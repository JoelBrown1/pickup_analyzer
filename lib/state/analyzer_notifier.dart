import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_providers.dart';
import '../audio/domain/audio_device.dart';
import '../dsp/dsp_providers.dart';
import '../dsp/fft_processor.dart';
import '../dsp/peak_detector.dart';
import 'analyzer_state.dart';

class AnalyzerNotifier extends Notifier<AnalyzerState> {
  static const _sampleRate = 44100;
  static const _fftSize = 4096;

  StreamSubscription<Uint8List>? _subscription;

  /// Rolling buffer of float64 samples fed from incoming PCM chunks.
  final _buffer = <double>[];

  @override
  AnalyzerState build() => AnalyzerState.initial();

  void selectDevice(AudioDevice device) {
    state = state.copyWith(selectedDevice: device);
  }

  Future<void> startRecording() async {
    final device = state.selectedDevice;
    if (device == null || state.isRecording) return;

    final service = ref.read(audioStreamServiceProvider);
    final processor = FftProcessor(fftSize: _fftSize, sampleRate: _sampleRate);
    final detector = ref.read(peakDetectorProvider);

    final stream = await service.startStream(
      device: device,
      sampleRate: _sampleRate,
    );

    state = state.copyWith(status: AnalyzerStatus.recording);

    _subscription = stream.listen(
      (bytes) => _onChunk(bytes, processor, detector),
      onError: (_) => stopRecording(),
      onDone: stopRecording,
    );
  }

  Future<void> stopRecording() async {
    await _subscription?.cancel();
    _subscription = null;
    _buffer.clear();

    final service = ref.read(audioStreamServiceProvider);
    await service.stop();

    state = state.copyWith(status: AnalyzerStatus.idle);
  }

  void _onChunk(
    Uint8List bytes,
    FftProcessor processor,
    PeakDetector detector,
  ) {
    final samples = FftProcessor.pcmBytesToSamples(bytes);
    _buffer.addAll(samples);

    // Process whenever we have at least one full FFT window.
    if (_buffer.length < _fftSize) return;

    final window = Float64List.fromList(
      _buffer.sublist(_buffer.length - _fftSize),
    );
    // Keep only the last fftSize samples in the buffer to avoid unbounded growth.
    if (_buffer.length > _fftSize * 2) {
      _buffer.removeRange(0, _buffer.length - _fftSize);
    }

    final bodeData = processor.process(window);
    final peaks = detector.detect(bodeData);

    state = state.copyWith(bodeData: bodeData, peaks: peaks);
  }
}

