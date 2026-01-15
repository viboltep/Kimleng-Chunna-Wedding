import 'package:flutter/material.dart';
import '../services/web_music_service.dart';
import '../theme/wedding_theme.dart';

/// Reusable floating music toggle button.
class MusicToggleButton extends StatefulWidget {
  const MusicToggleButton({super.key, this.bottomPadding = 8});

  final double bottomPadding;

  @override
  State<MusicToggleButton> createState() => _MusicToggleButtonState();
}

class _MusicToggleButtonState extends State<MusicToggleButton> {
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _playing = WebMusicService().isPlaying;
  }

  Future<void> _toggle() async {
    await WebMusicService().toggleMusic();
    setState(() {
      _playing = WebMusicService().isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      child: FloatingActionButton.extended(
        onPressed: _toggle,
        backgroundColor: const Color(0xFFB88527),
        icon: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
        label: Text(
          _playing ? 'Pause music' : 'Play music',
          style: WeddingTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
