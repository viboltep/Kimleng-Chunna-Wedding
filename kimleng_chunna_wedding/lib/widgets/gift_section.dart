import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/assets.dart';
import '../theme/wedding_theme.dart';
import 'shimmer_image_asset.dart';

/// Gift section widget displaying wedding gift information and QR codes
class GiftSection extends StatelessWidget {
  const GiftSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              color: _GiftSectionConstants.gold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'ការចូលរួមរបស់លោកអ្នកនៅក្នុងពិធីអាពាហ៍ពិពាហ៍របស់យើង គឺជាអំណោយដ៏មានតម្លៃបំផុតសម្រាប់យើង។ ទោះយ៉ាងណា ប្រសិនបើលោកអ្នកមានបំណងចង់ផ្តល់អំណោយ សូមអនុញ្ញាតឲ្យយើងទទួលយកជាការបរិច្ចាគជាសាច់ប្រាក់ ដោយក្តីគោរព និងអំណរគុណយ៉ាងជ្រាលជ្រៅ។',
            textAlign: TextAlign.center,
            style: WeddingTextStyles.body.copyWith(
              color: _GiftSectionConstants.brown,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: const [
              GiftQrCard(
                title: 'ដុល្លារ',
                imagePath: Assets.qrDollar,
                name: 'LIM CHOUNA & SIENG KIMLENG',
              ),
              GiftQrCard(
                title: 'រៀល',
                imagePath: Assets.qrRiel,
                name: 'លឹម ជូណា & សៀង គឹមឡេង',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 220,
            child: ElevatedButton.icon(
              onPressed: () => _handlePaymentAppLaunch(context),
              icon: const Icon(Iconsax.card, size: 18),
              label: Text(
                'បើកកម្មវិធី ABA',
                style: WeddingTextStyles.button.copyWith(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _GiftSectionConstants.gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles launching the payment app
  static Future<void> _handlePaymentAppLaunch(BuildContext context) async {
    const paymentUrl = 'https://pay.ababank.com/oRF8/z80qz2zr';
    final uri = Uri.parse(paymentUrl);
    final success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open ABA PayWay.'),
        ),
      );
    }
  }
}

/// QR code card widget for displaying gift payment QR codes
class GiftQrCard extends StatelessWidget {
  const GiftQrCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.name,
  });

  final String title;
  final String imagePath;
  final String name;

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
        border: Border.all(
          color: _GiftSectionConstants.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: WeddingTextStyles.heading3.copyWith(
              color: _GiftSectionConstants.gold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ShimmerImageAsset(
                    imagePath: imagePath,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: WeddingTextStyles.small.copyWith(
              color: _GiftSectionConstants.brown,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Constants for the gift section
class _GiftSectionConstants {
  _GiftSectionConstants._();
  
  static const Color gold = Color(0xFFB88527);
  static const Color brown = Color(0xFF6F4C0B);
}
