import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_guitar/domain/models/app_settings.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const _themeModeKey = 'themeMode';
  static const _languageKey = 'language';
  static const _referencePitchKey = 'referencePitch';
  static const _tuningModeKey = 'tuningMode';

  AppSettings loadSettings() {
    final themeMode = _prefs.getString(_themeModeKey) ?? 'system';
    final language = _prefs.getString(_languageKey) ?? 'system';
    final referencePitch = _prefs.getDouble(_referencePitchKey) ?? 440.0;
    final tuningModeIndex = _loadTuningModeIndex();

    return AppSettings(
      themeMode: themeMode,
      language: language,
      referencePitch: referencePitch,
      tuningModeIndex: tuningModeIndex,
    );
  }

  int _loadTuningModeIndex() {
    final dynamic raw = _prefs.get(_tuningModeKey);
    if (raw is int) return raw.clamp(0, TuningMode.values.length - 1);
    if (raw is String) {
      final index = TuningMode.values.indexWhere((e) => e.name == raw);
      final result = index >= 0 ? index : 0;
      _prefs.setInt(_tuningModeKey, result);
      return result;
    }
    return 0;
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_themeModeKey, settings.themeMode);
    await _prefs.setString(_languageKey, settings.language);
    await _prefs.setDouble(_referencePitchKey, settings.referencePitch);
    await _prefs.setInt(_tuningModeKey, settings.tuningModeIndex);
  }
}
