import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Animated music button with audio visualization effect.
/// Shows animated bars when music is playing.
class AnimatedMusicButton extends StatefulWidget {
  const AnimatedMusicButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
  });

  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  State<AnimatedMusicButton> createState() => _AnimatedMusicButtonState();
}

class _AnimatedMusicButtonState extends State<AnimatedMusicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const List<double> _phases = [0.0, 0.15, 0.3, 0.45, 0.6, 0.75];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    if (widget.isPlaying) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AnimatedMusicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startAnimation();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _stopAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _stopAnimation() {
    _controller.stop();
    _controller.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB88527);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
      child: Material(
        color: gold,
        elevation: 4,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: Colors.white.withValues(alpha: 0.25),
          highlightColor: Colors.white.withValues(alpha: 0.12),
          onTap: widget.onPressed,
          child: SizedBox(
            width: 52,
            height: 52,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isPlaying) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Orange-red gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF7B5C),
                  Color(0xFFE65C4C),
                ],
              ),
            ),
          ),
          // Audio visualizer bars and pause icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Left side bars
              ...List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: _AudioBar(
                    controller: _controller,
                    phase: _phases[index],
                    color: Colors.white,
                  ),
                );
              }),
              // Pause icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 4,
                    height: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 4,
                    height: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              // Right side bars
              ...List.generate(3, (index) {
                final barIndex = index + 3;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: _AudioBar(
                    controller: _controller,
                    phase: _phases[barIndex],
                    color: Colors.white,
                  ),
                );
              }),
            ],
          ),
        ],
      );
    }
    
    // Static play icon
    return Center(
      child: SvgPicture.asset(
        'assets/icons/play.svg',
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

/// Custom wave curve for audio visualization animation
/// Animated audio bar for visualization
class _AudioBar extends StatelessWidget {
  const _AudioBar({
    required this.controller,
    required this.phase,
    required this.color,
  });

  final AnimationController controller;
  final double phase;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + phase) % 1.0;
        final wave = 0.5 - 0.5 * math.cos(t * math.pi * 2);
        final height = 12 * wave.clamp(0.3, 1.0);
        return Container(
          width: 2,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
    );
  }
}