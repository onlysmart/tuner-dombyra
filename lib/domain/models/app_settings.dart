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
  dropD,
  halfStepDown,
  fullStepDown,
}

List<double> tuningFrequencies(TuningMode mode, double referencePitch) {
  const standardSemitones = [-29, -24, -19, -14, -10, -5];
  const dropDSemitones = [-31, -24, -19, -14, -10, -5];

  final semitones = mode == TuningMode.dropD ? dropDSemitones : standardSemitones;
  final baseRatio = referencePitch / 440.0;

  var result = semitones.map((s) {
    var freq = 440.0 * pow(2, s / 12) * baseRatio;
    if (mode == TuningMode.halfStepDown) freq *= pow(2, -1 / 12);
    if (mode == TuningMode.fullStepDown) freq *= pow(2, -2 / 12);
    return freq;
  }).toList();

  return result;
}

List<String> tuningNoteNames(TuningMode mode) {
  switch (mode) {
    case TuningMode.standard:
      return ['E', 'A', 'D', 'G', 'B', 'E'];
    case TuningMode.dropD:
      return ['D', 'A', 'D', 'G', 'B', 'E'];
    case TuningMode.halfStepDown:
      return ['Eb', 'Ab', 'Db', 'Gb', 'Bb', 'Eb'];
    case TuningMode.fullStepDown:
      return ['D', 'G', 'C', 'F', 'A', 'D'];
  }
}

List<int> tuningOctaves(TuningMode mode) {
  switch (mode) {
    case TuningMode.standard:
      return [2, 2, 3, 3, 3, 4];
    case TuningMode.dropD:
      return [2, 2, 3, 3, 3, 4];
    case TuningMode.halfStepDown:
      return [2, 2, 3, 3, 3, 4];
    case TuningMode.fullStepDown:
      return [2, 2, 3, 3, 3, 4];
  }
}
