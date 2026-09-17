import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    await _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('ja-JP');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.42);
    _isInitialized = true;
  }

  Future<void> speakJapanese(
    String text, {
    double rate = 0.42,
  }) async {
    await _ensureInitialized();
    await _tts.stop();
    await _tts.setLanguage('ja-JP');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(rate.clamp(0.2, 1.5));
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _ensureInitialized();
    await _tts.stop();
  }
}
