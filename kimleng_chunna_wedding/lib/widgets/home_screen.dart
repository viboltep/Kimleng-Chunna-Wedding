import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../services/web_music_service.dart';
import '../theme/wedding_theme.dart';
import '../utils/responsive.dart';

/// Desktop-first home screen aligned to the Figma “Home” frame (11:51).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _playing = WebMusicService().isPlaying;
  }

  Future<void> _toggleMusic() async {
    await WebMusicService().toggleMusic();
    setState(() {
      _playing = WebMusicService().isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8F2EB); // Frame background from Figma
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          onPressed: _toggleMusic,
          backgroundColor: const Color(0xFFB88527),
          icon: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
          label: Text(
            _playing ? 'Pause music' : 'Play music',
            style: WeddingTextStyles.button.copyWith(color: Colors.white),
          ),
        ),
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
                  _HeroInvite(),
                  const SizedBox(height: 48),
                  _ScheduleCard(),
                  const SizedBox(height: 48),
                  _GalleryCollage(),
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
  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              Assets.rectangle3,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'សិរីមង្គលអាពាហ៍ពិពាហ៍',
                  textAlign: TextAlign.center,
                  style: WeddingTextStyles.heading2.copyWith(
                    color: const Color(0xFFB88527),
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You are cordially invited to the wedding of',
                  textAlign: TextAlign.center,
                  style: WeddingTextStyles.bodyLarge.copyWith(
                    color: const Color(0xFF6F4C0B),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'សៀង គឹមឡេង',
                  textAlign: TextAlign.center,
                  style: WeddingTextStyles.heading2.copyWith(
                    color: const Color(0xFFB88527),
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'និង',
                  textAlign: TextAlign.center,
                  style: WeddingTextStyles.body.copyWith(
                    color: const Color(0xFF6F4C0B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'លឹម ជូណា',
                  textAlign: TextAlign.center,
                  style: WeddingTextStyles.heading2.copyWith(
                    color: const Color(0xFFB88527),
                    fontSize: 30,
                  ),
                ),
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

class _CalendarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: wire to existing calendar deep link if needed.
        },
        icon: const Icon(Icons.calendar_today, size: 18),
        label: const Text('ទាញចូលប្រតិទិន'),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              Assets.flower,
              fit: BoxFit.cover,
            ),
          ),
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
  @override
  Widget build(BuildContext context) {
    final images = [
      Assets.rectangle4,
      Assets.rectangle5,
      Assets.rectangle8,
      Assets.rectangle9,
      Assets.rectangle6,
      Assets.rectangle7,
    ];
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
          children: images
              .map(
                (asset) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    asset,
                    fit: BoxFit.cover,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ParentMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brown = const Color(0xFF6F4C0B);
    final gold = const Color(0xFFB88527);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MessageCard(
            title: 'លិខិតសូមអភ័យទោស',
            body:
                'យើងខ្ញុំជាមាតាបិតារបស់កូនប្រុស និងកូនស្រី សូមគោរពអញ្ជើញពីសំណាក់ ឯកឧត្តម លោកឧកញ៉ា លោកជំទាវ លោក លោកស្រី និងអ្នកនាងកញ្ញា ដែលជាភ្ញៀវកិត្តិយសទាំងអស់ ករណីដែលយើងខ្ញុំពុំបានជួបអញ្ជើញដោយផ្ទាល់។ យើងខ្ញុំសង្ឃឹមថា ភ្ញៀវកិត្តិយសទាំងអស់ នឹងផ្តល់កិត្តិយសអញ្ជើញចូលរួម ក្នុងពិធីមង្គលអាពាហ៍ពិពាហ៍ របស់កូនប្រុស និងកូនស្រីរបស់យើងខ្ញុំ ដោយក្តីអនុគ្រោះ។',
            titleColor: gold,
            bodyColor: brown,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _MessageCard(
            title: 'សារជូនពរ',
            body:
                'យើងខ្ញុំជាមាតាបិតារបស់កូនប្រុស និងកូនស្រី សូមថ្លែងអំណរគុណយ៉ាងជ្រាលជ្រៅ និងសូមគោរពជូនពរទាំង ៥ប្រការ ដល់ ឯកឧត្តម លោកឧកញ៉ា លោកជំទាវ លោក លោកស្រី និងភ្ញៀវកិត្តិយសទាំងអស់ ដែលបានចំណាយពេលវេលាដ៏មានតម្លៃ អញ្ជើញចូលរួមជាភ្ញៀវកិត្តិយស ក្នុងពិធីមង្គលអាពាហ៍ពិពាហ៍ របស់កូនប្រុស និងកូនស្រីរបស់យើងខ្ញុំ។ វត្តមានរបស់ ឯកឧត្តម លោក លោកស្រី និងភ្ញៀវកិត្តិយសទាំងអស់ គឺជាកិត្តិយសដ៏ខ្ពង់ខ្ពស់ និងជាមោទនភាពដ៏អស្ចារ្យបំផុត សម្រាប់គ្រួសាររបស់យើងខ្ញុំ។',
            titleColor: gold,
            bodyColor: brown,
          ),
        ),
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
            style: WeddingTextStyles.body.copyWith(
              color: brown,
              height: 1.6,
            ),
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
            style: WeddingTextStyles.body.copyWith(
              color: brown,
            ),
          ),
        ],
      ),
    );
  }
}
