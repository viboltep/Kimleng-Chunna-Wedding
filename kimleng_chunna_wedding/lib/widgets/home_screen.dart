import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/assets.dart';
import '../services/web_music_service.dart';
import '../theme/wedding_theme.dart';
import '../utils/responsive.dart';
import 'package:latlong2/latlong.dart';

const List<String> _galleryImages = [
  Assets.photo0Y9A6340,
  Assets.photo0Y9A6755,
  Assets.photo0Y9A6984,
  Assets.photo078A5077,
  Assets.photo0Y9A6878,
  Assets.photo0Y9A6498,
  Assets.photo011A6483,
  Assets.photo011A6948,
];

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

  void _openGalleryViewer(BuildContext context, int startIndex) {
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
            final maxWidth = isNarrow ? screenWidth - 24 : 720.0;
            final viewportHeight =
                (screenHeight * 0.8).clamp(320.0, isNarrow ? 540.0 : 620.0);

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
                      itemCount: _galleryImages.length,
                      itemBuilder: (context, idx) => Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxWidth,
                            maxHeight: viewportHeight,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: Colors.black,
                              child: Image.asset(
                                _galleryImages[idx],
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
                      top: 32,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${currentIndex + 1} / ${_galleryImages.length}',
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
                            backgroundColor:
                                Colors.black.withValues(alpha: 0.3),
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
                            backgroundColor:
                                Colors.black.withValues(alpha: 0.3),
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
      });
      _countdownTimer?.cancel();
      return;
    }

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    setState(() {
      _countdown =
          '${days}d ${hours}h ${minutes}m ${seconds.toString().padLeft(2, '0')}s';
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
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: ResponsiveContainer(
              maxWidth: 1200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroInvite(countdown: _countdown),
                  const SizedBox(height: 48),
                  _ScheduleCard(),
                  const SizedBox(height: 48),
                  _MapSection(),
                  const SizedBox(height: 48),
                  _GalleryCollage(
                    onImageTap: (index) => _openGalleryViewer(context, index),
                  ),
                  const SizedBox(height: 48),
                  _LoveStorySection(),
                  const SizedBox(height: 48),
                  _ParentMessages(),
                  const SizedBox(height: 48),
                  _ThankYou(),
                  const SizedBox(height: 48),
                  _BottomNote(),
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
  const _HeroInvite({required this.countdown});

  final String countdown;
  @override
  Widget build(BuildContext context) {
    final viewHeight = MediaQuery.of(context).size.height;
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            'សិរីមង្គលអាពាហ៍ពិពាហ៍',
            textAlign: TextAlign.center,
            style: WeddingTextStyles.heading2.copyWith(
              color: const Color(0xFFB88527),
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(Assets.photo0Y9A6878),
                      radius: 80,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'សៀង គឹមឡេង',
                      textAlign: TextAlign.center,
                      style: WeddingTextStyles.heading2.copyWith(
                        color: const Color(0xFFB88527),
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'និង',
                      textAlign: TextAlign.center,
                      style: WeddingTextStyles.body.copyWith(
                        color: const Color(0xFF6F4C0B),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                  CircleAvatar(
                    backgroundImage: AssetImage(Assets.photo0Y9A6878),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'ថ្ងៃអាទិត្យ ទី១ ខែមិនា ឆ្នាំ ២០២៦',
                  textAlign: TextAlign.center,
                  style: WeddingTextStyles.heading3.copyWith(
                    color: const Color(0xFFB88527),
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ភោជនីយដ្ឋាន មហារមង្គល',
                  textAlign: TextAlign.center,
                  style: WeddingTextStyles.bodyLarge.copyWith(
                    color: const Color(0xFF6F4C0B),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  countdown,
                  textAlign: TextAlign.center,
                  style: WeddingTextStyles.heading3.copyWith(
                    color: const Color(0xFF6F4C0B),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _CalendarButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB88527);
    const brown = Color(0xFF6F4C0B);
    const mapUrl = 'https://maps.app.goo.gl/Kz7FxgiKve5MyiMZ7';
    // Venue coordinates
    const venueLatLng = LatLng(13.1277753, 104.3382257);

    return Container(
      padding: const EdgeInsets.all(24),
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
            'ភោជនីយដ្ឋាន មហារមង្គល\nPhnom Penh, Cambodia',
            style: WeddingTextStyles.body.copyWith(
              color: brown,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 320,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: venueLatLng,
                  initialZoom: 15.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.kimlengchunna.wedding',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 80,
                        point: venueLatLng,
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage(Assets.couple1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                style: GoogleFonts.dangrek(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
  }
}

class _CalendarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: ElevatedButton.icon(
        onPressed: () => _launchCalendarInvite(context),
        icon: const Icon(Iconsax.calendar_tick, size: 18),
        label: Text(
          'ទាញចូលប្រតិទិន',
          style: GoogleFonts.dangrek(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w100,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB88527),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: WeddingTextStyles.button.copyWith(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _launchCalendarInvite(BuildContext context) async {
    // All-day event on March 1, 2026 (local wedding day).
    const startDate = '20260301';
    const endDateExclusive = '20260302'; // all-day uses next day end
    const title = 'Wedding of Kimleng & Chunna';
    const location = 'ភោជនីយដ្ឋាន មហារមង្គល, Phnom Penh';
    const description =
        'You are warmly invited to celebrate with Kimleng & Chunna.';

    final googleCalendarUri = Uri.parse(
      'https://calendar.google.com/calendar/render'
      '?action=TEMPLATE'
      '&text=${Uri.encodeComponent(title)}'
      '&details=${Uri.encodeComponent(description)}'
      '&location=${Uri.encodeComponent(location)}'
      '&dates=$startDate/$endDateExclusive',
    );

    final icsContent = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//KimlengChunnaWedding//EN
BEGIN:VEVENT
UID:kimlengchunna-20260301
DTSTAMP:20260116T000000Z
DTSTART;VALUE=DATE:$startDate
DTEND;VALUE=DATE:$endDateExclusive
SUMMARY:$title
DESCRIPTION:$description
LOCATION:$location
END:VEVENT
END:VCALENDAR
''';

    final icsUri = Uri.parse(
      'data:text/calendar;charset=utf-8,${Uri.encodeComponent(icsContent)}',
    );

    try {
      final target = kIsWeb
          ? googleCalendarUri
          : Platform.isIOS
              ? icsUri
              : googleCalendarUri;
      final success =
          await launchUrl(target, mode: LaunchMode.externalApplication);
      if (!success) {
        throw Exception('Unable to open calendar');
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open calendar. Please try again.'),
        ),
      );
    }
  }
}

class _ScheduleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                Text(
                  'កម្មវិធីមង្គលការ',
                  style: WeddingTextStyles.heading3.copyWith(
                    color: const Color(0xFFB88527),
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'ថ្ងៃទី១៖ ថ្ងៃសៅរ៍ ទី២៨ ខែកុម្ភៈ ឆ្នាំ ២០២៦\n• ពិធីក្រុងពិលី • ពិធីកាត់សក់បង្កក់សិរី • ពិធីសូត្រមន្តចម្រើនព្រះបរិត្ត\n• ពិធីកាត់ជំនួន (កំណត់) ចូលរោងជ័យ ជួបខាន់ស្លា • អញ្ជើញភ្ញៀវកិត្តិយសទទួលទានអាហារពេលព្រឹក\n• ពិធីស្រាសំពះផ្ទឹម កាត់ខាន់ស្លា ពិលពាន',
                  style: WeddingTextStyles.body.copyWith(
                    color: const Color(0xFF6F4C0B),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ថ្ងៃទី២៖ ថ្ងៃអាទិត្យ ទី០១ ខែមីនា ឆ្នាំ២០២៦\n• ជួបជុំបងប្អូនញាតិមិត្ត និងភ្ញៀវកិត្តិយស រៀបចំហែរជំនួន\n• អញ្ជើញ បងប្អូនញាតិមិត្ត និងភ្ញៀវកិត្តិយស ទទួលបានអាហារពេលល្ងាច',
                  style: WeddingTextStyles.body.copyWith(
                    color: const Color(0xFF6F4C0B),
                  ),
                ),
              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'វិចិត្រសាល',
          style: WeddingTextStyles.heading3.copyWith(
            color: const Color(0xFFB88527),
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 16),
        ResponsiveGrid(
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: List.generate(
            _galleryImages.length,
            (index) => GestureDetector(
              onTap: () => onImageTap(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  _galleryImages[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
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
        title: 'First Hello',
        date: '2018 · Phnom Penh',
        detail: 'Met through mutual friends and bonded over coffee and music.',
        image: Assets.couple2,
      ),
      (
        title: 'The Promise',
        date: '2023 · Siem Reap',
        detail: 'A sunrise visit to Angkor Wat sealed a shared dream for life.',
        image: Assets.couple3,
      ),
      (
        title: 'Forever Begins',
        date: '2026 · Phnom Penh',
        detail: 'Celebrating this new chapter with family and dear friends.',
        image: Assets.couple4,
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
    return Row(
      children: [
        Icon(Iconsax.heart_circle, color: gold, size: 24),
        const SizedBox(width: 10),
        Text(
          'រឿងស្នេហា',
          style: WeddingTextStyles.heading3.copyWith(
            color: gold,
            fontSize: 22,
          ),
        ),
      ],
    );
  }
}

class _LoveStoryTimeline extends StatelessWidget {
  const _LoveStoryTimeline({
    required this.moments,
    required this.gold,
    required this.brown,
  });

  final List<({String title, String date, String detail, String image})> moments;
  final Color gold;
  final Color brown;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: moments
          .map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Iconsax.heart, color: gold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: WeddingTextStyles.heading3.copyWith(
                            color: gold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.date,
                          style: WeddingTextStyles.body.copyWith(
                            color: brown.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.detail,
                          style: WeddingTextStyles.body.copyWith(
                            color: brown,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: SizedBox(
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                m.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
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
        titleColor: gold,
        bodyColor: brown,
      ),
      const SizedBox(width: 20, height: 20),
      _MessageCard(
        title: 'សារជូនពរ',
        body:
            'យើងខ្ញុំជាមាតាបិតារបស់កូនប្រុស និងកូនស្រី សូមថ្លែងអំណរគុណយ៉ាងជ្រាលជ្រៅ និងសូមគោរពជូនពរទាំង ៥ប្រការ ដល់ ឯកឧត្តម លោកឧកញ៉ា លោកជំទាវ លោក លោកស្រី និងភ្ញៀវកិត្តិយសទាំងអស់ ដែលបានចំណាយពេលវេលាដ៏មានតម្លៃ អញ្ជើញចូលរួមជាភ្ញៀវកិត្តិយស ក្នុងពិធីមង្គលអាពាហ៍ពិពាហ៍ របស់កូនប្រុស និងកូនស្រីរបស់យើងខ្ញុំ។ វត្តមានរបស់ ឯកឧត្តម លោក លោកស្រី និងភ្ញៀវកិត្តិយសទាំងអស់ គឺជាកិត្តិយសដ៏ខ្ពង់ខ្ពស់ និងជាមោទនភាពដ៏អស្ចារ្យបំផុត សម្រាប់គ្រួសាររបស់យើងខ្ញុំ។',
        titleColor: gold,
        bodyColor: brown,
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: child,
                ))
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 20),
        Expanded(child: children[2]),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.title,
    required this.body,
    required this.titleColor,
    required this.bodyColor,
  });

  final String title;
  final String body;
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
        ],
      ),
    );
  }
}

class _ThankYou extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brown = const Color(0xFF6F4C0B);
    final gold = const Color(0xFFB88527);
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
            'សូមអរគុណ',
            style: WeddingTextStyles.heading3.copyWith(
              color: gold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We, as the parents of the bride and groom, would like to express our deepest gratitude and respectfully extend our thanks in all five directions to all distinguished guests who have taken their valuable time to join us as honored guests at the wedding of our son and daughter. The presence of Their Excellencies, Ladies and Gentlemen, and all distinguished guests is the greatest honor and pride of our family.',
            style: WeddingTextStyles.body.copyWith(color: brown, height: 1.6),
          ),
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
                final uri = Uri.parse(
                    'https://pay.ababank.com/oRF8/z80qz2zr');
                final ok = await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open ABA PayWay.'),
                    ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassMusicButton extends StatelessWidget {
  const _GlassMusicButton({
    required this.playing,
    required this.onPressed,
  });

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
            child: Icon(
              playing ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
