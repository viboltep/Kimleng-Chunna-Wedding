import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../theme/wedding_theme.dart';
import 'heart_shape.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _scrollController;
  late Timer _countdownTimer;
  Duration _timeUntilWedding = Duration.zero;

  @override
  void initState() {
    super.initState();
    
    // Initialize countdown
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
    
    // Floating animation controller
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Scroll indicator animation controller
    _scrollController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final weddingDate = DateTime(2026, 3, 1);
    final difference = weddingDate.difference(now);
    
    if (mounted) {
      setState(() {
        _timeUntilWedding = difference;
      });
    }
  }

  String _formatCountdown() {
    final days = _timeUntilWedding.inDays;
    final hours = _timeUntilWedding.inHours % 24;
    final minutes = _timeUntilWedding.inMinutes % 60;
    final seconds = _timeUntilWedding.inSeconds % 60;
    
    if (days > 0) {
      return '$days days, $hours hours, $minutes minutes';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes, $seconds seconds';
    } else if (minutes > 0) {
      return '$minutes minutes, $seconds seconds';
    } else {
      return '$seconds seconds';
    }
  }

  Future<void> _addToCalendar() async {
    final weddingDate = DateTime(2026, 3, 1, 14, 0); // March 1st, 2026 at 2:00 PM
    final endDate = DateTime(2026, 3, 1, 22, 0); // March 1st, 2026 at 10:00 PM
    
    // Format dates for calendar URL
    final startDateStr = '${weddingDate.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0]}Z';
    final endDateStr = '${endDate.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0]}Z';
    
    // Create Google Calendar URL
    final title = Uri.encodeComponent('Kimleng & Chunna Wedding');
    final details = Uri.encodeComponent('Join us in celebrating the wedding of Kimleng & Chunna!\n\nCeremony: 2:00 PM\nReception: 6:00 PM\n\nWe can\'t wait to celebrate with you!');
    final location = Uri.encodeComponent('Wedding Venue, Phnom Penh, Cambodia');
    
    final googleCalendarUrl = 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=$startDateStr/$endDateStr&details=$details&location=$location';
    
    try {
      if (await canLaunchUrl(Uri.parse(googleCalendarUrl))) {
        await launchUrl(Uri.parse(googleCalendarUrl), mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Show a snackbar with event details
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Wedding: March 1st, 2026 at 2:00 PM'),
              backgroundColor: WeddingColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open calendar. Please add manually: March 1st, 2026 at 2:00 PM'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _floatingController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            WeddingColors.primary.withOpacity(0.05),
            WeddingColors.secondary.withOpacity(0.1),
            WeddingColors.accent.withOpacity(0.15),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background elements
          Positioned(
            top: screenHeight * 0.1,
            left: 20,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingController.value * -20),
                  child: HeartShape(
                    size: 120,
                    color: WeddingColors.gold,
                    borderColor: WeddingColors.gold,
                    opacity: 0.1,
                    borderWidth: 1,
                  ).animate()
                      .fadeIn(duration: 2.seconds)
                      .scale(begin: const Offset(0.5, 0.5))
                      .then()
                      .shimmer(duration: 3.seconds),
                );
              },
            ),
          ),
          
          Positioned(
            top: screenHeight * 0.2,
            right: 20,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingController.value * 15),
                  child: HeartShape(
                    size: 80,
                    color: WeddingColors.primary,
                    borderColor: WeddingColors.primary,
                    opacity: 0.1,
                    borderWidth: 1,
                  ).animate()
                      .fadeIn(duration: 2.5.seconds, delay: 500.ms)
                      .scale(begin: const Offset(0.3, 0.3))
                      .then()
                      .shimmer(duration: 2.seconds),
                );
              },
            ),
          ),
          
          Positioned(
            bottom: screenHeight * 0.15,
            left: 30,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingController.value * -10),
                  child: HeartShape(
                    size: 60,
                    color: WeddingColors.secondary,
                    borderColor: WeddingColors.secondary,
                    opacity: 0.15,
                    borderWidth: 1,
                  ).animate()
                      .fadeIn(duration: 3.seconds, delay: 1.seconds)
                      .scale(begin: const Offset(0.2, 0.2))
                      .then()
                      .shimmer(duration: 2.5.seconds),
                );
              },
            ),
          ),
          
          // Additional floating elements
          Positioned(
            top: screenHeight * 0.4,
            left: 50,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingController.value * -30),
                  child: HeartShape(
                    size: 40,
                    color: WeddingColors.accent,
                    borderColor: WeddingColors.accent,
                    opacity: 0.2,
                    borderWidth: 1,
                  ).animate()
                      .fadeIn(duration: 2.seconds, delay: 1.5.seconds)
                      .scale(begin: const Offset(0.1, 0.1)),
                );
              },
            ),
          ),
          
          Positioned(
            top: screenHeight * 0.6,
            right: 60,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingController.value * 25),
                  child: HeartShape(
                    size: 30,
                    color: WeddingColors.gold,
                    borderColor: WeddingColors.gold,
                    opacity: 0.15,
                    borderWidth: 1,
                  ).animate()
                      .fadeIn(duration: 2.5.seconds, delay: 2.seconds)
                      .scale(begin: const Offset(0.2, 0.2)),
                );
              },
            ),
          ),
          
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decorative line
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scaleX: 1.0 + (_pulseController.value * 0.2),
                        child: Container(
                          width: 100,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [WeddingColors.gold, WeddingColors.primary],
                            ),
                          ),
                        ),
                      ).animate()
                          .fadeIn(duration: 1.seconds)
                          .scaleX(begin: 0)
                          .then()
                          .shimmer(duration: 3.seconds);
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Invitation text
                  Text(
                    'Together with their families',
                    style: WeddingTextStyles.caption,
                    textAlign: TextAlign.center,
                  ).animate()
                      .fadeIn(delay: 500.ms, duration: 1.seconds)
                      .slideY(begin: 0.3),
                  
                  const SizedBox(height: 40),
                  
                  // Couple names
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.05),
                        child: Text(
                          'Kimleng\n& Chunna',
                          style: WeddingTextStyles.heading1.copyWith(
                            fontSize: 36,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate()
                          .fadeIn(delay: 1.seconds, duration: 1.5.seconds)
                          .slideY(begin: 0.5)
                          .then()
                          .shimmer(duration: 2.seconds);
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Wedding invitation text
                  Text(
                    'invite you to celebrate their wedding',
                    style: WeddingTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ).animate()
                      .fadeIn(delay: 1.5.seconds, duration: 1.seconds)
                      .slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Date
                  Text(
                    'March 1th, 2026',
                    style: WeddingTextStyles.heading3.copyWith(
                      color: WeddingColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                      .fadeIn(delay: 2.seconds, duration: 1.seconds)
                      .slideY(begin: 0.3),
                  
                  const SizedBox(height: 15),
                  
                  // Countdown Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: WeddingColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: WeddingColors.gold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _formatCountdown(),
                      style: WeddingTextStyles.body.copyWith(
                        color: WeddingColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate()
                      .fadeIn(delay: 2.5.seconds, duration: 1.seconds)
                      .slideY(begin: 0.3)
                      .then()
                      .shimmer(duration: 2.seconds),
                  
                  const SizedBox(height: 20),
                  SizedBox(height: 20),
                  // Add to Calendar Button
                  ElevatedButton.icon(
                    onPressed: _addToCalendar,
                    icon: Icon(
                      Icons.calendar_today,
                      color: WeddingColors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Add to Calendar',
                      style: WeddingTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WeddingColors.primary,
                      foregroundColor: WeddingColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 3,
                    ),
                  ).animate()
                      .fadeIn(delay: 3.seconds, duration: 1.seconds)
                      .slideY(begin: 0.3)
                      .then()
                      .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 1.seconds)
                      .then()
                      .scale(begin: const Offset(1.05, 1.05), end: const Offset(1.0, 1.0), duration: 1.seconds),
                  
                  const SizedBox(height: 15),
                  
                  // Scroll indicator
                  AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _scrollController.value * 10),
                        child: Column(
                          children: [
                            Text(
                              'Scroll to continue',
                              style: WeddingTextStyles.small,
                            ),
                            const SizedBox(height: 10),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: WeddingColors.textSecondary,
                              size: 24,
                            ),
                          ],
                        ),
                      ).animate()
                          .fadeIn(delay: 2.5.seconds, duration: 1.seconds)
                          .slideY(begin: 0.3);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}