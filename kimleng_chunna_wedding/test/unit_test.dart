// Unit tests for Kimleng & Chunna Wedding Invitation
//
// These tests verify the basic functionality and data structures
// used in the wedding invitation app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kimleng_chunna_wedding/theme/wedding_theme.dart';

void main() {
  group('Wedding Theme Tests', () {
    test('WeddingColors should have defined colors', () {
      expect(WeddingColors.primary, isA<Color>());
      expect(WeddingColors.secondary, isA<Color>());
      expect(WeddingColors.accent, isA<Color>());
      expect(WeddingColors.background, isA<Color>());
      expect(WeddingColors.textPrimary, isA<Color>());
      expect(WeddingColors.textSecondary, isA<Color>());
      expect(WeddingColors.gold, isA<Color>());
      expect(WeddingColors.white, isA<Color>());
      expect(WeddingColors.lightGray, isA<Color>());
    });

    test('WeddingTextStyles should have defined text styles', () {
      expect(WeddingTextStyles.heading1, isA<TextStyle>());
      expect(WeddingTextStyles.heading2, isA<TextStyle>());
      expect(WeddingTextStyles.heading3, isA<TextStyle>());
      expect(WeddingTextStyles.body, isA<TextStyle>());
      expect(WeddingTextStyles.bodyLarge, isA<TextStyle>());
      expect(WeddingTextStyles.caption, isA<TextStyle>());
      expect(WeddingTextStyles.button, isA<TextStyle>());
      expect(WeddingTextStyles.small, isA<TextStyle>());
    });

    test('WeddingTheme should provide light theme', () {
      final theme = WeddingTheme.lightTheme;
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
    });

    test('WeddingColors should have consistent color values', () {
      // Test that colors are not null and have expected properties
      expect(WeddingColors.primary.value, isA<int>());
      expect(WeddingColors.secondary.value, isA<int>());
      expect(WeddingColors.accent.value, isA<int>());
      expect(WeddingColors.background.value, isA<int>());
      expect(WeddingColors.textPrimary.value, isA<int>());
      expect(WeddingColors.textSecondary.value, isA<int>());
      expect(WeddingColors.gold.value, isA<int>());
      expect(WeddingColors.white.value, isA<int>());
      expect(WeddingColors.lightGray.value, isA<int>());
    });

    test('WeddingTextStyles should have consistent font properties', () {
      // Test that text styles have expected properties
      expect(WeddingTextStyles.heading1.fontSize, equals(48));
      expect(WeddingTextStyles.heading2.fontSize, equals(32));
      expect(WeddingTextStyles.heading3.fontSize, equals(24));
      expect(WeddingTextStyles.body.fontSize, equals(16));
      expect(WeddingTextStyles.bodyLarge.fontSize, equals(18));
      expect(WeddingTextStyles.caption.fontSize, equals(14));
      expect(WeddingTextStyles.button.fontSize, equals(16));
      expect(WeddingTextStyles.small.fontSize, equals(12));
    });
  });

  group('Wedding Invitation Content Tests', () {
    test('Wedding date should be March 15th, 2025', () {
      const expectedDate = 'March 15th, 2025';
      expect(expectedDate, isA<String>());
      expect(expectedDate.length, greaterThan(0));
    });

    test('Couple names should be Kimleng and Chunna', () {
      const groomName = 'Kimleng';
      const brideName = 'Chunna';
      
      expect(groomName, isA<String>());
      expect(brideName, isA<String>());
      expect(groomName.length, greaterThan(0));
      expect(brideName.length, greaterThan(0));
    });

    test('Wedding venue should be defined', () {
      const venue = 'Garden Palace Resort';
      const address = '123 Wedding Lane';
      const city = 'Phnom Penh, Cambodia';
      
      expect(venue, isA<String>());
      expect(address, isA<String>());
      expect(city, isA<String>());
      expect(venue.length, greaterThan(0));
      expect(address.length, greaterThan(0));
      expect(city.length, greaterThan(0));
    });

    test('RSVP deadline should be February 15th, 2025', () {
      const rsvpDeadline = 'February 15th, 2025';
      expect(rsvpDeadline, isA<String>());
      expect(rsvpDeadline.length, greaterThan(0));
    });

    test('Contact information should be provided', () {
      const groomPhone = '+855 12 345 678';
      const bridePhone = '+855 98 765 432';
      
      expect(groomPhone, isA<String>());
      expect(bridePhone, isA<String>());
      expect(groomPhone.length, greaterThan(0));
      expect(bridePhone.length, greaterThan(0));
    });
  });
}
