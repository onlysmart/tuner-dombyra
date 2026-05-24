import 'dart:math';

class AppSettings {
  final String themeMode;
  final String language;
  final double referencePitch;
  final int tuningModeIndex;

  const AppSettings({
    this.themeMode = 'system',
    this.language = 'system',
    this.referencePitch = 440.0,
    this.tuningModeIndex = 0,
  });

  TuningMode get tuningMode => TuningMode.values[tuningModeIndex];

  AppSettings copyWith({
    String? themeMode,
    String? language,
    double? referencePitch,
    int? tuningModeIndex,
    TuningMode? tuningMode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      referencePitch: referencePitch ?? this.referencePitch,
      tuningModeIndex: tuningMode?.index ?? tuningModeIndex ?? this.tuningModeIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          themeMode == other.themeMode &&
          language == other.language &&
          referencePitch == other.referencePitch &&
          tuningModeIndex == other.tuningModeIndex;

  @override
  int get hashCode =>
      themeMode.hashCode ^ language.hashCode ^ referencePitch.hashCode ^ tuningModeIndex.hashCode;
}

enum TuningMode {
  standard,
}

List<double> tuningFrequencies(TuningMode mode, double referencePitch) {
  const standardSemitones = [-19, -14];
  final semitones = standardSemitones;
  final baseRatio = referencePitch / 440.0;

  var result = semitones.map((s) {
    var freq = 440.0 * pow(2, s / 12) * baseRatio;
    return freq;
  }).toList();

  return result;
}

List<String> tuningNoteNames(TuningMode mode) {
  return ['D', 'G'];
}

List<int> tuningOctaves(TuningMode mode) {
  return [3, 3];
}
