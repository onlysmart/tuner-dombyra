import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

enum AudioPermissionStatus { granted, denied, unknown }

class AudioService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _streamSubscription;
  bool _isListening = false;
  AudioPermissionStatus _permissionStatus = AudioPermissionStatus.unknown;
  double _lastAmplitude = -60.0;

  final List<int> _pcmBuffer = [];
  static const _sampleRate = 44100;
  static const _bufferSamples = 4096;
  static const _bufferBytes = _bufferSamples * 2;

  int _chunkCount = 0;

  bool get isListening => _isListening;
  AudioPermissionStatus get permissionStatus => _permissionStatus;
  double get lastAmplitude => _lastAmplitude;

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    _permissionStatus = status.isGranted
        ? AudioPermissionStatus.granted
        : AudioPermissionStatus.denied;
    notifyListeners();
    return status.isGranted;
  }

  Future<void> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    _permissionStatus = status.isGranted
        ? AudioPermissionStatus.granted
        : status.isDenied
            ? AudioPermissionStatus.denied
            : AudioPermissionStatus.unknown;
    notifyListeners();
  }

  Future<void> startListening({
    required void Function(double frequency, double confidence) onPitchDetected,
    required void Function() onNoPitch,
    void Function(double amplitude)? onAmplitudeUpdate,
  }) async {
    if (_permissionStatus != AudioPermissionStatus.granted) {
      final granted = await requestMicrophonePermission();
      if (!granted) {
        onNoPitch();
        return;
      }
    }

    _chunkCount = 0;
    notifyListeners();

    try {
      try { await _recorder.stop(); } catch (_) {}
      _pcmBuffer.clear();
      _isListening = true;

      final config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
      );

      final stream = await _recorder.startStream(config);

      _streamSubscription = stream.listen(
        (data) {
          _pcmBuffer.addAll(data);

          while (_pcmBuffer.length >= _bufferBytes) {
            final chunk = _pcmBuffer.sublist(0, _bufferBytes);
            _pcmBuffer.removeRange(0, _bufferBytes);

            final samples = _bytesToSamples(chunk);
            final rms = _calculateRMS(samples);
            final db = rms > 0 ? 20 * log(rms / 32768.0) / ln10 : -96.0;
            _lastAmplitude = db;

            _chunkCount++;
            if (_chunkCount % 10 == 0) {
              onAmplitudeUpdate?.call(db);
            }

            if (db > -50) {
              final result = _detectPitchFromSamples(samples);
              if (result != null) {
                onPitchDetected(result.frequency, result.confidence);
              } else {
                onNoPitch();
              }
            } else {
              onNoPitch();
            }
          }
        },
        onError: (error) {
          debugPrint('Audio stream error: $error');
          _cleanup();
          onNoPitch();
        },
        onDone: () {
          _cleanup();
          onNoPitch();
        },
      );
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _isListening = false;
      notifyListeners();
      onNoPitch();
    }
  }

  List<double> _bytesToSamples(List<int> bytes) {
    final samples = <double>[];
    for (var i = 0; i < bytes.length - 1; i += 2) {
      final low = bytes[i];
      final high = bytes[i + 1];
      var value = (high << 8) | low;
      if (value >= 32768) value -= 65536;
      samples.add(value / 32768.0);
    }
    return samples;
  }

  double _calculateRMS(List<double> samples) {
    if (samples.isEmpty) return 0;
    var sum = 0.0;
    for (final s in samples) {
      sum += s * s;
    }
    return sqrt(sum / samples.length) * 32768;
  }

  _PitchResult? _detectPitchFromSamples(List<double> samples) {
    return _autocorrelationPitch(samples, _sampleRate);
  }

  _PitchResult? _autocorrelationPitch(List<double> samples, int sampleRate) {
    final n = samples.length;
    if (n < 256) return null;

    final minLag = (sampleRate / 400).ceil();
    final maxLag = (sampleRate / 60).floor();
    if (maxLag >= n || maxLag <= minLag) return null;

    var bestCorrelation = -1.0;
    var bestLag = minLag;

    for (var lag = minLag; lag < maxLag; lag++) {
      var sum = 0.0;
      var normA = 0.0;
      var normB = 0.0;
      for (var i = 0; i < n - lag; i++) {
        final a = samples[i];
        final b = samples[i + lag];
        sum += a * b;
        normA += a * a;
        normB += b * b;
      }
      final denominator = sqrt(normA * normB).toDouble();
      final correlation = denominator > 0 ? sum / denominator : 0.0;
      if (correlation > bestCorrelation) {
        bestCorrelation = correlation;
        bestLag = lag;
      }
    }

    if (bestCorrelation < 0.3) return null;

    final frequency = sampleRate.toDouble() / bestLag;
    if (frequency < 60 || frequency > 400) return null;

    return _PitchResult(frequency, bestCorrelation.clamp(0.0, 1.0));
  }

  Future<Amplitude> getAmplitude() async {
    return _recorder.getAmplitude();
  }

  void _cleanup() {
    _isListening = false;
    _streamSubscription?.cancel();
    _streamSubscription = null;
    try { _recorder.stop(); } catch (_) {}
    notifyListeners();
  }

  void stopListening() {
    _cleanup();
  }

  @override
  void dispose() {
    stopListening();
    _recorder.dispose();
    super.dispose();
  }
}

class _PitchResult {
  final double frequency;
  final double confidence;
  _PitchResult(this.frequency, this.confidence);
}
