import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/wedding_theme.dart';

class WeddingAgendaSection extends StatefulWidget {
  const WeddingAgendaSection({super.key});

  @override
  State<WeddingAgendaSection> createState() => _WeddingAgendaSectionState();
}

class _WeddingAgendaSectionState extends State<WeddingAgendaSection> {
  String _selectedDate = 'ថ្ងៃទី១'; // Default selected date

  final Map<String, List<Map<String, String>>> _agenda = {
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WeddingColors.primary.withValues(alpha: 0.05),
            WeddingColors.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
                padding: const EdgeInsets.all(20),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'កម្មវិធីសិរីមង្គលអាពាហ៍ពិពាហ៍', // Wedding Ceremony Program
                          style: WeddingTextStyles.bayon(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFb88527),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideY(begin: 0.2),
                      ],
                    ),
                    const SizedBox(height: 20),

                    //Date Selection Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDateTab('ថ្ងៃទី១'),
                        _buildDateTab('ថ្ងៃទី២'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Agenda Timeline
                    Column(
                      children: _agenda[_selectedDate]!
                          .map(
                            (event) => _buildAgendaItem(
                              event['time']!,
                              event['event']!,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildDateTab(String date) {
    final isSelected = _selectedDate == date;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFb88527).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: const Color(0xFFb88527), width: 2)
              : null,
        ),
        child: Text(
          date,
          style: WeddingTextStyles.bayon(
            fontSize: 18,
            color: isSelected
                ? const Color(0xFFb88527)
                : WeddingColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildAgendaItem(String time, String event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calendar_today, color: const Color(0xFFb88527), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: WeddingTextStyles.bayon(
                    fontSize: 16,
                    color: WeddingColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  event,
                  style: WeddingTextStyles.bayon(
                    fontSize: 14,
                    color: WeddingColors.textSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
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
