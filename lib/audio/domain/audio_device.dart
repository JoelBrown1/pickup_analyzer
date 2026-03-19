class AudioDevice {
  final String id;
  final String label;

  const AudioDevice({required this.id, required this.label});

  @override
  String toString() => 'AudioDevice(id: $id, label: $label)';

  @override
  bool operator ==(Object other) =>
      other is AudioDevice && other.id == id && other.label == label;

  @override
  int get hashCode => Object.hash(id, label);
}
