import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../constants/assets.dart';
import '../services/web_music_service.dart';
import '../theme/wedding_theme.dart';
import '../utils/responsive.dart';
import 'wedding_agenda_section.dart';
import 'animated_music_button.dart';
import 'footer_note.dart';
import 'gift_section.dart';
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
    final borderRadius = widget.borderRadius ?? BorderRadius.zero;
    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Stack(
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
      ),
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

  final GlobalKey _keyInvitation = GlobalKey();
  final GlobalKey _keyGallery = GlobalKey();
  final GlobalKey _keyStory = GlobalKey();
  final GlobalKey _keyAgenda = GlobalKey();
  final GlobalKey _keyLocation = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.08,
      );
    }
  }

  Widget _buildAppBar(BuildContext context) {
    const brown = Color(0xFF6F4C0B);
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    const titles = ['ទំព័រដើម', 'វិចិត្រសាល', 'ប្រវត្តិស្នេហា', 'កម្មវិធី', 'អំណោយ'];
    final keys = [_keyInvitation, _keyGallery, _keyStory, _keyAgenda, _keyLocation];
    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 12 : 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: isNarrow ? 4 : 8),
                  child: TextButton(
                    onPressed: () => _scrollToSection(keys[i]),
                    style: TextButton.styleFrom(
                      foregroundColor: brown,
                      padding: EdgeInsets.symmetric(
                        horizontal: isNarrow ? 8 : 14,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      titles[i],
                      style: TextStyle(
                        fontFamily: 'Dangrek',
                        fontSize: isNarrow ? 14 : 15,
                        fontWeight: FontWeight.w500,
                        color: brown,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

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
                            borderRadius: BorderRadius.zero,
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
    // Sync play state after a short delay (music may have just started from Open Invitation tap)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        final nowPlaying = WebMusicService().isPlaying;
        if (nowPlaying != _playing) {
          setState(() => _playing = nowPlaying);
        }
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
    const background = Color(0xFFB88527); // Fallback gold while image loads
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: AnimatedMusicButton(
        isPlaying: _playing,
        onPressed: _toggleMusic,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Golden background image (Figma design) - fills entire screen
          Image.asset(
            Assets.background,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: background),
          ),
          SafeArea(
            child: Stack(
              children: [
                // Scroll content fills the screen so it can scroll *behind* the app bar (for blur)
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 56,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: ResponsiveContainer(
                      maxWidth: ResponsiveBreakpoints.isDesktop(context) ? double.infinity : 1200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          KeyedSubtree(
                            key: _keyInvitation,
                            child: _HeroInvite(
                              countdownParts: _countdownParts,
                              celebrationText: _countdown,
                            ),
                          ),
                          const SizedBox(height: 48),
                          KeyedSubtree(
                            key: _keyGallery,
                            child: _GalleryCollage(
                              onImageTap: (index) =>
                                  _HomeScreenState.openImageViewer(context, _galleryImages, index),
                            ),
                          ),
                          const SizedBox(height: 48),
                          KeyedSubtree(
                            key: _keyStory,
                            child: _LoveStorySection(),
                          ),
                          const SizedBox(height: 48),
                          KeyedSubtree(
                            key: _keyAgenda,
                            child: const WeddingAgendaSection(),
                          ),
                          const SizedBox(height: 48),
                          KeyedSubtree(
                            key: _keyLocation,
                            child: _MapBlessingRow(),
                          ),
                          const SizedBox(height: 48),
                          _ParentMessages(),
                          const SizedBox(height: 48),
                          const GiftSection(),
                          const FooterNote(),
                        ],
                      ),
                    ),
                  ),
                ),
                // App bar on top so BackdropFilter blurs the scrolling content behind it
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildAppBar(context),
                ),
              ],
            ),
          ),
        ],
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
            final isNarrow = constraints.maxWidth < 740;
            final flowerSize = isNarrow ? 180.0 : 400.0;
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
  const _MapSection();

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
  const _MapBlessingRow();

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



class _CalendarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          MasonryGridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _galleryImages.length,
            itemBuilder: (context, index) {
              // Create staggered visual effect by varying container heights slightly
              // but images always maintain 250px height
              final baseHeight = 250.0;
              final variation = (index % 3) * 20.0 - 20.0; // -20, 0, or 20
              final containerHeight = baseHeight + variation;
              
              return GestureDetector(
                onTap: () => onImageTap(index),
                child: SizedBox(
                  height: containerHeight,
                  child: Center(
                    child: SizedBox(
                      height: 250, // Fixed height for all images (portrait and landscape)
                      width: double.infinity,
                      child: _ShimmerImageAsset(
                        imagePath: _galleryImages[index],
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              );
            },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoveStoryHeader(gold: gold),
          const SizedBox(height: 18),
          _LoveStoryTimeline(moments: moments, gold: gold, brown: brown),
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
      // Mobile: Left-aligned timeline with desktop-style cards
      return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Vertical timeline line on the left
              Positioned(
                left: 0,
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
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
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
                            isMobile: true,
                            isLeft: false, // All items on right side of timeline
                            images: _images,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      );
    }

    // Desktop: Center timeline with alternating left/right layout
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 1200 ? 1200.0 : constraints.maxWidth;
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Stack(
                children: [
                  // Vertical timeline line in center
                  Positioned(
                    left: maxWidth / 2 - 1,
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
              ),
            ),
          ),
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
      // Mobile: Image on top, text content below
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot on the left
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 24),
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
          // Content on the right side of timeline
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image on top
                  Center(
                    child: imageWidget,
                  ),
                  const SizedBox(height: 16),
                  // Text content below image
                  textWidget,
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Desktop: Alternating left/right layout with center timeline
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                          Flexible(
                            child: imageWidget,
                          ),
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
                    Flexible(
                      child: imageWidget,
                    ),
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
      },
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxImageWidth = constraints.maxWidth.isFinite 
                ? constraints.maxWidth.clamp(0.0, imageWidth)
                : imageWidth;
            return Stack(
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
                      width: maxImageWidth,
                      child: AspectRatio(
                        aspectRatio: 3 / 4, // Maintains aspect ratio
                        child: _ShimmerImageAsset(
                          imagePath: image,
                          width: maxImageWidth,
                          height: maxImageWidth * (4 / 3),
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(10),
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
            );
          },
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
        isMobile: isMobile,
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
        isMobile: isMobile,
      ),
    ];

    if (isMobile) {
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
            // Section header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.message, color: gold, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'សារពីមាតាបិតា',
                  style: WeddingTextStyles.heading3.copyWith(
                    color: gold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // First message card
            children[0],
            const SizedBox(height: 20),
            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    gold.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Second message card
            children[2],
          ],
        ),
      );
    }

    // Desktop: Same style as mobile but with side-by-side layout
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
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.message, color: gold, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'សារពីមាតាបិតា',
                style: WeddingTextStyles.heading3.copyWith(
                  color: gold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Message cards side by side
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 20),
                Expanded(child: children[2]),
              ],
            ),
          ),
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
    this.isMobile = false,
  });

  final String title;
  final String body;
  final String? bodyEnglish;
  final Color titleColor;
  final Color bodyColor;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    // Enhanced card design - same for both mobile and desktop
    final fontSize = isMobile ? 14.0 : 15.0;
    final titleFontSize = isMobile ? 18.0 : 20.0;
    final padding = isMobile ? 18.0 : 20.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2EB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: titleColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with decorative underline
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: WeddingTextStyles.heading3.copyWith(
                    color: titleColor,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: titleColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 16),
          // Khmer text
          Text(
            body,
            style: WeddingTextStyles.body.copyWith(
              color: bodyColor,
              height: 1.7,
              fontSize: fontSize,
            ),
          ),
          // English text if available
          if (bodyEnglish != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                bodyEnglish!,
                style: WeddingTextStyles.body.copyWith(
                  color: bodyColor.withValues(alpha: 0.8),
                  height: 1.6,
                  fontSize: fontSize - 1,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
