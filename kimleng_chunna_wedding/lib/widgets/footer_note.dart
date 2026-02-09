import 'package:flutter/material.dart';

import '../constants/assets.dart';
import '../theme/wedding_theme.dart';

/// Footer section with logo and "Made with love" note.
class FooterNote extends StatelessWidget {
  const FooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;
    const heartColor = Colors.red;

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
                  color: textColor,
                  fontSize: 14,
                ),
              ),
              Icon(Icons.favorite, color: heartColor, size: 18),
              Text(
                ' for your special day',
                style: WeddingTextStyles.body.copyWith(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
            Text(
              'SIENG KIMLENG & LIM CHOUNA',
              style: WeddingTextStyles.small.copyWith(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
