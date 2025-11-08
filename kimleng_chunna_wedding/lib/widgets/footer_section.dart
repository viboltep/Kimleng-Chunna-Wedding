import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/wedding_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            WeddingColors.primary.withOpacity(0.1),
            WeddingColors.primary.withOpacity(0.2),
          ],
        ),
      ),
      child: Column(
        children: [
          // Share section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: WeddingColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: WeddingColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.share,
                  size: 40,
                  color: WeddingColors.primary,
                ),
                const SizedBox(height: 15),
                Text(
                  'Share Our Joy',
                  style: WeddingTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Help us spread the word about our special day',
                  style: WeddingTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _shareInvitation(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share Invitation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WeddingColors.primary,
                    foregroundColor: WeddingColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ).animate()
              .fadeIn(delay: 500.ms, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 40),
          
          // Final message
          Text(
            'Kimleng & Chunna',
            style: WeddingTextStyles.heading2.copyWith(
              color: WeddingColors.primary,
            ),
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 1.seconds, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 20),
          
          Text(
            'March 15th, 2025',
            style: WeddingTextStyles.bodyLarge.copyWith(
              color: WeddingColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 1.2.seconds, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 30),
          
          // Decorative line
          Container(
            width: 200,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [WeddingColors.gold, WeddingColors.primary],
              ),
            ),
          ).animate()
              .fadeIn(delay: 1.4.seconds, duration: 1.seconds)
              .scaleX(begin: 0),
          
          const SizedBox(height: 30),
          
          Text(
            'We can\'t wait to celebrate with you!',
            style: WeddingTextStyles.body,
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 1.6.seconds, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 20),
          
          // Contact info
          Column(
            children: [
              _buildContactItem(
                icon: Icons.phone,
                text: 'Kimleng: +855 12 345 678',
              ),
              const SizedBox(height: 10),
              _buildContactItem(
                icon: Icons.phone,
                text: 'Chunna: +855 98 765 432',
              ),
            ],
          ).animate()
              .fadeIn(delay: 1.8.seconds, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 40),
          
          // Copyright
          Text(
            '© 2025 Kimleng & Chunna Wedding. Made with ❤️',
            style: WeddingTextStyles.small,
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 2.seconds, duration: 1.seconds)
              .slideY(begin: 0.3),
        ],
      ),
    );
  }
  
  Widget _buildContactItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: WeddingColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: WeddingTextStyles.small,
        ),
      ],
    );
  }
  
  void _shareInvitation(BuildContext context) {
    Share.share(
      'You\'re invited to Kimleng & Chunna\'s wedding!\n\n'
      'Date: March 15th, 2025\n'
      'Time: 4:00 PM - 10:00 PM\n'
      'Venue: Garden Palace Resort, Phnom Penh, Cambodia\n\n'
      'RSVP by February 15th, 2025\n\n'
      'We can\'t wait to celebrate with you! 💕',
      subject: 'Wedding Invitation - Kimleng & Chunna',
    );
  }
}
