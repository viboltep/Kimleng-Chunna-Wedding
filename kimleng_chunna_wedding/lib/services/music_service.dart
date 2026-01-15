import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;

  /// Initialize and start playing background music
  Future<void> startBackgroundMusic() async {
    try {
      if (_isInitialized) {
        debugPrint('Music service already initialized');
        return;
      }
      
      debugPrint('Initializing music service...');
      
      // Set audio context for web
      if (kIsWeb) {
        debugPrint('Setting web audio context...');
        await _audioPlayer.setAudioContext(AudioContext());
        debugPrint('Web audio context set successfully');
      }

      // Set volume to a comfortable level (30%)
      debugPrint('Setting volume to 0.3...');
      await _audioPlayer.setVolume(0.3);
      debugPrint('Volume set successfully');
      
      // Set release mode to loop
      debugPrint('Setting release mode to loop...');
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      debugPrint('Release mode set successfully');
      
      // Try to start playing the background music
      debugPrint('Attempting to play music file: assets/music/plov-chivit-rum-knea.mp3');
      try {
        await _audioPlayer.play(AssetSource('assets/music/plov-chivit-rum-knea.mp3'));
        _isPlaying = true;
        debugPrint('🎵 Background music started successfully!');
      } catch (autoplayError) {
        debugPrint('⚠️ Autoplay blocked by browser: $autoplayError');
        debugPrint('Music will start after user interaction');
        // Don't set _isPlaying to true yet - wait for user interaction
      }
      
      _isInitialized = true;
      debugPrint('Music service initialization completed');
    } catch (e) {
      debugPrint('❌ Error initializing background music: $e');
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      debugPrint('Background music stopped');
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      debugPrint('Background music paused');
    } catch (e) {
      debugPrint('Error pausing background music: $e');
    }
  }

  /// Resume background music (also handles first play if autoplay was blocked)
  Future<void> resumeBackgroundMusic() async {
    try {
      if (!_isInitialized) {
        await startBackgroundMusic();
        return;
      }
      
      await _audioPlayer.resume();
      _isPlaying = true;
      debugPrint('Background music resumed');
    } catch (e) {
      debugPrint('Error resuming background music: $e');
      // If resume fails, try to play from start
      try {
        await _audioPlayer.play(AssetSource('assets/music/plov-chivit-rum-knea.mp3'));
        _isPlaying = true;
        debugPrint('Background music started after resume failure');
      } catch (playError) {
        debugPrint('Error playing music: $playError');
      }
    }
  }

  /// Toggle music playback
  Future<void> toggleMusic() async {
    if (_isPlaying) {
      await pauseBackgroundMusic();
    } else {
      await resumeBackgroundMusic();
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      debugPrint('Volume set to: ${volume.clamp(0.0, 1.0)}');
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  /// Get current playing status
  bool get isPlaying => _isPlaying;

  /// Get current volume
  double get volume => _audioPlayer.volume;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isInitialized = false;
      _isPlaying = false;
      debugPrint('Music service disposed');
    } catch (e) {
      debugPrint('Error disposing music service: $e');
    }
  }
}
