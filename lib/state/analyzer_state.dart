import '../audio/domain/audio_device.dart';
import '../dsp/bode_data.dart';
import '../dsp/peak_detector.dart';

enum AnalyzerStatus { idle, recording }

class AnalyzerState {
  final AnalyzerStatus status;
  final AudioDevice? selectedDevice;
  final BodeData? bodeData;
  final List<SpectralPeak> peaks;

  const AnalyzerState({
    required this.status,
    this.selectedDevice,
    this.bodeData,
    this.peaks = const [],
  });

  factory AnalyzerState.initial() =>
      const AnalyzerState(status: AnalyzerStatus.idle);

  bool get isRecording => status == AnalyzerStatus.recording;
  bool get hasData => bodeData != null;

  AnalyzerState copyWith({
    AnalyzerStatus? status,
    AudioDevice? selectedDevice,
    BodeData? bodeData,
    List<SpectralPeak>? peaks,
  }) {
    return AnalyzerState(
      status: status ?? this.status,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      bodeData: bodeData ?? this.bodeData,
      peaks: peaks ?? this.peaks,
    );
  }
}
