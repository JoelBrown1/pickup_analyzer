import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/record_audio_device_repository.dart';
import 'domain/audio_device.dart';
import 'domain/audio_device_repository.dart';
import 'service/audio_stream_service.dart';

final audioDeviceRepositoryProvider = Provider<AudioDeviceRepository>(
  (_) => const RecordAudioDeviceRepository(),
);

final audioDevicesProvider = FutureProvider<List<AudioDevice>>((ref) {
  return ref.watch(audioDeviceRepositoryProvider).listDevices();
});

final audioStreamServiceProvider = Provider<AudioStreamService>(
  (_) => AudioStreamService(),
);
