import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../audio/domain/audio_device.dart';
import '../../state/state_providers.dart';

class DevicePicker extends ConsumerWidget {
  const DevicePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(audioDevicesProvider);
    final selected = ref.watch(selectedDeviceProvider);
    final isRecording = ref.watch(isRecordingProvider);

    return devicesAsync.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, _) => Text(
        'Failed to list devices: $e',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
      data: (devices) => DropdownButtonHideUnderline(
        child: DropdownButton<AudioDevice>(
          value: selected,
          hint: const Text('Select input device'),
          isDense: true,
          onChanged: isRecording
              ? null
              : (device) {
                  if (device != null) {
                    ref.read(analyzerProvider.notifier).selectDevice(device);
                  }
                },
          items: devices
              .map(
                (d) => DropdownMenuItem(
                  value: d,
                  child: Text(d.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
