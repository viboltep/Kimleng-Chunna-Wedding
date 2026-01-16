import 'package:flutter/material.dart';
import '../theme/wedding_theme.dart';

Widget buildGoogleMapView(String embedUrl) {
  return Container(
    color: Colors.black.withValues(alpha: 0.05),
    child: Center(
      child: Text(
        'Google Maps preview is available on web.\nUse "Get Directions" below to open Maps.',
        textAlign: TextAlign.center,
        style: WeddingTextStyles.body,
      ),
    ),
  );
}
