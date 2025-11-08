import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/wedding_theme.dart';

class WeddingDetailsSection extends StatelessWidget {
  const WeddingDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Section title
          Text(
            'Wedding Details',
            style: WeddingTextStyles.heading2,
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 500.ms, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 30),
          
          // Details cards
          Column(
            children: [
              // Date & Time
              DetailCard(
                icon: Icons.calendar_today,
                title: 'Date & Time',
                content: 'Saturday, March 15th, 2025\n4:00 PM - 10:00 PM',
                color: WeddingColors.primary,
              ).animate()
                  .fadeIn(delay: 1.seconds, duration: 1.seconds)
                  .slideX(begin: -0.3),
              
              const SizedBox(height: 30),
              
              // Venue
              DetailCard(
                icon: Icons.location_on,
                title: 'Venue',
                content: 'Garden Palace Resort\n123 Wedding Lane\nPhnom Penh, Cambodia',
                actionText: 'Get Directions',
                onAction: () => _launchMaps(),
                color: WeddingColors.secondary,
              ).animate()
                  .fadeIn(delay: 1.2.seconds, duration: 1.seconds)
                  .slideX(begin: 0.3),
              
              const SizedBox(height: 30),
              
              // Dress Code
              DetailCard(
                icon: Icons.checkroom,
                title: 'Dress Code',
                content: 'Semi-Formal\nSuggested colors: Pastels & Earth tones',
                color: WeddingColors.gold,
              ).animate()
                  .fadeIn(delay: 1.4.seconds, duration: 1.seconds)
                  .slideX(begin: -0.3),
              
              const SizedBox(height: 30),
              
              // Contact Info
              DetailCard(
                icon: Icons.phone,
                title: 'Contact',
                content: 'Kimleng: +855 12 345 678\nChunna: +855 98 765 432',
                color: WeddingColors.accent,
              ).animate()
                  .fadeIn(delay: 1.6.seconds, duration: 1.seconds)
                  .slideX(begin: 0.3),
            ],
          ),
        ],
      ),
    );
  }
  
  void _launchMaps() async {
    const url = 'https://maps.google.com/?q=Garden+Palace+Resort+Phnom+Penh+Cambodia';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

class DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final String? actionText;
  final VoidCallback? onAction;
  final Color color;

  const DetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.actionText,
    this.onAction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WeddingColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            title,
            style: WeddingTextStyles.heading3.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 15),
          
          // Content
          Text(
            content,
            style: WeddingTextStyles.body,
            textAlign: TextAlign.center,
          ),
          
          // Action button
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: WeddingColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}
