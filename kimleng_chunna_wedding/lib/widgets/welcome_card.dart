import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../constants/assets.dart';
import '../services/web_music_service.dart';

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
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Request timeout after 30 seconds');
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
      
      // Check if it's a timeout exception
      if (e is TimeoutException) {
        debugPrint('⏱️ Request timed out. Using default guest name.');
      }
      
      if (mounted) {
        setState(() {
          _loading = false;
          // Keep default guest name on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB88527);
    const warmBrown = Color(0xFF6F4C0B);
    const deepBrown = Color(0xFF2C1810);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF9F4),
              Color(0xFFF8F0E6),
              Color(0xFFF5EBDE),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 400;
              final cardPadding = isNarrow ? 20.0 : 32.0;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - MediaQuery.paddingOf(context).vertical),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        //const SizedBox(height: 24),
                        // Decorative top florals
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     _decoFlower(Assets.flower1),
                        //     _decoFlower(Assets.flower2),
                        //   ],
                        // ),
                        const SizedBox(height: 16),
                        // Invitation card
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isNarrow ? 16 : 40),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 440),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: 36),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withValues(alpha: 0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 32,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                              border: Border.all(
                                color: gold.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Gold accent line
                                Container(
                                  width: 48,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: gold,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'សិរីមង្គលអាពាហ៍ពិពាហ៍',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Koulen',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                    color: gold,
                                    height: 1.35,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'You are cordially invited to the wedding',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Battambang',
                                    fontSize: isNarrow ? 13 : 14,
                                    color: warmBrown,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Decorative divider
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _dividerLine(gold),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        '◆',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: gold.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ),
                                    _dividerLine(gold),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Guest name
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: gold.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: gold.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: _loading
                                      ? Shimmer.fromColors(
                                          baseColor: gold.withValues(alpha: 0.2),
                                          highlightColor: gold.withValues(alpha: 0.4),
                                          period: const Duration(milliseconds: 1200),
                                          child: Container(
                                            width: 180,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: gold.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          _guestName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: 'Battambang',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: deepBrown,
                                            height: 1.35,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'ថ្ងៃអាទិត្យ ទី១ ខែមិនា ឆ្នាំ ២០២៦',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Koulen',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: gold,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ភោជនីយដ្ឋាន មហារមង្គល',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Battambang',
                                    fontSize: isNarrow ? 16 : 18,
                                    color: warmBrown,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () async {
                                      await WebMusicService().resumeBackgroundMusic();
                                      if (context.mounted) widget.onOpen();
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: gold,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                      shadowColor: gold.withValues(alpha: 0.4),
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
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _decoFlower(String path) {
    return Opacity(
      opacity: 0.55,
      child: Image.asset(
        path,
        width: 72,
        height: 72,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _dividerLine(Color color) {
    return Container(
      width: 40,
      height: 1,
      color: color.withValues(alpha: 0.4),
    );
  }
}
