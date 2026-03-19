import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/state_providers.dart';

class RecordButton extends ConsumerWidget {
  const RecordButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = ref.watch(isRecordingProvider);
    final hasDevice = ref.watch(selectedDeviceProvider) != null;
    final notifier = ref.read(analyzerProvider.notifier);

    return FilledButton.icon(
      onPressed: hasDevice
          ? () async {
              if (isRecording) {
                await notifier.stopRecording();
              } else {
                await notifier.startRecording();
              }
            }
          : null,
      icon: Icon(isRecording ? Icons.stop : Icons.mic),
      label: Text(isRecording ? 'Stop' : 'Record'),
      style: FilledButton.styleFrom(
        backgroundColor: isRecording ? Colors.red.shade700 : null,
      ),
    );
  }
}
