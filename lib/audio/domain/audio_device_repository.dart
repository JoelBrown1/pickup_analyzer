import 'audio_device.dart';

abstract interface class AudioDeviceRepository {
  Future<List<AudioDevice>> listDevices();
}
