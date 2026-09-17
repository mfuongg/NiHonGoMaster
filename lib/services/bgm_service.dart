import 'package:audioplayers/audioplayers.dart';

class BgmService {
  BgmService._();
  static final BgmService instance = BgmService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentAsset;
  double _currentVolume = 0;

  Future<void> _fadeTo(
    double target, {
    Duration duration = const Duration(milliseconds: 900),
  }) async {
    const steps = 9;
    final start = _currentVolume;
    for (var i = 1; i <= steps; i++) {
      final value = start + ((target - start) * i / steps);
      final nextVolume = value < 0
          ? 0.0
          : value > 1
              ? 1.0
              : value;
      await _player.setVolume(nextVolume);
      _currentVolume = nextVolume;
      await Future.delayed(Duration(milliseconds: duration.inMilliseconds ~/ steps));
    }
  }

  Future<void> _fadeOutAndStop() async {
    if (_currentAsset == null) return;
    await _fadeTo(0.0, duration: const Duration(milliseconds: 420));
    await _player.stop();
    _currentAsset = null;
    _currentVolume = 0;
  }

  Future<void> _play(
    String assetPath, {
    double volume = 0.1,
  }) async {
    await _player.setReleaseMode(ReleaseMode.loop);

    if (_currentAsset == assetPath) {
      await _fadeTo(volume, duration: const Duration(milliseconds: 420));
      return;
    }

    if (_currentAsset != null) {
      await _fadeOutAndStop();
    }

    await _player.setVolume(0.0);
    await _player.play(AssetSource(assetPath));
    _currentAsset = assetPath;
    _currentVolume = 0.0;
    await _fadeTo(volume);
  }

  Future<void> playAuthMusic() => _play(
        'audio/login_bgm.mp3',
        volume: 0.10,
      );

  Future<void> playStudyMusic() => _play(
        'audio/study_bgm.mp3',
        volume: 0.08,
      );

  Future<void> stop() async {
    await _fadeOutAndStop();
  }
}
