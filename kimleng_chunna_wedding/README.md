# Kimleng & Chunna Wedding Invitation

A beautiful, interactive Flutter Web e-invitation card for Kimleng & Chunna's wedding celebration.

## Features

✨ **Beautiful Design**
- Elegant color palette with wedding-appropriate colors
- Custom typography using Google Fonts (Playfair Display & Crimson Text)
- Smooth animations and transitions

🎨 **Interactive Sections**
- **Photo Popup**: Shows IMG_8350.jpg on page load (instant display, no animations)
- **Hero Section**: Full-screen animated introduction with infinite loop animations, continuous floating elements, live countdown timer, and "Add to Calendar" button
- **Wedding Details**: Date, time, venue, and dress code information
- **Wedding Agenda**: Traditional Khmer wedding ceremony timeline with date selection
- **RSVP Form**: Interactive form for guest responses with validation
- **Photo Gallery**: Showcase couple photos (placeholder images included)
- **Footer**: Share functionality and contact information

📱 **Mobile-First Design**
- Fixed width of 475px for consistent experience across all devices
- Centered layout on desktop platforms
- Optimized for mobile viewing experience

⚡ **Performance Optimized**
- Efficient animations using flutter_animate
- Optimized for web deployment
- Clean, maintainable code structure

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Chrome browser for testing

### Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd kimleng_chunna_wedding
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d chrome
   ```

4. **Run tests**
   ```bash
   # Run basic content tests
   ./run_tests.sh
   
   # Or run individual test files
   dart test test/basic_test.dart
   ```

5. **Build for production**
   ```bash
   flutter build web --release
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── wedding_theme.dart   # Color palette, typography, and theme
├── widgets/
│   ├── invitation_card.dart      # Main invitation widget
│   ├── hero_section.dart          # Hero section with animations
│   ├── wedding_details_section.dart # Wedding details cards
│   ├── rsvp_section.dart          # RSVP form
│   ├── gallery_section.dart       # Photo gallery
│   └── footer_section.dart        # Footer with share functionality
└── utils/
    └── responsive.dart            # Responsive layout helpers
```

## Customization

### Colors
Edit `lib/theme/wedding_theme.dart` to customize the color palette:

```dart
class WeddingColors {
  static const Color primary = Color(0xFF8B4513);      // Saddle Brown
  static const Color secondary = Color(0xFFD2B48C);     // Tan
  static const Color accent = Color(0xFFF5DEB3);        // Wheat
  // ... more colors
}
```

### Content
Update the wedding details in the respective widget files:
- **Hero Section**: Couple names and date in `hero_section.dart`
- **Wedding Details**: Venue, time, dress code in `wedding_details_section.dart`
- **Contact Info**: Phone numbers in `footer_section.dart`

### Images
Replace placeholder images in `assets/images/` with actual couple photos:
- `IMG_8350.jpg` - Main popup photo (shown on page load)
- `couple1.jpg` through `couple6.jpg` - Gallery photos

### Fixed Width Design
The app uses a fixed width of 475px for a consistent mobile-first experience:

```dart
class InvitationCard extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WeddingColors.background,
      body: Center(
        child: Container(
          width: 475,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // All sections here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

This ensures:
- Consistent layout across all devices
- Mobile-optimized experience
- Centered presentation on desktop
- Easy to maintain and customize

### Hero Section Animations
The hero section features sophisticated infinite loop animations that continue playing even when scrolling to the bottom:

```dart
// Infinite floating animation using AnimationController
_floatingController = AnimationController(
  duration: const Duration(seconds: 4),
  vsync: this,
)..repeat(reverse: true);

AnimatedBuilder(
  animation: _floatingController,
  builder: (context, child) {
    return Transform.translate(
      offset: Offset(0, _floatingController.value * -20),
      child: Container(/* floating element */),
    );
  },
)
```

**Infinite Animation Features:**
- **Continuous Floating Elements**: 5 decorative circles with infinite up-down movement
- **Infinite Pulse Effects**: Couple names and decorative line pulse continuously
- **Persistent Scroll Indicator**: Arrow bounces infinitely to guide users
- **Background Shimmer**: Continuous shimmer effects on decorative elements
- **Stateful Animation**: Uses AnimationController for true infinite loops

**Animation Controllers:**
- **Floating Controller**: 4-second duration, reverse repeat for smooth floating
- **Pulse Controller**: 2-second duration, reverse repeat for gentle pulsing
- **Shimmer Controller**: 3-second duration, forward repeat for shimmer effects
- **Scroll Controller**: 1-second duration, reverse repeat for bouncing arrow

**Technical Implementation:**
- **StatefulWidget**: Converted from StatelessWidget to manage animation lifecycle
- **TickerProviderStateMixin**: Provides vsync for smooth animations
- **AnimationController.repeat()**: Creates infinite loops with reverse option
- **AnimatedBuilder**: Efficiently rebuilds only animated parts
- **Transform.translate/scale**: Hardware-accelerated transformations

**Performance Benefits:**
- **Hardware Acceleration**: Uses Transform widgets for optimal performance
- **Efficient Rebuilds**: Only animated elements rebuild, not entire widget tree
- **Memory Efficient**: Proper disposal of animation controllers
- **Smooth 60fps**: Optimized for consistent frame rates

### Countdown Timer Feature
The hero section includes a live countdown timer that shows the remaining time until the wedding:

```dart
// Real-time countdown timer
Timer _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  _updateCountdown();
});

void _updateCountdown() {
  final now = DateTime.now();
  final weddingDate = DateTime(2026, 3, 1);
  final difference = weddingDate.difference(now);
  
  if (mounted) {
    setState(() {
      _timeUntilWedding = difference;
    });
  }
}
```

**Countdown Features:**
- **Live Updates**: Updates every second with real-time countdown
- **Smart Formatting**: Shows days, hours, minutes, and seconds appropriately
- **Elegant Design**: Golden container with shimmer animation effects
- **Wedding Date**: Counts down to March 1st, 2026
- **Performance Optimized**: Efficient timer management with proper disposal

**Display Format:**
- **Days Remaining**: "X days, Y hours, Z minutes" (when > 1 day)
- **Hours Remaining**: "X hours, Y minutes, Z seconds" (when < 1 day)
- **Minutes Remaining**: "X minutes, Y seconds" (when < 1 hour)
- **Seconds Remaining**: "X seconds" (when < 1 minute)

**Visual Design:**
- **Golden Container**: Elegant rounded container with golden background
- **Shimmer Effect**: Subtle shimmer animation for visual appeal
- **Smooth Animation**: Fade-in and slide-up entrance animation
- **Consistent Styling**: Matches the overall wedding theme

### Add to Calendar Button
The hero section includes an "Add to Calendar" button that allows guests to easily add the wedding event to their calendar:

```dart
Future<void> _addToCalendar() async {
  final weddingDate = DateTime(2026, 3, 1, 14, 0); // March 1st, 2026 at 2:00 PM
  final endDate = DateTime(2026, 3, 1, 22, 0); // March 1st, 2026 at 10:00 PM
  
  // Create Google Calendar URL
  final googleCalendarUrl = 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=$startDateStr/$endDateStr&details=$details&location=$location';
  
  if (await canLaunchUrl(Uri.parse(googleCalendarUrl))) {
    await launchUrl(Uri.parse(googleCalendarUrl), mode: LaunchMode.externalApplication);
  }
}
```

**Calendar Features:**
- **One-Click Addition**: Instantly adds wedding event to user's calendar
- **Google Calendar Integration**: Opens Google Calendar with pre-filled event details
- **Complete Event Info**: Includes title, date, time, location, and description
- **Cross-Platform**: Works on web, mobile, and desktop platforms
- **Fallback Support**: Shows event details if calendar app can't be opened

**Event Details:**
- **Title**: "Kimleng & Chunna Wedding"
- **Date**: March 1st, 2026
- **Time**: 2:00 PM - 10:00 PM (Ceremony at 2:00 PM, Reception at 6:00 PM)
- **Location**: "Wedding Venue, Phnom Penh, Cambodia"
- **Description**: Complete wedding invitation message with ceremony and reception times

**Button Design:**
- **Calendar Icon**: Material Design calendar icon for clear recognition
- **Elegant Styling**: Rounded button with wedding theme colors
- **Smooth Animation**: Fade-in, slide-up, and subtle scale animation
- **Professional Look**: Elevated button with proper padding and typography

**User Experience:**
- **Instant Action**: Click button to immediately open calendar app
- **Pre-filled Form**: All event details automatically populated
- **Easy Confirmation**: User just needs to click "Save" in their calendar app
- **Error Handling**: Graceful fallback with event details if calendar can't open

### Wedding Agenda Feature
The app includes a comprehensive wedding agenda section with traditional Khmer ceremonies:

```dart
class WeddingAgendaSection extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('កម្មវិធីសិរីមង្គល'), // Wedding Ceremony Program
          // Date selection tabs
          Row(children: [
            _buildDateTab('23 មីនា'), // March 23
            _buildDateTab('24 មីនា'), // March 24
          ]),
          // Timeline of events
          Column(children: agendaItems.map((item) => 
            _buildAgendaItem(item['time'], item['event'])
          ).toList()),
        ],
      ),
    );
  }
}
```

Features:
- **Date Selection**: Toggle between March 23rd and 24th ceremonies
- **Traditional Ceremonies**: Complete Khmer wedding ceremony timeline
- **Dialog Design**: Card-style layout with gradient background and enhanced shadows
- **Custom Golden Design**: Elegant #b88527 color scheme with calendar icons
- **Interactive Tabs**: Click to switch between ceremony days
- **Timeline Layout**: Clear time-based event organization
- **Khmer Typography**: Uses Moulpali font via Google Fonts for authentic Khmer text display (✅ Active)
- **Enhanced Shadows**: Multi-layered shadow effects for depth and elegance

### Photo Popup Feature
The app includes a beautiful photo popup that appears when the page loads:

```dart
class PhotoPopup extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    // Show popup after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showPhotoDialog();
      }
    });
  }
}
```

Features:
- **Automatic Display**: Shows IMG_8350.jpg on page load
- **Contained Dimming**: Lighter dark overlay (50% opacity) covers the 475px webpage area
- **Clean Design**: No rounded corners for sharp, modern look
- **Instant Display**: No animations for immediate photo visibility
- **Smart Click Behavior**: Click outside photo to dismiss, click photo to keep open
- **Error Handling**: Falls back to placeholder if image not found
- **Responsive**: Works perfectly with the 475px fixed width design

## Font Setup

The wedding agenda section uses the Moulpali Khmer font via Google Fonts for authentic text display:

```dart
TextStyle(
  fontFamily: GoogleFonts.moulpali(),
  fontSize: 32,
  fontWeight: FontWeight.w600,
  color: const Color(0xFFb88527),
)
```

### Font Configuration:
- **Font Source**: Google Fonts API
- **Font Family**: `GoogleFonts.moulpali()`
- **Status**: ✅ **Active and Working**
- **Benefits**: Automatic font loading, better performance, no local files needed

### Font Usage:
The Moulpali font is used for all Khmer text in the wedding agenda:
- **Main Title**: "កម្មវិធីសិរីមង្គល" (Wedding Ceremony Program)
- **Date Tabs**: "23 មីនា", "24 មីនា" (March 23, March 24)
- **Event Times**: "ម៉ោង 1:30 រសៀល", etc.
- **Event Descriptions**: Traditional Khmer ceremony names

### Google Fonts Benefits:
- **Automatic Loading**: Fonts loaded dynamically from Google's CDN
- **Better Performance**: Optimized font delivery and caching
- **No Local Files**: No need to manage font files in the project
- **Cross-Platform**: Works consistently across all platforms
- **Easy Maintenance**: Simple API for font management

## Testing

The project includes comprehensive tests to ensure the wedding invitation works correctly:

### Test Files
- `test/basic_test.dart` - Basic content and data validation tests
- `test/widget_test.dart` - Widget integration tests
- `test/unit_test.dart` - Unit tests for theme and components

### Running Tests
```bash
# Run all basic tests
./run_tests.sh

# Run specific test file
dart test test/basic_test.dart

# Run Flutter widget tests (requires Flutter test environment)
flutter test
```

### Test Coverage
The tests verify:
- ✅ Wedding content (dates, names, venue, contact info)
- ✅ Color palette and typography
- ✅ Widget rendering and functionality
- ✅ Form validation
- ✅ Responsive design

## Deployment

### Firebase Hosting
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init hosting`
4. Build: `flutter build web --release`
5. Deploy: `firebase deploy`

### GitHub Pages
1. Build: `flutter build web --base-href "/kimleng-chunna-wedding/"`
2. Copy `build/web/*` to `docs/` folder
3. Commit and push to GitHub

### Netlify/Vercel
1. Build: `flutter build web --release`
2. Upload `build/web/` folder to your hosting service

## Dependencies

- **flutter_animate**: Smooth animations and transitions
- **google_fonts**: Beautiful typography
- **url_launcher**: Open maps and external links
- **share_plus**: Share invitation functionality
- **provider**: State management (ready for future enhancements)

## Browser Support

- Chrome (recommended)
- Firefox
- Safari
- Edge

## Contributing

This is a wedding invitation project. For any modifications or enhancements, please coordinate with the wedding couple.

## License

This project is created specifically for Kimleng & Chunna's wedding celebration.

---

**Made with ❤️ for Kimleng & Chunna's special day**

March 15th, 2025