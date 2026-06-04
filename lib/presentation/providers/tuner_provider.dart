import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tuner_dombyra/services/audio_service.dart';
import 'package:tuner_dombyra/domain/models/app_settings.dart';

enum PitchAccuracy { inTune, sharp, flat, noInput }

enum AudioInputState { listening, tooQuiet, tooNoisy, detected }

class TunerProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();

  double _detectedFrequency = 0.0;
  double _targetFrequency = 0.0;
  int _detectedStringIndex = -1;
  PitchAccuracy _accuracy = PitchAccuracy.noInput;
  AudioInputState _inputState = AudioInputState.listening;
  double _centsDeviation = 0.0;
  bool _isListening = false;
  double _referencePitch = 440.0;
  double _sensitivity = 0.5;
  int _inTuneCount = 0;
  List<double> _targetFrequencies = [];
  List<String> _noteNames = [];
  TuningMode _tuningMode = TuningMode.standard;
  bool _hapticEnabled = true;

  double _smoothedFrequency = 0.0;
  int _stringLockCandidate = -1;
  int _stringLockCount = 0;

  double get detectedFrequency => _detectedFrequency;
  double get targetFrequency => _targetFrequency;
  int get detectedStringIndex => _detectedStringIndex;
  PitchAccuracy get accuracy => _accuracy;
  AudioInputState get inputState => _inputState;
  double get centsDeviation => _centsDeviation;
  bool get isListening => _isListening;
  double get referencePitch => _referencePitch;
  double get sensitivity => _sensitivity;
  bool get hapticEnabled => _hapticEnabled;
  AudioService get audioService => _audioService;
  List<String> get noteNames => _noteNames;

  void setReferencePitch(double pitch) {
    _referencePitch = pitch;
    _computeTargets();
    notifyListeners();
  }

  void setSensitivity(double value) {
    _sensitivity = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
    notifyListeners();
  }

  void setTuningMode({
    required TuningMode mode,
    required List<String> noteNames,
  }) {
    _tuningMode = mode;
    _noteNames = noteNames;
    _computeTargets();
    notifyListeners();
  }

  void _computeTargets() {
    _targetFrequencies = tuningFrequencies(_tuningMode, _referencePitch);
    _noteNames = tuningNoteNames(_tuningMode);
  }

  Future<void> startListening() async {
    final granted = await _audioService.requestMicrophonePermission();
    if (!granted) {
      _inputState = AudioInputState.tooNoisy;
      _accuracy = PitchAccuracy.noInput;
      notifyListeners();
      return;
    }

    _isListening = true;
    _inputState = AudioInputState.listening;
    _smoothedFrequency = 0.0;
    _stringLockCandidate = -1;
    _stringLockCount = 0;
    _inTuneCount = 0;
    notifyListeners();

    try {
      await _audioService.startListening(
        onPitchDetected: _handlePitchDetected,
        onNoPitch: _handleNoPitch,
        onAmplitudeUpdate: _handleAmplitudeUpdate,
      );
    } catch (e) {
      _isListening = false;
      _inputState = AudioInputState.tooNoisy;
      notifyListeners();
    }
  }

  void _handleAmplitudeUpdate(double amplitude) {
    final quietThreshold = -50.0 + (_sensitivity * 20);

    if (amplitude < quietThreshold) {
      if (_inputState != AudioInputState.tooQuiet && _inputState != AudioInputState.detected) {
        _inputState = AudioInputState.tooQuiet;
        notifyListeners();
      }
    }
  }

  void _handlePitchDetected(double frequency, double confidence) {
    _detectedFrequency = frequency;
    _inputState = AudioInputState.detected;

    if (_targetFrequencies.isEmpty) {
      _computeTargets();
    }

    const smoothingAlpha = 0.4;
    if (_smoothedFrequency == 0.0) {
      _smoothedFrequency = frequency;
    } else {
      _smoothedFrequency = smoothingAlpha * frequency + (1 - smoothingAlpha) * _smoothedFrequency;
    }

    int nearestIndex = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < _targetFrequencies.length; i++) {
      final diff = (_smoothedFrequency - _targetFrequencies[i]).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearestIndex = i;
      }
    }

    const hysteresisRatio = 0.7;
    const stringSwitchDebounce = 3;

    if (_detectedStringIndex == -1) {
      _detectedStringIndex = nearestIndex;
      _targetFrequency = _targetFrequencies[nearestIndex];
      _stringLockCandidate = -1;
      _stringLockCount = 0;
    } else if (nearestIndex == _detectedStringIndex) {
      _targetFrequency = _targetFrequencies[_detectedStringIndex];
      _stringLockCandidate = -1;
      _stringLockCount = 0;
    } else {
      final diffToCurrent = (_smoothedFrequency - _targetFrequencies[_detectedStringIndex]).abs();

      if (minDiff < diffToCurrent * hysteresisRatio) {
        if (_stringLockCandidate == nearestIndex) {
          _stringLockCount++;
          if (_stringLockCount >= stringSwitchDebounce) {
            _detectedStringIndex = nearestIndex;
            _targetFrequency = _targetFrequencies[nearestIndex];
            _stringLockCandidate = -1;
            _stringLockCount = 0;
          }
        } else {
          _stringLockCandidate = nearestIndex;
          _stringLockCount = 1;
        }
      } else {
        _stringLockCandidate = -1;
        _stringLockCount = 0;
      }
    }

    if (_targetFrequency > 0) {
      _centsDeviation = 1200 * log(_smoothedFrequency / _targetFrequency) / log(2);
      _centsDeviation = _centsDeviation.clamp(-50.0, 50.0);

      final inTuneThreshold = 5.0 + (1 - _sensitivity) * 5;

      if (_centsDeviation.abs() < inTuneThreshold) {
        _accuracy = PitchAccuracy.inTune;
        _inTuneCount++;

        if (_hapticEnabled && _inTuneCount >= 3) {
          HapticFeedback.mediumImpact();
        }
      } else if (_centsDeviation > 0) {
        _accuracy = PitchAccuracy.sharp;
        _inTuneCount = 0;
        if (_hapticEnabled) {
          HapticFeedback.selectionClick();
        }
      } else {
        _accuracy = PitchAccuracy.flat;
        _inTuneCount = 0;
        if (_hapticEnabled) {
          HapticFeedback.selectionClick();
        }
      }
    }

    notifyListeners();
  }

  void _handleNoPitch() {
    _accuracy = PitchAccuracy.noInput;
    if (!_audioService.isListening) {
      _isListening = false;
      _detectedFrequency = 0.0;
      _targetFrequency = 0.0;
      _centsDeviation = 0.0;
    }
    _inputState = AudioInputState.tooQuiet;
    _detectedStringIndex = -1;
    _stringLockCandidate = -1;
    _stringLockCount = 0;
    _inTuneCount = 0;
    notifyListeners();
  }

  void stopListening() {
    _audioService.stopListening();
    _isListening = false;
    _accuracy = PitchAccuracy.noInput;
    _inputState = AudioInputState.listening;
    _detectedFrequency = 0.0;
    _targetFrequency = 0.0;
    _centsDeviation = 0.0;
    _detectedStringIndex = -1;
    _smoothedFrequency = 0.0;
    _stringLockCandidate = -1;
    _stringLockCount = 0;
    _inTuneCount = 0;
    notifyListeners();
  }

  void clearPitch() {
    _detectedFrequency = 0.0;
    _targetFrequency = 0.0;
    _detectedStringIndex = -1;
    _smoothedFrequency = 0.0;
    _stringLockCandidate = -1;
    _stringLockCount = 0;
    _accuracy = PitchAccuracy.noInput;
    _centsDeviation = 0.0;
    _inTuneCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
