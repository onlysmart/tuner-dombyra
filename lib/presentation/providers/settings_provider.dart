import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuner_dombyra/data/repositories/settings_repository.dart';
import 'package:tuner_dombyra/domain/models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  late AppSettings _settings;

  SettingsProvider(this._repository) {
    _settings = _repository.loadSettings();
  }

  AppSettings get settings => _settings;

  Future<void> updateThemeMode(String mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateReferencePitch(double pitch) async {
    _settings = _settings.copyWith(referencePitch: pitch);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateTuningMode(TuningMode mode) async {
    _settings = _settings.copyWith(tuningMode: mode);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }
}
