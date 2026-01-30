// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class WebMusicService {
  static final WebMusicService _instance = WebMusicService._internal();
  factory WebMusicService() => _instance;
  WebMusicService._internal();

  html.AudioElement? _audioElement;
  StreamSubscription<html.Event>? _clickSubscription;
  StreamSubscription<html.Event>? _touchStartSubscription;
  StreamSubscription<html.Event>? _scrollSubscription;
  StreamSubscription<html.KeyboardEvent>? _keyDownSubscription;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _listenersAttached = false;
  static const String _audioFileName = 'plov-chivit-rum-knea.mp3';
  static final String _encodedAudioFileName = Uri.encodeComponent(_audioFileName);

  /// Initialize and start playing background music
  Future<void> startBackgroundMusic() async {
    try {
      if (_isInitialized) {
        debugPrint('Music service already initialized');
        return;
      }

      debugPrint('Initializing web music service...');

      // Create HTML5 audio element
      _audioElement = html.AudioElement();

      // Use URL-encoded filename to avoid issues with Unicode in web asset URLs.
      // Flutter web serves assets under "assets/<declared path>"
      // Our pubspec declares "assets/music/", so the built URL becomes
      // "assets/assets/music/...". We keep both primary and legacy paths and
      // try the primary one first.
      final String primaryAudioPath =
          'assets/assets/music/$_encodedAudioFileName';
      final String legacyAudioPath =
          'assets/music/$_encodedAudioFileName';

      _audioElement!.src = primaryAudioPath;
      debugPrint('🎵 Using audio path: $primaryAudioPath');

      // Add comprehensive error handling
      _audioElement!.onError.listen((event) {
        debugPrint('❌ Audio error with primary path: $primaryAudioPath');
        debugPrint('❌ Error details: $event');

        // Try alternative paths
        _tryAlternativePaths(primaryAudioPath, legacyAudioPath);
      });

      _audioElement!.volume = 0.3; // 30% volume
      _audioElement!.loop = true;
      _audioElement!.preload = 'auto';
      _audioElement!.autoplay = false; // avoid autoplay errors on web

      // Add event listeners
      _audioElement!.onLoadedData.listen((_) {
        debugPrint('🎵 Music file loaded successfully!');
      });

      _audioElement!.onCanPlay.listen((_) {
        debugPrint('🎵 Music can play!');
      });

      _audioElement!.onError.listen((event) {
        debugPrint('❌ Audio error: $event');
      });

      _audioElement!.onPlay.listen((_) {
        debugPrint('▶️ Music started playing');
        _isPlaying = true;
      });

      _audioElement!.onPause.listen((_) {
        debugPrint('⏸️ Music paused');
        _isPlaying = false;
      });

      _audioElement!.onEnded.listen((_) {
        debugPrint('🔚 Music ended');
        _isPlaying = false;
      });

      // Do not attempt autoplay; rely on explicit user interaction
      _isPlaying = false;
      _setupUserInteractionListeners();

      _isInitialized = true;
      debugPrint('Web music service initialization completed');
    } catch (e) {
      debugPrint('❌ Error initializing web music service: $e');
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      if (_audioElement != null) {
        _audioElement!.pause();
        _audioElement!.currentTime = 0;
        _isPlaying = false;
        debugPrint('🛑 Background music stopped');
      }
    } catch (e) {
      debugPrint('❌ Error stopping background music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      if (_audioElement != null) {
        _audioElement!.pause();
        _isPlaying = false;
        debugPrint('⏸️ Background music paused');
      }
    } catch (e) {
      debugPrint('❌ Error pausing background music: $e');
    }
  }

  /// Resume background music (also handles first play if autoplay was blocked)
  Future<void> resumeBackgroundMusic() async {
    try {
      if (!_isInitialized) {
        debugPrint(
          '🔄 Music service not initialized, starting initialization...',
        );
        await startBackgroundMusic();
        // Fall through to play (user just triggered this from Open Invitation)
      }

      if (_audioElement != null) {
        debugPrint('🎵 Attempting to play music...');
        await _audioElement!.play();
        _isPlaying = true;
        debugPrint('▶️ Background music resumed successfully!');
        await _removeUserInteractionListeners();
      } else {
        debugPrint('❌ Audio element is null');
      }
    } catch (e) {
      debugPrint('❌ Error resuming background music: $e');
      // Try to recreate the audio element
      try {
        debugPrint('🔄 Attempting to recreate audio element...');
        _audioElement = html.AudioElement();
        _audioElement!.src = 'assets/music/$_encodedAudioFileName';
        _audioElement!.volume = 0.3;
        _audioElement!.loop = true;
        final playResult = _audioElement!.play();
        await playResult;
              _isPlaying = true;
        debugPrint('🎵 Music started with recreated audio element!');
        await _removeUserInteractionListeners();
      } catch (recreateError) {
        debugPrint('❌ Failed to recreate audio element: $recreateError');
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
      if (_audioElement != null) {
        _audioElement!.volume = volume.clamp(0.0, 1.0);
        debugPrint('🔊 Volume set to: ${volume.clamp(0.0, 1.0)}');
      }
    } catch (e) {
      debugPrint('❌ Error setting volume: $e');
    }
  }

  /// Get current playing status
  bool get isPlaying => _isPlaying;

  /// Get current volume
  double get volume => _audioElement?.volume.toDouble() ?? 0.0;

  /// Set up user interaction listeners to start music
  void _setupUserInteractionListeners() {
    if (_listenersAttached) {
      return;
    }

    debugPrint('🔧 Setting up user interaction listeners...');
    _listenersAttached = true;

    Future<void> handleInteraction(String type) async {
      if (!_isPlaying && _audioElement != null) {
        debugPrint('👆 $type interaction detected, starting music...');
        try {
          await resumeBackgroundMusic();
        } catch (e) {
          debugPrint('❌ Error during $type interaction resume: $e');
        }
      }
    }

    _clickSubscription = html.document.onClick.listen((_) {
      handleInteraction('Click');
    });
    _touchStartSubscription = html.document.onTouchStart.listen((_) {
      handleInteraction('Touch');
    });
    _scrollSubscription = html.document.onScroll.listen((_) {
      handleInteraction('Scroll');
    });
    _keyDownSubscription = html.document.onKeyDown.listen((_) {
      handleInteraction('Key');
    });
  }

  /// Try alternative audio paths if the first one fails
  void _tryAlternativePaths(String primaryPath, String legacyPath) {
    if (_audioElement == null) return;

    List<String> alternativePaths = [
      primaryPath,
      legacyPath,
      // Package-style path used when assets are bundled differently
      'packages/kimleng_chunna_wedding/assets/music/$_encodedAudioFileName',
    ];

    for (String path in alternativePaths) {
      debugPrint('🔄 Trying alternative path: $path');
      _audioElement!.src = path;

      // Add a small delay to test if this path works
      Future.delayed(Duration(milliseconds: 100), () {
        if (_audioElement != null &&
            _audioElement!.networkState == html.MediaElement.HAVE_METADATA) {
          debugPrint('✅ Audio path working: $path');
          return;
        }
      });
    }
  }

  Future<void> _removeUserInteractionListeners() async {
    if (!_listenersAttached) {
      return;
    }

    await _clickSubscription?.cancel();
    await _touchStartSubscription?.cancel();
    await _scrollSubscription?.cancel();
    await _keyDownSubscription?.cancel();
    _clickSubscription = null;
    _touchStartSubscription = null;
    _scrollSubscription = null;
    _keyDownSubscription = null;
    _listenersAttached = false;
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      if (_audioElement != null) {
        _audioElement!.pause();
        _audioElement = null;
      }
      await _removeUserInteractionListeners();
      _isInitialized = false;
      _isPlaying = false;
      debugPrint('🗑️ Web music service disposed');
    } catch (e) {
      debugPrint('❌ Error disposing web music service: $e');
    }
  }
}
