import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/wedding_theme.dart';
import '../utils/responsive.dart';

class WeddingAgendaSection extends StatelessWidget {
  const WeddingAgendaSection({super.key});

  final Map<String, List<Map<String, String>>> _agenda = const {
    'ថ្ងៃទី១': [
      {'time': 'ម៉ោង ១:០០ រសៀល', 'event': 'ពិធីក្រុងពាលី'},
      {'time': 'ម៉ោង ២:០០ រសៀល', 'event': 'ពិធីកាត់សក់បង្កក់សិរី'},
      {'time': 'ម៉ោង ៥:០០ រសៀល', 'event': 'ពិធីសូត្រមន្តចម្រើនព្រះបរិត្ត'},
      {'time': 'ម៉ោង ៥:០០ ល្ងាច', 'event': 'អញ្ជើញ បងប្អូនញាតិមិត្ត និងភ្ញៀវកិត្តិយស ទទួលទានអាហារពេលល្ងាច'},
    ],
    'ថ្ងៃទី២': [
      {'time': 'ម៉ោង ៦:៣០ ព្រឹក', 'event': 'ជួបជុំបងប្អូនញាតិមិត្ត និងភ្ញៀវកិត្តិយស រៀបចំរណ្តាប់ជំនូន'},
      {'time': 'ម៉ោង ៧:០០ ព្រឹក', 'event': 'ពិធីហែជំនូន (កំណត់) ចូលរោងជ័យ ជូនខាន់ស្លា'},
      {'time': 'ម៉ោង ៨:០០ ព្រឹក', 'event': 'អញ្ជើញភ្ញៀវកិត្តិយសទទួលទានអាហារពេលព្រឹក'},
      {'time': 'ម៉ោង ៩:០០ ព្រឹក', 'event': 'ពិធីសំពះជួនដូន ជីតា និងចាក់ទឹកតែ'},
      {'time': 'ម៉ោង ១០:០០ ព្រឹក', 'event': 'ក្រាបសំពះផ្ទឹម បង្វិលពពិល បាចផ្កាស្លាពរជ័យ និងព្រះរោងរោងសែន្យានាគ'},
      {'time': 'ម៉ោង ១១:៣០ ព្រឹក', 'event': 'អញ្ជើញភ្ញៀវកិត្តិយសទទួលទានអាហារថ្ងៃត្រង់'},
      {'time': 'ម៉ោង ៤:០០ រសៀល', 'event': 'អញ្ជើញភ្ញៀវកិត្តិយសពិសាភោជនីយអាហារ នៅភោជនីយដ្ឋាន មហាមង្គល ភូមិថ្មី ឃុំគោកធ្លកក្រោម ស្រុកជីក្រែង ខេត្តសៀមរាប ដោយមេត្រីភាព'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    const gold = Color(0xFFB88527);
    const brown = Color(0xFF6F4C0B);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WeddingColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: WeddingColors.primary.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Iconsax.calendar, color: gold, size: 22),
              const SizedBox(width: 10),
              Text(
                'តារាងកម្មវិធី',
                style: WeddingTextStyles.heading3.copyWith(
                  color: gold,
                  fontSize: 22,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.2),
            ],
          ),
          const SizedBox(height: 24),
          if (isMobile)
            Column(
              children: [
                _TimelineDay(
                  title: 'ថ្ងៃទី១',
                  events: _agenda['ថ្ងៃទី១']!,
                  gold: gold,
                  brown: brown,
                ),
                const SizedBox(height: 32),
                _TimelineDay(
                  title: 'ថ្ងៃទី២',
                  events: _agenda['ថ្ងៃទី២']!,
                  gold: gold,
                  brown: brown,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TimelineDay(
                    title: 'ថ្ងៃទី១',
                    events: _agenda['ថ្ងៃទី១']!,
                    gold: gold,
                    brown: brown,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _TimelineDay(
                    title: 'ថ្ងៃទី២',
                    events: _agenda['ថ្ងៃទី២']!,
                    gold: gold,
                    brown: brown,
                  ),
                ),
              ],
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.2);
  }
}

class _TimelineDay extends StatelessWidget {
  const _TimelineDay({
    required this.title,
    required this.events,
    required this.gold,
    required this.brown,
  });

  final String title;
  final List<Map<String, String>> events;
  final Color gold;
  final Color brown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: WeddingTextStyles.bayon(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: gold,
          ),
        ),
        const SizedBox(height: 20),
        ...events.asMap().entries.map((entry) {
          final isLast = entry.key == events.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: gold,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.value['time']!,
                        style: WeddingTextStyles.bayon(
                          fontSize: 14,
                          color: brown,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value['event']!,
                        style: WeddingTextStyles.bayon(
                          fontSize: 13,
                          color: brown.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
