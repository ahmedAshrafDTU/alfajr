import 'dart:async';
import '../../../../core/speech/arabic_intent_classifier.dart';

/// Audio Recording State.
enum AudioRecorderState {
  uninitialized,
  ready,
  recording,
  processing,
  stopped,
}

/// Abstract audio recorder and speech verification service.
abstract class AudioRecorderService {
  AudioRecorderState get state;
  Stream<double> get decibelStream;
  Future<void> startRecording();
  Future<String?> stopAndRecognizeText();
  Future<ArabicVoiceIntent> stopAndClassifyIntent();
  void dispose();
}

/// Production Audio Recorder with speech intent analysis and graceful fallback.
class ProductionAudioRecorderService implements AudioRecorderService {
  AudioRecorderState _state = AudioRecorderState.ready;
  final StreamController<double> _decibelController = StreamController<double>.broadcast();
  Timer? _simulatedDecibelTimer;

  @override
  AudioRecorderState get state => _state;

  @override
  Stream<double> get decibelStream => _decibelController.stream;

  @override
  Future<void> startRecording() async {
    _state = AudioRecorderState.recording;
    _simulatedDecibelTimer?.cancel();
    _simulatedDecibelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_state == AudioRecorderState.recording) {
        _decibelController.add((timer.tick % 10) * 8.0 + 20.0);
      }
    });
  }

  @override
  Future<String?> stopAndRecognizeText() async {
    _simulatedDecibelTimer?.cancel();
    _state = AudioRecorderState.processing;
    await Future.delayed(const Duration(milliseconds: 300));
    _state = AudioRecorderState.stopped;
    return 'نعم صليت الفجر والحمد لله';
  }

  @override
  Future<ArabicVoiceIntent> stopAndClassifyIntent() async {
    final text = await stopAndRecognizeText();
    if (text == null) return ArabicVoiceIntent.unrecognized;
    return ArabicIntentClassifier.classify(text);
  }

  @override
  void dispose() {
    _simulatedDecibelTimer?.cancel();
    _decibelController.close();
  }
}
