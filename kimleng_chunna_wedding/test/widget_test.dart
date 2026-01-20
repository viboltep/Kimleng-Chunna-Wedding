// Widget tests for Kimleng & Chunna Wedding Invitation
//
// These tests verify that the main components of the wedding invitation
// are properly rendered and functional.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kimlengchouna/main.dart';

void main() {
  group('Wedding Invitation Widget Tests', () {
    testWidgets('App loads and displays wedding invitation', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const WeddingApp());

      // Verify that the main invitation content is displayed
      expect(find.text('Kimleng'), findsOneWidget);
      expect(find.text('Chunna'), findsOneWidget);
      expect(find.text('March 15th, 2025'), findsOneWidget);
    });

    testWidgets('Hero section displays couple names correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const WeddingApp());
      await tester.pumpAndSettle();

      // Verify couple names are displayed
      expect(find.text('Kimleng'), findsOneWidget);
      expect(find.text('Chunna'), findsOneWidget);
      
      // Verify invitation text
      expect(find.text('Together with their families'), findsOneWidget);
      expect(find.text('invite you to celebrate their wedding'), findsOneWidget);
    });

    testWidgets('Wedding details section displays correct information', (WidgetTester tester) async {
      await tester.pumpWidget(const WeddingApp());
      await tester.pumpAndSettle();

      // Verify wedding details are displayed
      expect(find.text('Wedding Details'), findsOneWidget);
      expect(find.text('Date & Time'), findsOneWidget);
      expect(find.text('Venue'), findsOneWidget);
      expect(find.text('Dress Code'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('RSVP section displays form elements', (WidgetTester tester) async {
      await tester.pumpWidget(const WeddingApp());
      await tester.pumpAndSettle();

      // Verify RSVP section
      expect(find.text('RSVP'), findsOneWidget);
      expect(find.text('Please respond by February 15th, 2025'), findsOneWidget);
      expect(find.text('Submit RSVP'), findsOneWidget);
      
      // Verify form fields
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Gallery section displays photo grid', (WidgetTester tester) async {
      await tester.pumpWidget(const WeddingApp());
      await tester.pumpAndSettle();

      // Verify gallery section
      expect(find.text('Our Story'), findsOneWidget);
      expect(find.text('Moments that led us to this beautiful day'), findsOneWidget);
      
      // Verify photo placeholders (should have 6 photo containers)
      expect(find.byIcon(Icons.photo_camera), findsWidgets);
    });

    testWidgets('Footer section displays share functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const WeddingApp());
      await tester.pumpAndSettle();

      // Verify footer content
      expect(find.text('Share Our Joy'), findsOneWidget);
      expect(find.text('Share Invitation'), findsOneWidget);
      expect(find.text('We can\'t wait to celebrate with you!'), findsOneWidget);
    });
  });
}
