import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/wedding_theme.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  // Wedding venue location - you can update these coordinates
  static const String _venueName = 'វត្តព្រះពុទ្ធសាសនា';
  static const String _venueAddress = 'Phnom Penh, Cambodia';
  static const double _latitude = 11.5564;
  static const double _longitude = 104.9282;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WeddingColors.secondary.withValues(alpha: 0.05),
            WeddingColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Container(
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
              color: WeddingColors.secondary.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Location Icon and Title
            Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: WeddingColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ទីតាំងពិធី', // Location
                      style: WeddingTextStyles.bayon(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: WeddingColors.primary,
                        height: 1.3,
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 20),

            // Venue Information
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WeddingColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: WeddingColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Venue Name
                      Text(
                        _venueName,
                        style: WeddingTextStyles.bayon(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: WeddingColors.textPrimary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Address
                      Text(
                        _venueAddress,
                        style: WeddingTextStyles.bayon(
                          fontSize: 16,
                          color: WeddingColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 20),

            // Google Maps Button
            SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openInGoogleMaps(),
                    icon: Icon(Icons.map, color: Colors.white, size: 24),
                    label: Text(
                      'បើកក្នុង Google Maps',
                      style: WeddingTextStyles.bayon(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WeddingColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: WeddingColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Additional Info
            Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WeddingColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: WeddingColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ចុចបើកក្នុង Google Maps ដើម្បីមើលទីតាំងពិតប្រាកដ',
                          style: WeddingTextStyles.bayon(
                            fontSize: 14,
                            color: WeddingColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms)
                .slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Future<void> _openInGoogleMaps() async {
    try {
      // Create Google Maps URL
      final String googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude';

      // Try to launch the URL
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to basic maps URL
        final String fallbackUrl =
            'https://maps.google.com/?q=$_latitude,$_longitude';
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Error opening Google Maps: $e');
      // You could show a snackbar or dialog here to inform the user
    }
  }
}
