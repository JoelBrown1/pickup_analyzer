import 'package:record/record.dart';

import '../domain/audio_device.dart';
import '../domain/audio_device_repository.dart';

class RecordAudioDeviceRepository implements AudioDeviceRepository {
  const RecordAudioDeviceRepository();

  @override
  Future<List<AudioDevice>> listDevices() async {
    final recorder = AudioRecorder();
    try {
      final devices = await recorder.listInputDevices();
      return devices
          .map((d) => AudioDevice(id: d.id ?? d.label, label: d.label))
          .toList();
    } finally {
      await recorder.dispose();
    }
  }
}
