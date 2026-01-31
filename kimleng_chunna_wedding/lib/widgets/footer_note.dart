import 'package:flutter/material.dart';

import '../constants/assets.dart';
import '../theme/wedding_theme.dart';

/// Footer section with logo and "Made with love" note.
class FooterNote extends StatelessWidget {
  const FooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF6F4C0B);
    const gold = Color(0xFFB88527);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            Assets.logo,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Made with ',
                style: WeddingTextStyles.body.copyWith(
                  color: brown.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              Icon(Icons.favorite, color: gold, size: 18),
              Text(
                ' for your special day',
                style: WeddingTextStyles.body.copyWith(
                  color: brown.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kimleng & Chunna',
            style: WeddingTextStyles.small.copyWith(
              color: gold.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
