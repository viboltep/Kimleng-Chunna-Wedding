import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
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
  String _guestName = 'Guest';
  bool _loading = true;
  static const String _lookupUrl =
      'https://script.google.com/macros/s/AKfycbyZR2Wg5pz69wkRJ-S2v3zxEy8oDgepDeDvwebN6m-FqJjawM48Gi782Ibblk6k1pHThg/exec';

  @override
  void initState() {
    super.initState();
    _loadGuestName();
  }

  Future<void> _loadGuestName() async {
    final eid = Uri.base.queryParameters['eid']?.trim();
    if (eid == null || eid.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    try {
      final uri = Uri.parse('$_lookupUrl?eid=$eid');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final name = (data['name'] ?? 'Guest').toString().trim();
        setState(() {
          _guestName = name.isEmpty ? 'Guest' : name;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

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
                    style: WeddingTextStyles.heading2.copyWith(
                      color: accentColor,
                      fontSize: 36,
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
                  const SizedBox(height: 8),
                  Text(
                    _loading
                        ? 'Loading invitation…'
                        : 'Invitation for: $_guestName',
                    textAlign: TextAlign.center,
                    style: WeddingTextStyles.body.copyWith(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
                          style: WeddingTextStyles.heading2.copyWith(
                            color: accentColor,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'ថ្ងៃអាទិត្យ ទី១ ខែមិនា ឆ្នាំ ២០២៦',
                    textAlign: TextAlign.center,
                    style: WeddingTextStyles.heading3.copyWith(
                      color: accentColor,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ភោជនីយដ្ឋាន មហារមង្គល',
                    textAlign: TextAlign.center,
                    style: WeddingTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                      fontSize: 18,
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
                          const Icon(
                            Iconsax.direct_inbox,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'សូមចុចបើកការអញ្ចើញ',
                            style: GoogleFonts.dangrek(
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
