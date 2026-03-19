import 'dart:typed_data';

import 'package:record/record.dart';

import '../domain/audio_device.dart';

class AudioStreamService {
  AudioRecorder? _recorder;

  bool get isStreaming => _recorder != null;

  /// Returns a stream of raw PCM frames (16-bit little-endian, mono by default).
  Future<Stream<Uint8List>> startStream({
    required AudioDevice device,
    int sampleRate = 44100,
    int numChannels = 1,
  }) async {
    if (_recorder != null) {
      throw StateError('Already streaming. Call stop() first.');
    }

    final recorder = AudioRecorder();
    _recorder = recorder;

    final config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: sampleRate,
      numChannels: numChannels,
      device: InputDevice(id: device.id, label: device.label),
    );

    return recorder.startStream(config);
  }

  Future<void> stop() async {
    final recorder = _recorder;
    if (recorder == null) return;
    _recorder = null;
    await recorder.stop();
    await recorder.dispose();
  }
}
