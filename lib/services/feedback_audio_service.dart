import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class FeedbackAudioService {
  FeedbackAudioService._();
  static final FeedbackAudioService instance = FeedbackAudioService._();

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _player.setPlayerMode(PlayerMode.lowLatency);
    await _player.setReleaseMode(ReleaseMode.stop);
    _initialized = true;
  }

  Future<void> _play(String assetPath, {double volume = 0.9}) async {
    await _ensureInitialized();
    await _player.stop();
    await _player.setVolume(volume);
    await _player.play(AssetSource(assetPath));
  }

  Future<void> playCorrect() => _play('audio/sfx/correct.wav', volume: 0.85);

  Future<void> playWrong() => _play('audio/sfx/wrong.wav', volume: 0.85);

  Future<void> playSkip() async {
    try {
      await _play('audio/sfx/skip.wav', volume: 0.74);
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> playComplete() async {
    try {
      await _play('audio/sfx/complete.wav', volume: 0.96);
    } catch (_) {
      await _play('audio/sfx/correct.wav', volume: 0.96);
      await Future<void>.delayed(const Duration(milliseconds: 140));
      await SystemSound.play(SystemSoundType.click);
    }
  }
}
