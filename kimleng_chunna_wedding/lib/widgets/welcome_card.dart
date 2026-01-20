import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
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

  static const String _lookupUrl =
      'https://script.google.com/macros/s/AKfycbx801jEXTvfWwD0SaCRDfwnyRt-eNQtuAoHT5MWZ2fuo3Pm0s1ukP7rWek3Kvw1qkyQog/exec';

  String _guestName = 'ភ្ញៀវកិត្តិយស';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGuestName();
  }

  Future<void> _loadGuestName() async {
    final code = Uri.base.queryParameters['code']?.trim();
    debugPrint('🔑 Code from URL: "$code"');
    debugPrint('🔑 Full URL: ${Uri.base}');
    debugPrint('🔑 Query parameters: ${Uri.base.queryParameters}');
    
    if (code == null || code.isEmpty) {
      debugPrint('⚠️ No code parameter found in URL');
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    try {
      final uri = Uri.parse(_lookupUrl).replace(queryParameters: {
        'code': code,
      });
      
      // Debug: log the URL being called
      debugPrint('🔍 Fetching guest name from: $uri');
      
      final resp = await http
          .get(uri)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Request timeout');
      });

      if (!mounted) return;

      // Debug: log response details
      debugPrint('📥 Response status: ${resp.statusCode}');
      debugPrint('📥 Response body: ${resp.body}');
      debugPrint('📥 Response headers: ${resp.headers}');

      if (resp.statusCode == 200) {
        String name = '';
        final body = resp.body.trim();
        
        // Skip HTML responses (Google Apps Script sometimes returns HTML error pages or login redirects)
        if (body.startsWith('<!DOCTYPE') || 
            body.startsWith('<html') || 
            body.startsWith('<HTML') ||
            body.contains('ServiceLogin') ||
            body.contains('Moved Temporarily')) {
          debugPrint('⚠️ Received HTML response (likely login redirect). Google Apps Script needs to be deployed as a web app with public access.');
          name = 'ភ្ញៀវកិត្តិយស';
        } else {
          try {
            // Try to parse as JSON first
            final data = json.decode(body);
            debugPrint('✅ Parsed JSON: $data');
            
            if (data is Map<String, dynamic>) {
              debugPrint('📋 JSON keys: ${data.keys.toList()}');
              debugPrint('📋 JSON values: ${data.values.toList()}');
              
              // Check for error responses first
              if (data.containsKey('error')) {
                final errorMsg = data['error']?.toString() ?? '';
                debugPrint('⚠️ API returned error: $errorMsg');
                // If error says missing code, that means code wasn't passed - use default
                if (errorMsg.toLowerCase().contains('missing code') || 
                    errorMsg.toLowerCase().contains('code')) {
                  name = 'ភ្ញៀវកិត្តិយស';
                } else {
                  // Other errors - still try to get name if available
                  name = 'ភ្ញៀវកិត្តិយស';
                }
              } else {
                // Check for 'name' field (case-insensitive, check multiple variations)
                String? foundName;
                final possibleKeys = ['name', 'guest', 'guestname', 'guest_name', 'guestName', 'Name', 'Guest'];
                
                for (var key in possibleKeys) {
                  if (data.containsKey(key)) {
                    final value = data[key];
                    if (value != null) {
                      foundName = value.toString().trim();
                      if (foundName.isNotEmpty) {
                        debugPrint('✅ Found name in field "$key": $foundName');
                        break;
                      }
                    }
                  }
                }
                
                // If not found with exact keys, search case-insensitively
                if (foundName == null || foundName.isEmpty) {
                  for (var entry in data.entries) {
                    final keyLower = entry.key.toLowerCase();
                    if ((keyLower.contains('name') || keyLower.contains('guest')) &&
                        entry.value is String && 
                        entry.value.toString().trim().isNotEmpty) {
                      foundName = entry.value.toString().trim();
                      debugPrint('✅ Found name in field "${entry.key}": $foundName');
                      break;
                    }
                  }
                }
                
                // Last resort: use first non-error string value
                if (foundName == null || foundName.isEmpty) {
                  for (var entry in data.entries) {
                    if (entry.key.toLowerCase() != 'error' && 
                        entry.value is String && 
                        entry.value.toString().trim().isNotEmpty) {
                      foundName = entry.value.toString().trim();
                      debugPrint('✅ Using first string value from field "${entry.key}": $foundName');
                      break;
                    }
                  }
                }
                
                name = foundName ?? '';
              }
            } else if (data is String) {
              name = data.trim();
              debugPrint('✅ Response is plain string: $name');
            } else if (data is List && data.isNotEmpty) {
              // Handle array responses
              final firstItem = data.first;
              if (firstItem is Map<String, dynamic>) {
                name = firstItem['name']?.toString().trim() ?? 
                       firstItem['guest']?.toString().trim() ?? '';
              } else if (firstItem is String) {
                name = firstItem.trim();
              }
              debugPrint('✅ Response is array, using first item: $name');
            } else {
              // If not JSON, use body as text
              name = body;
              debugPrint('✅ Using body as plain text: $name');
            }
          } catch (e) {
            // If JSON parsing fails, use body as plain text
            debugPrint('⚠️ JSON parse error: $e, using body as text');
            name = body;
          }
        }

        if (name.isEmpty) {
          debugPrint('⚠️ Name is empty, using default');
          name = 'ភ្ញៀវកិត្តិយស';
        }

        debugPrint('✅ Final guest name: $name');

        if (mounted) {
          setState(() {
            _guestName = name;
            _loading = false;
          });
        }
      } else {
        // Non-200 status code
        debugPrint('❌ Non-200 status code: ${resp.statusCode}');
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      // Handle any errors (timeout, network, etc.)
      debugPrint('❌ Error loading guest name: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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
                    style: const TextStyle(
                      fontFamily: 'Koulen',
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: accentColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You are cordially invited to the wedding',
                    textAlign: TextAlign.center,
                    style: WeddingTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        //Guest Name with Shimmer
                        _loading
                            ? Shimmer.fromColors(
                                baseColor: accentColor.withValues(alpha: 0.2),
                                highlightColor: accentColor.withValues(alpha: 0.4),
                                period: const Duration(milliseconds: 1200),
                                child: Container(
                                  width: 200,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )
                            : Text(
                                _guestName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Battambang',
                                  fontSize: 24,
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
                      fontFamily: 'Battambang',
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
