import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/assets.dart';
import '../services/web_music_service.dart';
import '../theme/wedding_theme.dart';
import '../utils/responsive.dart';
import 'wedding_agenda_section.dart';
import 'map_embed_stub.dart'
    if (dart.library.html) 'map_embed_web.dart'
    as map_embed;

const List<String> _galleryImages = [
  Assets.photo1,
  Assets.photo2,
  Assets.photo3,
  Assets.photo4,
  Assets.photo5,
  Assets.photo6,
  Assets.photo7,
  Assets.photo8,
  Assets.photo9,
  Assets.photo10,
];

/// Shimmer widget for image loading placeholder
class _ShimmerImage extends StatelessWidget {
  const _ShimmerImage({
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
      ),
    );
  }
}

class _ShimmerAvatar extends StatefulWidget {
  const _ShimmerAvatar({
    required this.asset,
    required this.radius,
  });

  final String asset;
  final double radius;

  @override
  State<_ShimmerAvatar> createState() => _ShimmerAvatarState();
}

class _ShimmerAvatarState extends State<_ShimmerAvatar> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedOpacity(
            opacity: _loaded ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ClipOval(
            child: Image.asset(
              widget.asset,
              fit: BoxFit.cover,
              width: size,
              height: size,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame != null && !_loaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _loaded = true);
                  });
                }
                return child;
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Image widget with shimmer loading effect
class _ShimmerImageAsset extends StatefulWidget {
  const _ShimmerImageAsset({
    required this.imagePath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String imagePath;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  State<_ShimmerImageAsset> createState() => _ShimmerImageAssetState();
}

class _ShimmerImageAssetState extends State<_ShimmerImageAsset> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isLoading)
          _ShimmerImage(
            width: widget.width,
            height: widget.height,
            borderRadius: widget.borderRadius,
          ),
        Image.asset(
          widget.imagePath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              if (_isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                });
              }
              return child;
            }
            return _ShimmerImage(
              width: widget.width,
              height: widget.height,
              borderRadius: widget.borderRadius,
            );
          },
        ),
      ],
    );
  }
}

/// Desktop-first home screen aligned to the Figma “Home” frame (11:51).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _playing = false;
  Timer? _countdownTimer;
  String _countdown = '';
  ({int days, int hours, int minutes, int seconds})? _countdownParts;

  static void openImageViewer(
    BuildContext context,
    List<String> images,
    int startIndex,
  ) {
    final controller = PageController(initialPage: startIndex);
    int currentIndex = startIndex;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            void goTo(int index) {
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            }

            final screenWidth = MediaQuery.of(dialogContext).size.width;
            final screenHeight = MediaQuery.of(dialogContext).size.height;
            final isNarrow = screenWidth < 700;
            final maxWidth = isNarrow ? screenWidth : 720.0;
            final viewportHeight = isNarrow
                ? (screenHeight * 0.9).clamp(360.0, screenHeight)
                : (screenHeight * 0.8).clamp(320.0, 620.0);

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.95),
                      ),
                    ),
                    PageView.builder(
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (idx) =>
                          setState(() => currentIndex = idx),
                      itemCount: images.length,
                      itemBuilder: (context, idx) => Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isNarrow ? screenWidth : maxWidth,
                            maxHeight: viewportHeight,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: Colors.black,
                              child: Image.asset(
                                images[idx],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 24,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    Positioned(
                      bottom: 18,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'រូបភាព ${currentIndex + 1} / ${images.length}',
                          style: WeddingTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (!isNarrow)
                      Positioned(
                        left: 8,
                        child: IconButton(
                          iconSize: 34,
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          onPressed: currentIndex > 0
                              ? () => goTo(currentIndex - 1)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                      ),
                    if (!isNarrow)
                      Positioned(
                        right: 8,
                        child: IconButton(
                          iconSize: 34,
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          onPressed: currentIndex < _galleryImages.length - 1
                              ? () => goTo(currentIndex + 1)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _playing = WebMusicService().isPlaying;
    _startCountdown();
    // Ensure music starts when arriving on Home after user interaction.
    WebMusicService().resumeBackgroundMusic().then((_) {
      setState(() {
        _playing = WebMusicService().isPlaying;
      });
    });
  }

  Future<void> _toggleMusic() async {
    await WebMusicService().toggleMusic();
    setState(() {
      _playing = WebMusicService().isPlaying;
    });
  }

  void _startCountdown() {
    _updateCountdown();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final target = DateTime(2026, 3, 1, 16, 0);
    final now = DateTime.now();
    final diff = target.difference(now);

    if (!mounted) return;

    if (diff.isNegative) {
      setState(() {
        _countdown = 'It\'s celebration time!';
        _countdownParts = null;
      });
      _countdownTimer?.cancel();
      return;
    }

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    setState(() {
      _countdownParts = (
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
      _countdown = '';
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8F2EB); // Frame background from Figma
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: _GlassMusicButton(
        playing: _playing,
        onPressed: _toggleMusic,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: ResponsiveContainer(
              maxWidth: 1200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroInvite(
                    countdownParts: _countdownParts,
                    celebrationText: _countdown,
                  ),
                  const SizedBox(height: 48),
                  const WeddingAgendaSection(),
                  const SizedBox(height: 48),
                  _MapBlessingRow(),
                  const SizedBox(height: 48),
                  _GalleryCollage(
                    onImageTap: (index) =>
                        _HomeScreenState.openImageViewer(context, _galleryImages, index),
                  ),
                  const SizedBox(height: 48),
                  _LoveStorySection(),

                  const SizedBox(height: 48),
                  _ParentMessages(),
                  const SizedBox(height: 48),

                  _BottomNote(),
                  _FooterNote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroInvite extends StatelessWidget {
  const _HeroInvite({
    required this.countdownParts,
    required this.celebrationText,
  });

  final ({int days, int hours, int minutes, int seconds})? countdownParts;
  final String celebrationText;
  @override
  Widget build(BuildContext context) {
    final viewHeight = MediaQuery.of(context).size.height;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: BoxConstraints(minHeight: viewHeight * 0.95),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;
            final flowerSize = isNarrow ? 100.0 : 400.0;
            final horizontalPadding = isNarrow ? 60.0 : 100.0;

            return Stack(
              children: [
                // Bottom left flower - positioned at bottom of container
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Transform.translate(
                      offset: Offset(
                        isNarrow ? -flowerSize * 0.2 : -flowerSize * 0.2,
                        0,
                      ),
                      child: Image.asset(
                        Assets.flower1,
                        width: flowerSize,
                        height: flowerSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // Bottom right flower - positioned at bottom of container
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.translate(
                      offset: Offset(
                        isNarrow ? flowerSize * 0.2 : flowerSize * 0.2,
                        0,
                      ),
                      child: Transform.flip(
                        flipX: true,
                        child: Image.asset(
                          Assets.flower1,
                          width: flowerSize,
                          height: flowerSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                // Main content
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 700;
                            if (isNarrow) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _ShimmerAvatar(
                                    asset: Assets.photo8,
                                    radius: 80,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'សៀង គឹមឡេង',
                                    textAlign: TextAlign.center,
                                    style: WeddingTextStyles.heading2.copyWith(
                                      color: const Color(0xFFB88527),
                                      fontSize: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'និង',
                                    textAlign: TextAlign.center,
                                    style: WeddingTextStyles.body.copyWith(
                                      color: const Color(0xFF6F4C0B),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'លឹម ជូណា',
                                    textAlign: TextAlign.center,
                                    style: WeddingTextStyles.heading2.copyWith(
                                      color: const Color(0xFFB88527),
                                      fontSize: 26,
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'សៀង គឹមឡេង',
                                    textAlign: TextAlign.center,
                                    style: WeddingTextStyles.heading2.copyWith(
                                      color: const Color(0xFFB88527),
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                _ShimmerAvatar(
                                  asset: Assets.photo8,
                                  radius: 100,
                                ),
                                const SizedBox(width: 32),
                                Flexible(
                                  child: Text(
                                    'លឹម ជូណា',
                                    textAlign: TextAlign.center,
                                    style: WeddingTextStyles.heading2.copyWith(
                                      color: const Color(0xFFB88527),
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ថ្ងៃអាទិត្យ ទី១ ខែមិនា ឆ្នាំ ២០២៦',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Dangrek',
                                fontSize: 22,
                                color: Color(0xFFB88527),
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 16),
                            Text(
                              'ភោជនីយដ្ឋាន មហារមង្គល',
                              textAlign: TextAlign.center,
                              style: WeddingTextStyles.heading3.copyWith(
                                color: const Color(0xFF6F4C0B),
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 32),
                            if (countdownParts != null)
                              _CountdownRow(parts: countdownParts!)
                            else if (celebrationText.isNotEmpty)
                              Text(
                                celebrationText,
                                textAlign: TextAlign.center,
                                style: WeddingTextStyles.heading3.copyWith(
                                  color: const Color(0xFF6F4C0B),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            const SizedBox(height: 32),
                            _CalendarButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CountdownRow extends StatelessWidget {
  const _CountdownRow({required this.parts});

  final ({int days, int hours, int minutes, int seconds}) parts;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final numberStyle = TextStyle(
      fontFamily: 'Koulen',
      fontSize: isMobile ? 28 : 40,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
    final labelStyle = TextStyle(
      fontFamily: 'Battambang',
      fontSize: isMobile ? 10 : 12,
      letterSpacing: isMobile ? 0.5 : 1.1,
      color: const Color(0xFF9E9E9E),
    );
    final spacing = isMobile ? 16.0 : 28.0;

    Widget buildUnit(String value, String labelKh) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: numberStyle),
          const SizedBox(height: 4),
          Text(labelKh, style: labelStyle),
        ],
      );
    }

    String two(int v) => v.toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildUnit(parts.days.toString(), 'ថ្ងៃ'),
        SizedBox(width: spacing),
        buildUnit(two(parts.hours), 'ម៉ោង'),
        SizedBox(width: spacing),
        buildUnit(two(parts.minutes), 'នាទី'),
        SizedBox(width: spacing),
        buildUnit(two(parts.seconds), 'វិនាទី'),
      ],
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection({super.key});

  static bool _mapViewRegistered = false;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB88527);
    const brown = Color(0xFF6F4C0B);
    const mapUrl = 'https://maps.app.goo.gl/Kz7FxgiKve5MyiMZ7';
    const embedUrl =
        'https://www.google.com/maps?q=13.1277753,104.3382257&hl=en&z=15&output=embed';

    final mapCard = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.location, color: gold, size: 22),
              const SizedBox(width: 10),
              Text(
                'ទីតាំងពិធី',
                style: WeddingTextStyles.heading3.copyWith(
                  color: gold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ភោជនីយដ្ឋាន មហារមង្គល',
            style: WeddingTextStyles.body.copyWith(color: brown, height: 1.5),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: map_embed.buildGoogleMapView(embedUrl),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(mapUrl);
                final success = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open map. Please try again.'),
                    ),
                  );
                }
              },
              icon: const Icon(Iconsax.routing, size: 18),
              label: Text(
                'Get Directions',
                style: const TextStyle(
                  fontFamily: 'Dangrek',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isNarrow = maxWidth < 900;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [mapCard],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SizedBox(width: maxWidth * 0.5, child: mapCard)],
        );
      },
    );
  }
}

class _MapBlessingRow extends StatelessWidget {
  const _MapBlessingRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isStacked = maxWidth < 900;

        if (isStacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _MapSection(),
              SizedBox(height: 24),
              _BlessingMessageSection(),
            ],
          );
        }

        const minHeight = 360.0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: _MapSection(),
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: _BlessingMessageSection(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.label,
    required this.hex,
    required this.color,
  });

  final String label;
  final String hex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: WeddingTextStyles.body.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                hex,
                style: WeddingTextStyles.body.copyWith(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB88527);
    return SizedBox(
      width: 240,
      child: ElevatedButton(
        onPressed: () => _launchCalendarInvite(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE19B1A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/calendar-add.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'ទាញចូលប្រតិទិន',
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
    );
  }

  Future<void> _launchCalendarInvite(BuildContext context) async {
    // Wedding event on March 1, 2026, 5:00 PM - 9:30 PM
    const title = 'អាពាហ៍ពិពាហ៍ គឹមឡេង និង ជូណា • Wedding of Kimleng & Chunna';
    const location = 'ភោជនីយដ្ឋាន មហារមង្គល';
    const description =
        'ថ្ងៃអាទិត្យ ទី១ ខែមិនា ឆ្នាំ ២០២៦\nវេលាម៉ោង ៥ រសៀល\nនៅភោជនីយដ្ឋាន មហារមង្គល';

    // Event times: March 1, 2026, 5:00 PM - 9:30 PM (Cambodia time, UTC+7)
    // Convert to UTC for ICS format: 5 PM ICT = 10:00 AM UTC, 9:30 PM ICT = 2:30 PM UTC next day
    const startDateTime = '20260301T100000Z'; // 5:00 PM ICT = 10:00 AM UTC
    const endDateTime = '20260301T143000Z'; // 9:30 PM ICT = 2:30 PM UTC

    // For Google Calendar (local time format)
    const googleStartDate = '20260301T170000';
    const googleEndDate = '20260301T213000';

    final googleCalendarUri = Uri.parse(
      'https://calendar.google.com/calendar/render'
      '?action=TEMPLATE'
      '&text=${Uri.encodeComponent(title)}'
      '&details=${Uri.encodeComponent(description)}'
      '&location=${Uri.encodeComponent(location)}'
      '&dates=$googleStartDate/$googleEndDate'
      '&ctz=Asia/Phnom_Penh',
    );

    // Generate DTSTAMP (current time in UTC)
    final now = DateTime.now().toUtc();
    final dtstamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}T'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}Z';

    final icsContent =
        '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//KimlengChunnaWedding//EN
CALSCALE:GREGORIAN
METHOD:PUBLISH
BEGIN:VEVENT
UID:kimlengchunna-20260301@kimlengchunna.wedding
DTSTAMP:$dtstamp
DTSTART:$startDateTime
DTEND:$endDateTime
SUMMARY:$title
DESCRIPTION:$description
LOCATION:$location
STATUS:CONFIRMED
SEQUENCE:0
BEGIN:VALARM
TRIGGER:-PT2H
ACTION:DISPLAY
DESCRIPTION:Reminder: Wedding in 2 hours
END:VALARM
END:VEVENT
END:VCALENDAR''';

    final icsUri = Uri.parse(
      'data:text/calendar;charset=utf-8,${Uri.encodeComponent(icsContent)}',
    );

    try {
      if (kIsWeb) {
        // Web: Use Google Calendar
        final success = await launchUrl(
          googleCalendarUri,
          mode: LaunchMode.externalApplication,
        );
        if (!success) {
          throw Exception('Unable to open calendar');
        }
      } else if (Platform.isIOS) {
        // iOS: Create temporary ICS file and share it to open in native Calendar
        try {
          final tempDir = Directory.systemTemp;
          final file = File('${tempDir.path}/wedding_event.ics');
          await file.writeAsString(icsContent);

          // Use XFile from share_plus (it's re-exported)
          final xFile = XFile(file.path, mimeType: 'text/calendar');
          await Share.shareXFiles(
            [xFile],
            text: 'Add to Calendar',
            subject: title,
          );
        } catch (e) {
          // Fallback: Try data URI if file sharing fails
          final success = await launchUrl(
            icsUri,
            mode: LaunchMode.externalApplication,
          );
          if (!success) {
            throw Exception('Unable to open calendar: $e');
          }
        }
      } else {
        // Android: Use Google Calendar
        final success = await launchUrl(
          googleCalendarUri,
          mode: LaunchMode.externalApplication,
        );
        if (!success) {
          throw Exception('Unable to open calendar');
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open calendar: ${e.toString()}')),
      );
    }
  }
}

class _ScheduleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB88527);
    const brown = Color(0xFF6F4C0B);

    const dayOneTitle = 'ថ្ងៃទី១៖ ថ្ងៃសៅរ៍ ទី២៨ ខែកុម្ភៈ ឆ្នាំ ២០២៦';
    const dayOneItems = [
      'ពិធីក្រុងពិលី • ពិធីកាត់សក់បង្កក់សិរី • ពិធីសូត្រមន្តចម្រើនព្រះបរិត្ត',
      'ពិធីកាត់ជំនួន (កំណត់) ចូលរោងជ័យ ជួបខាន់ស្លា',
      'អញ្ជើញភ្ញៀវកិត្តិយសទទួលទានអាហារពេលព្រឹក',
      'ពិធីស្រាសំពះផ្ទឹម កាត់ខាន់ស្លា ពិលពាន',
    ];

    const dayTwoTitle = 'ថ្ងៃទី២៖ ថ្ងៃអាទិត្យ ទី០១ ខែមីនា ឆ្នាំ ២០២៦';
    const dayTwoItems = [
      'ជួបជុំបងប្អូនញាតិមិត្ត និងភ្ញៀវកិត្តិយស រៀបចំហែរជំនួន',
      'អញ្ជើញ បងប្អូនញាតិមិត្ត និងភ្ញៀវកិត្តិយស ទទួលបានអាហារពេលល្ងាច',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Iconsax.calendar, color: gold, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'កម្មវិធីមង្គលការ',
                      style: WeddingTextStyles.heading3.copyWith(
                        color: gold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _AgendaDayCard(
                  title: dayOneTitle,
                  items: dayOneItems,
                  accent: gold,
                  textColor: brown,
                ),
                const SizedBox(height: 12),
                _AgendaDayCard(
                  title: dayTwoTitle,
                  items: dayTwoItems,
                  accent: gold,
                  textColor: brown,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaDayCard extends StatelessWidget {
  const _AgendaDayCard({
    required this.title,
    required this.items,
    required this.accent,
    required this.textColor,
  });

  final String title;
  final List<String> items;
  final Color accent;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: WeddingTextStyles.heading3.copyWith(
              color: accent,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      line,
                      style: WeddingTextStyles.body.copyWith(
                        color: textColor,
                        height: 1.5,
                      ),
                    ),
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

class _GalleryCollage extends StatelessWidget {
  const _GalleryCollage({required this.onImageTap});

  final void Function(int index) onImageTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final crossAxisCount = isMobile ? 2 : 4;
    const gold = Color(0xFFB88527);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(Iconsax.gallery, color: gold, size: 22),
              const SizedBox(width: 10),
              Text(
                'វិចិត្រសាល',
                style: WeddingTextStyles.heading3.copyWith(
                  color: gold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              mainAxisExtent: 250, // Fixed height for all images
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _galleryImages.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => onImageTap(index),
              child: SizedBox(
                width: double.infinity,
                height: 250,
                child: ClipRect(
                  child: _ShimmerImageAsset(
                    imagePath: _galleryImages[index],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoveStorySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB88527);
    const brown = Color(0xFF6F4C0B);
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    final moments = [
      (
        title: 'Childhood Friends to Soulmates',
        date: '',
        detail:
            'From childhood friends to soulmates — some loves are miracles, not accidents.',
        image: Assets.story1,
      ),
      (
        title: 'Believing in Love Again',
        date: '',
        detail:
            'Thank God that I\'ve finally found a good man who genuinely cares about me and made me believe in love again, loves to make me happy and loves me so much more than I could imagine.',
        image: Assets.story2,
      ),
      (
        title: 'To My Man',
        date: '',
        detail:
            'To my man : When I look at you, I see the most handsome, hardworking, patience and loving person. I see the effort you put in every single day, and I see how hard you work for us and for our future. Love u ma hubbie🥰',
        image: Assets.story3,
      ),
      (
        title: 'A Forever Begins',
        date: '',
        detail:
            'This day is more than a wedding; it is the beginning of a forever built on trust, sacrifice, and unconditional love.',
        image: Assets.story4,
      ),
      (
        title: 'Our Wedding Day',
        date: '',
        detail:
            'Surrounded by our families and friends, we promised to walk together through every joy and every challenge, holding the same love that brought us here today.',
        image: Assets.photo1,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoveStoryHeader(gold: gold),
                const SizedBox(height: 18),
                _LoveStoryTimeline(moments: moments, gold: gold, brown: brown),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LoveStoryHeader(gold: gold),
                      const SizedBox(height: 18),
                      _LoveStoryTimeline(
                        moments: moments,
                        gold: gold,
                        brown: brown,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _LoveStoryHeader extends StatelessWidget {
  const _LoveStoryHeader({required this.gold});

  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.heart_circle, color: gold, size: 24),
          const SizedBox(width: 10),
          Text(
            'Our Love Story',
            style: WeddingTextStyles.heading3.copyWith(
              color: gold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoveStoryTimeline extends StatelessWidget {
  const _LoveStoryTimeline({
    required this.moments,
    required this.gold,
    required this.brown,
  });

  final List<({String title, String date, String detail, String image})>
      moments;
  final Color gold;
  final Color brown;

  List<String> get _images => moments.map((m) => m.image).toList();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    if (isMobile) {
      // Mobile: timeline with minimal spacing
      return Column(
        children: moments.asMap().entries.map((entry) {
          final isLast = entry.key == moments.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: gold,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              gold.withValues(alpha: 0.6),
                              gold.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TimelineItem(
                    moment: entry.value,
                    index: entry.key,
                    gold: gold,
                    brown: brown,
                    isMobile: true,
                    isLeft: true, // Always left on mobile
                    images: _images,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Desktop: Center timeline with alternating sides
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Vertical timeline line
            Positioned(
              left: constraints.maxWidth / 2 - 1,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      gold.withValues(alpha: 0.3),
                      gold,
                      gold.withValues(alpha: 0.3),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Timeline items
            Column(
              children: moments
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: _TimelineItem(
                        moment: entry.value,
                        index: entry.key,
                        gold: gold,
                        brown: brown,
                        isMobile: false,
                        isLeft: entry.key % 2 == 0,
                        images: _images,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.moment,
    required this.index,
    required this.gold,
    required this.brown,
    required this.isMobile,
    required this.isLeft,
    required this.images,
  });

  final ({String title, String date, String detail, String image}) moment;
  final int index;
  final Color gold;
  final Color brown;
  final bool isMobile;
  final bool isLeft;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final creamBackground = const Color(0xFFF8F2EB);
    final lightYellow = gold.withValues(alpha: 0.15);

    final imageIndex = images.indexOf(moment.image);
    final imageWidget = Builder(
      builder: (context) => _StoryImageFrame(
        image: moment.image,
        year: moment.date,
        gold: gold,
        lightYellow: lightYellow,
        onTap: imageIndex >= 0
            ? () {
                if (context.mounted) {
                  _HomeScreenState.openImageViewer(context, images, imageIndex);
                }
              }
            : null,
      ),
    );

    final textWidget = _StoryTextContent(
      title: moment.title,
      detail: moment.detail,
      gold: gold,
      brown: brown,
    );

    if (isMobile) {
      // Mobile: Simple vertical layout (dot is handled in parent timeline)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [imageWidget, const SizedBox(height: 16), textWidget],
      );
    }

    // Desktop: Alternating left/right layout with center timeline
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side content
        if (isLeft) ...[
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: creamBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: textWidget,
                          ),
                          const SizedBox(width: 16),
                          imageWidget,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Timeline dot
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: gold,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Right side spacer
          const Expanded(flex: 5, child: SizedBox()),
        ] else ...[
          // Right side spacer
          const Expanded(flex: 5, child: SizedBox()),
          // Timeline dot
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: gold,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Right side content
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: creamBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageWidget,
                    const SizedBox(width: 16),
                    Expanded(
                      child: textWidget,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StoryImageFrame extends StatelessWidget {
  const _StoryImageFrame({
    required this.image,
    required this.year,
    required this.gold,
    required this.lightYellow,
    this.onTap,
  });

  final String image;
  final String year;
  final Color gold;
  final Color lightYellow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final imageWidth = isMobile ? 150.0 : 180.0; // Smaller size, responsive

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Stack(
          children: [
            Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lightYellow, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: imageWidth, // Smaller responsive width
              child: AspectRatio(
                aspectRatio: 3 / 4, // Maintains aspect ratio
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _ShimmerImageAsset(
                      imagePath: image,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(10),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        // Decorative gold corners on image
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
              ),
              border: Border(
                top: BorderSide(color: gold.withValues(alpha: 0.4), width: 2),
                left: BorderSide(color: gold.withValues(alpha: 0.4), width: 2),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
              ),
              border: Border(
                top: BorderSide(color: gold.withValues(alpha: 0.4), width: 2),
                right: BorderSide(color: gold.withValues(alpha: 0.4), width: 2),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
              ),
              border: Border(
                bottom: BorderSide(
                  color: gold.withValues(alpha: 0.4),
                  width: 2,
                ),
                left: BorderSide(color: gold.withValues(alpha: 0.4), width: 2),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(10),
              ),
              border: Border(
                bottom: BorderSide(
                  color: gold.withValues(alpha: 0.4),
                  width: 2,
                ),
                right: BorderSide(color: gold.withValues(alpha: 0.4), width: 2),
              ),
            ),
          ),
        ),
        // Year tag
        if (year.isNotEmpty)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                year,
                style: WeddingTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _StoryTextContent extends StatelessWidget {
  const _StoryTextContent({
    required this.title,
    required this.detail,
    required this.gold,
    required this.brown,
  });

  final String title;
  final String detail;
  final Color gold;
  final Color brown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: WeddingTextStyles.heading3.copyWith(
            color: gold,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"',
              style: WeddingTextStyles.body.copyWith(
                color: gold.withValues(alpha: 0.6),
                fontSize: 32,
                height: 1.2,
                fontWeight: FontWeight.w300,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  detail,
                  style: WeddingTextStyles.body.copyWith(
                    color: brown.withValues(alpha: 0.8),
                    height: 1.6,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            Text(
              '"',
              style: WeddingTextStyles.body.copyWith(
                color: gold.withValues(alpha: 0.6),
                fontSize: 32,
                height: 1.2,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BlessingMessageSection extends StatefulWidget {
  const _BlessingMessageSection();

  @override
  State<_BlessingMessageSection> createState() =>
      _BlessingMessageSectionState();
}

class _BlessingMessageSectionState extends State<_BlessingMessageSection> {
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();

    debugPrint('📩 Blessing submitted');

    if (message.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('សូមបញ្ចូលសារជ័យមង្គល'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _sending = false;
      _messageController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('អរគុណសម្រាប់សារជ័យមង្គល!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB88527);
    const brown = Color(0xFF6F4C0B);
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.message, color: gold, size: 22),
              const SizedBox(width: 10),
              Text(
                'ផ្ញើសារជ័យមង្គល',
                style: WeddingTextStyles.heading3.copyWith(
                  color: gold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ចែករំលែកពាក្យសម្ដី និងការថ្លែងអំណរ ចំពោះក្រុមគ្រួសារយើងខ្ញុំ។',
            style: WeddingTextStyles.body.copyWith(
              color: brown.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: _inputDecoration('សារជ័យមង្គលរបស់អ្នក'),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: isMobile ? Alignment.centerLeft : Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Iconsax.send_2, size: 18),
              label: Text(
                _sending ? 'កំពុងផ្ញើ...' : 'ផ្ញើសារ',
                style: WeddingTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F2EB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFFB88527).withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFFB88527).withValues(alpha: 0.6),
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _ParentMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brown = const Color(0xFF6F4C0B);
    final gold = const Color(0xFFB88527);
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final children = [
      _MessageCard(
        title: 'លិខិតសូមអភ័យទោស',
        body:
            'យើងខ្ញុំជាមាតាបិតារបស់កូនប្រុស និងកូនស្រី សូមគោរពអញ្ជើញពីសំណាក់ ឯកឧត្តម លោកឧកញ៉ា លោកជំទាវ លោក លោកស្រី និងអ្នកនាងកញ្ញា ដែលជាភ្ញៀវកិត្តិយសទាំងអស់ ករណីដែលយើងខ្ញុំពុំបានជួបអញ្ជើញដោយផ្ទាល់។ យើងខ្ញុំសង្ឃឹមថា ភ្ញៀវកិត្តិយសទាំងអស់ នឹងផ្តល់កិត្តិយសអញ្ជើញចូលរួម ក្នុងពិធីមង្គលអាពាហ៍ពិពាហ៍ របស់កូនប្រុស និងកូនស្រីរបស់យើងខ្ញុំ ដោយក្តីអនុគ្រោះ។',
        bodyEnglish:
            'We, the parents of the bride and groom, sincerely apologize if we could not invite you in person and respectfully invite you to honor us with your presence at the wedding of our children.',
        titleColor: gold,
        bodyColor: brown,
      ),
      const SizedBox(width: 20, height: 20),
      _MessageCard(
        title: 'លិខិតថ្លែងអំណរគុណ',
        body:
            'យើងខ្ញុំជាមាតាបិតារបស់កូនប្រុស និងកូនស្រី សូមថ្លែងអំណរគុណយ៉ាងជ្រាលជ្រៅ និងសូមគោរពជូនពរទាំង ៥ប្រការ ដល់ ឯកឧត្តម លោកឧកញ៉ា លោកជំទាវ លោក លោកស្រី និងភ្ញៀវកិត្តិយសទាំងអស់ ដែលបានចំណាយពេលវេលាដ៏មានតម្លៃ អញ្ជើញចូលរួមជាភ្ញៀវកិត្តិយស ក្នុងពិធីមង្គលអាពាហ៍ពិពាហ៍ របស់កូនប្រុស និងកូនស្រីរបស់យើងខ្ញុំ។ វត្តមានរបស់ ឯកឧត្តម លោក លោកស្រី និងភ្ញៀវកិត្តិយសទាំងអស់ គឺជាកិត្តិយសដ៏ខ្ពង់ខ្ពស់ និងជាមោទនភាពដ៏អស្ចារ្យបំផុត សម្រាប់គ្រួសាររបស់យើងខ្ញុំ។',
        bodyEnglish:
            'We, the parents of the bride and groom, express our deepest gratitude and heartfelt blessings to all distinguished guests for taking your valuable time to join the wedding of our son and daughter. Your presence is our greatest honor and pride.',
        titleColor: gold,
        bodyColor: brown,
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: child,
              ),
            )
            .toList(),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: children[0]),
          const SizedBox(width: 20),
          Expanded(child: children[2]),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.title,
    required this.body,
    this.bodyEnglish,
    required this.titleColor,
    required this.bodyColor,
  });

  final String title;
  final String body;
  final String? bodyEnglish;
  final Color titleColor;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: WeddingTextStyles.heading3.copyWith(
              color: titleColor,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: WeddingTextStyles.body.copyWith(
              color: bodyColor,
              height: 1.6,
            ),
          ),
          if (bodyEnglish != null) ...[
            const SizedBox(height: 10),
            Text(
              bodyEnglish!,
              style: WeddingTextStyles.body.copyWith(
                color: bodyColor.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFB88527);
    final brown = const Color(0xFF6F4C0B);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'អំណោយអាពាហ៍ពិពាហ៍',
            style: WeddingTextStyles.heading3.copyWith(
              color: gold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'សូមទាញអំណោយចូលគណនីធនាគាររបស់យើងខ្ញុំ ឬផ្ទាល់ខ្លួននៅថ្ងៃពិធី។',
            textAlign: TextAlign.center,
            style: WeddingTextStyles.body.copyWith(color: brown),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _GiftQrCard(
                title: 'ដុល្លារ',
                imagePath: Assets.qrDollar,
                gold: gold,
                brown: brown,
              ),
              _GiftQrCard(
                title: 'រៀល',
                imagePath: Assets.qrRiel,
                gold: gold,
                brown: brown,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 220,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://pay.ababank.com/oRF8/z80qz2zr');
                final ok = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open ABA PayWay.')),
                  );
                }
              },
              icon: const Icon(Iconsax.card, size: 18),
              label: Text(
                'បើកកម្មវិធីបង់ប្រាក់',
                style: WeddingTextStyles.button.copyWith(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brown = const Color(0xFF6F4C0B);
    final gold = const Color(0xFFB88527);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Made with ',
            style: WeddingTextStyles.body.copyWith(
              color: brown.withValues(alpha: 0.9),
            ),
          ),
          Icon(Icons.favorite, color: gold, size: 18),
          Text(
            ' your special day',
            style: WeddingTextStyles.body.copyWith(
              color: brown.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftQrCard extends StatelessWidget {
  const _GiftQrCard({
    required this.title,
    required this.imagePath,
    required this.gold,
    required this.brown,
  });

  final String title;
  final String imagePath;
  final Color gold;
  final Color brown;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: WeddingTextStyles.heading3.copyWith(
              color: gold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _ShimmerImageAsset(
                    imagePath: imagePath,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassMusicButton extends StatelessWidget {
  const _GlassMusicButton({required this.playing, required this.onPressed});

  final bool playing;
  final VoidCallback onPressed;

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
          onTap: onPressed,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: SvgPicture.asset(
                playing ? 'assets/icons/pause.svg' : 'assets/icons/play.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
