import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/wedding_theme.dart';
import '../utils/responsive.dart';

class WeddingAgendaSection extends StatefulWidget {
  const WeddingAgendaSection({super.key});

  @override
  State<WeddingAgendaSection> createState() => _WeddingAgendaSectionState();
}

class _WeddingAgendaSectionState extends State<WeddingAgendaSection> {
  int _selectedDayIndex = 0;

  static const Map<String, List<Map<String, String>>> _agenda = {
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
    const warmBrown = Color(0xFF6F4C0B);
    const deepBrown = Color(0xFF2C1810);
    const cream = Color(0xFFFDF9F4);

    final dayKeys = _agenda.keys.toList();
    final selectedKey = dayKeys[_selectedDayIndex];
    final selectedEvents = _agenda[selectedKey]!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDF9F4),
            Color(0xFFF8F0E6),
            Color(0xFFF5EBDE),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: gold.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header with accent
          Center(
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 4,
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.calendar_1, color: gold, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'តារាងកម្មវិធី',
                      style: WeddingTextStyles.heading3.copyWith(
                        fontFamily: 'Koulen',
                        color: gold,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Program Schedule',
                  style: WeddingTextStyles.body.copyWith(
                    color: warmBrown.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 24),
          // iOS segmented control: Day 1 | Day 2 (rounded like add to calendar button)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CupertinoTheme(
              data: CupertinoThemeData(
                primaryColor: gold,
                brightness: Brightness.light,
              ),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedDayIndex,
                thumbColor: Colors.white,
                backgroundColor: gold.withValues(alpha: 0.15),
                padding: const EdgeInsets.all(4),
              children: {
                0: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'ថ្ងៃទី១',
                    textAlign: TextAlign.center,
                    style: WeddingTextStyles.bayon(
                      fontSize: 15,
                      fontWeight: _selectedDayIndex == 0
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _selectedDayIndex == 0 ? gold : warmBrown,
                    ),
                  ),
                ),
                1: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'ថ្ងៃទី២',
                    textAlign: TextAlign.center,
                    style: WeddingTextStyles.bayon(
                      fontSize: 15,
                      fontWeight: _selectedDayIndex == 1
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _selectedDayIndex == 1 ? gold : warmBrown,
                    ),
                  ),
                ),
              },
              onValueChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDayIndex = value);
                }
              },
            ),
            ),
          ),
          const SizedBox(height: 20),
          _DayCard(
            dayTitle: selectedKey,
            events: selectedEvents,
            gold: gold,
            warmBrown: warmBrown,
            deepBrown: deepBrown,
            cream: cream,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.12, end: 0, curve: Curves.easeOut);
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.dayTitle,
    required this.events,
    required this.gold,
    required this.warmBrown,
    required this.deepBrown,
    required this.cream,
  });

  final String dayTitle;
  final List<Map<String, String>> events;
  final Color gold;
  final Color warmBrown;
  final Color deepBrown;
  final Color cream;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dayTitle,
                style: WeddingTextStyles.heading3.copyWith(
                  fontFamily: 'Koulen',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Timeline
          ...events.asMap().entries.map((entry) {
            final isLast = entry.key == events.length - 1;
            final time = entry.value['time']!;
            final event = entry.value['event']!;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: gold.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      time,
                      style: WeddingTextStyles.bayon(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: deepBrown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Connector dot
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: gold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Event text
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event,
                        style: WeddingTextStyles.bayon(
                          fontSize: 13,
                          color: warmBrown,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
