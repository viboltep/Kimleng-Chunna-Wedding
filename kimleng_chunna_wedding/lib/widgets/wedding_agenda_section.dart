import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/wedding_theme.dart';

class WeddingAgendaSection extends StatefulWidget {
  const WeddingAgendaSection({Key? key}) : super(key: key);

  @override
  State<WeddingAgendaSection> createState() => _WeddingAgendaSectionState();
}

class _WeddingAgendaSectionState extends State<WeddingAgendaSection> {
  String _selectedDate = '23 មីនា'; // Default selected date

  final Map<String, List<Map<String, String>>> _agenda = {
    '23 មីនា': [
      {'time': 'ម៉ោង 1:30 រសៀល', 'event': 'ស្វាគមន៍ និងជួបជុំភ្ញៀវកិត្តិយស'},
      {'time': 'ម៉ោង 2:00 រសៀល', 'event': 'ពីធីក្រុងពាលី'},
      {'time': 'ម៉ោង 3:00 រសៀល', 'event': 'ពីធីសូត្រមន្តចម្រើនព្រះបរិត្ត'},
      {'time': 'ម៉ោង 4:00 ល្ងាច', 'event': 'ពីធីជាវខាន់ស្លា'},
      {'time': 'ម៉ោង 5:00 ល្ងាច', 'event': 'ពិសាភោជនាអាហារពេលល្ងាច'},
    ],
    '24 មីនា': [
      {'time': 'ម៉ោង 8:00 ព្រឹក', 'event': 'ពីធីកាត់សក់'},
      {'time': 'ម៉ោង 9:00 ព្រឹក', 'event': 'ពីធីបង្វិលពពិល'},
      {'time': 'ម៉ោង 12:00 ថ្ងៃត្រង់', 'event': 'ពិសាអាហារថ្ងៃត្រង់'},
      {'time': 'ម៉ោង 6:00 ល្ងាច', 'event': 'ពិធីជប់លៀងមង្គលការ'},
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
            WeddingColors.primary.withOpacity(0.05),
            WeddingColors.secondary.withOpacity(0.05),
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: WeddingColors.primary.withOpacity(0.1),
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
                               'កម្មវិធីសិរីមង្គល', // Wedding Ceremony Program
                               style: TextStyle(
                                 fontFamily: 'Bayon',
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
                        const SizedBox(height: 20),
                      ],
                    ),
                    
                    //Date Selection Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDateTab('23 មីនា'),
                        _buildDateTab('24 មីនា'),
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
              ? const Color(0xFFb88527).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: const Color(0xFFb88527), width: 2)
              : null,
        ),
        child: Text(
          date,
          style: TextStyle(
            fontFamily: 'Bayon',
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
                  style: TextStyle(
                    fontFamily: 'Bayon',
                    fontSize: 16,
                    color: WeddingColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  event,
                  style: TextStyle(
                    fontFamily: 'Bayon',
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
