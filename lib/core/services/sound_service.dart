import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playCelebration() async {
    try {
      if (kDebugMode) {
        print('🎁 Playing celebration sound effect...');
      }
      await _player.stop(); // Reset if already playing
      await _player.play(AssetSource('sounds/celebration.mp3'));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error playing celebration sound: $e');
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
}
