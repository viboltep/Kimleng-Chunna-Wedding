import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/web_music_service.dart';
import '../theme/wedding_theme.dart';

/// Figma-inspired welcome gate shown before entering the main invitation.
class WelcomeCard extends StatefulWidget {
  const WelcomeCard({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  State<WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<WelcomeCard> {

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF8F2EB); // from Figma frame background
    const accentColor = Color(0xFFB88527); // dominant gold/brown accents
    const secondaryText = Color(0xFF6F4C0B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxCardWidth = constraints.maxWidth < 900
                ? constraints.maxWidth * 0.9
                : 820.0;

            return Container(
              width: maxCardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Khmer headline
                  Text(
                    'សិរីមង្គលអាពាហ៍ពិពាហ៍',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Koulen',
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You are cordially invited to the wedding of',
                    textAlign: TextAlign.center,
                    style: WeddingTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        //Guest Name
                        Text(
                          'លោក ទេព វិបុល',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Koulen',
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'ថ្ងៃអាទិត្យ ទី១ ខែមិនា ឆ្នាំ ២០២៦',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Koulen',
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: accentColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ភោជនីយដ្ឋាន មហារមង្គល',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Moulpali',
                      fontSize: 18,
                      color: secondaryText,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 240,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Start music after user interaction to avoid autoplay block.
                        await WebMusicService().resumeBackgroundMusic();
                        widget.onOpen();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: WeddingTextStyles.button.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/click-tap.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'សូមចុចបើកការអញ្ចើញ',
                            style: const TextStyle(
                              fontFamily: 'Dangrek',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
