# Flutter Web E-Invitation Card Development Guide

## Overview
This document provides a comprehensive guide for creating a beautiful, interactive e-invitation card using Flutter Web, inspired by modern wedding invitation designs like reach-and-sona.web.app.

## Table of Contents
1. [Project Setup](#project-setup)
2. [Design System](#design-system)
3. [Core Components](#core-components)
4. [Animation & Interactions](#animation--interactions)
5. [Responsive Design](#responsive-design)
6. [Deployment](#deployment)
7. [Code Examples](#code-examples)

## Project Setup

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Chrome browser for testing
- Code editor (VS Code recommended)

### Initialize Flutter Web Project
```bash
# Create new Flutter project
flutter create kimleng_chunna_wedding --platforms web

# Navigate to project directory
cd kimleng_chunna_wedding

# Enable web support
flutter config --enable-web

# Run on web
flutter run -d chrome
```

### Dependencies
Add these packages to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI & Animation
  flutter_animate: ^4.5.0
  google_fonts: ^6.1.0
  lottie: ^2.7.0
  
  # State Management
  provider: ^6.1.1
  
  # Utilities
  url_launcher: ^6.2.2
  share_plus: ^7.2.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Design System

### Color Palette
```dart
class WeddingColors {
  static const Color primary = Color(0xFF8B4513);      // Saddle Brown
  static const Color secondary = Color(0xFFD2B48C);     // Tan
  static const Color accent = Color(0xFFF5DEB3);        // Wheat
  static const Color background = Color(0xFFFEFEFE);    // Off White
  static const Color textPrimary = Color(0xFF2C1810);   // Dark Brown
  static const Color textSecondary = Color(0xFF6B5B47); // Medium Brown
  static const Color gold = Color(0xFFFFD700);          // Gold
}
```

### Typography
```dart
class WeddingTextStyles {
  static TextStyle get heading1 => GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: WeddingColors.textPrimary,
  );
  
  static TextStyle get heading2 => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: WeddingColors.textPrimary,
  );
  
  static TextStyle get body => GoogleFonts.sourceSerifPro(
    fontSize: 16,
    color: WeddingColors.textSecondary,
    height: 1.6,
  );
  
  static TextStyle get caption => GoogleFonts.sourceSerifPro(
    fontSize: 14,
    color: WeddingColors.textSecondary,
    fontStyle: FontStyle.italic,
  );
}
```

## Core Components

### 1. Main Invitation Card Widget
```dart
class InvitationCard extends StatefulWidget {
  const InvitationCard({Key? key}) : super(key: key);

  @override
  State<InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends State<InvitationCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WeddingColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            HeroSection(),
            
            // Couple Names
            CoupleNamesSection(),
            
            // Wedding Details
            WeddingDetailsSection(),
            
            // RSVP Section
            RSVPSection(),
            
            // Gallery Section
            GallerySection(),
            
            // Footer
            FooterSection(),
          ],
        ),
      ),
    );
  }
}
```

### 2. Hero Section with Animated Background
```dart
class HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            WeddingColors.primary.withOpacity(0.1),
            WeddingColors.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background elements
          Positioned(
            top: 100,
            left: 50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WeddingColors.gold.withOpacity(0.1),
              ),
            ).animate().fadeIn(duration: 2.seconds).scale(),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Together with their families',
                  style: WeddingTextStyles.caption,
                ).animate().fadeIn(delay: 500.ms),
                
                SizedBox(height: 20),
                
                Text(
                  'Kimleng & Chunna',
                  style: WeddingTextStyles.heading1,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 1.seconds).slideY(),
                
                SizedBox(height: 20),
                
                Text(
                  'invite you to celebrate their wedding',
                  style: WeddingTextStyles.body,
                ).animate().fadeIn(delay: 1.5.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. Wedding Details Section
```dart
class WeddingDetailsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          // Date & Time
          DetailCard(
            icon: Icons.calendar_today,
            title: 'Date & Time',
            content: 'Saturday, March 15th, 2025\n4:00 PM',
          ).animate().fadeIn(delay: 2.seconds),
          
          SizedBox(height: 30),
          
          // Venue
          DetailCard(
            icon: Icons.location_on,
            title: 'Venue',
            content: 'Garden Palace Resort\n123 Wedding Lane\nPhnom Penh, Cambodia',
            actionText: 'Get Directions',
            onAction: () => _launchMaps(),
          ).animate().fadeIn(delay: 2.2.seconds),
          
          SizedBox(height: 30),
          
          // Dress Code
          DetailCard(
            icon: Icons.checkroom,
            title: 'Dress Code',
            content: 'Semi-Formal\nSuggested colors: Pastels & Earth tones',
          ).animate().fadeIn(delay: 2.4.seconds),
        ],
      ),
    );
  }
  
  void _launchMaps() async {
    // Implementation for opening maps
  }
}
```

### 4. RSVP Section
```dart
class RSVPSection extends StatefulWidget {
  @override
  State<RSVPSection> createState() => _RSVPSectionState();
}

class _RSVPSectionState extends State<RSVPSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _guestsController = TextEditingController();
  bool _isAttending = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: WeddingColors.accent.withOpacity(0.3),
      ),
      child: Column(
        children: [
          Text(
            'RSVP',
            style: WeddingTextStyles.heading2,
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Please respond by February 15th, 2025',
            style: WeddingTextStyles.body,
          ),
          
          SizedBox(height: 30),
          
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Please enter your name' : null,
                ),
                
                SizedBox(height: 20),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Please enter your email' : null,
                ),
                
                SizedBox(height: 20),
                
                // Attendance toggle
                Row(
                  children: [
                    Text('Will you be attending?'),
                    SizedBox(width: 20),
                    Switch(
                      value: _isAttending,
                      onChanged: (value) => setState(() => _isAttending = value),
                    ),
                    Text(_isAttending ? 'Yes' : 'No'),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Number of guests
                TextFormField(
                  controller: _guestsController,
                  decoration: InputDecoration(
                    labelText: 'Number of Guests',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                
                SizedBox(height: 30),
                
                // Submit button
                ElevatedButton(
                  onPressed: _submitRSVP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WeddingColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text('Submit RSVP'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _submitRSVP() {
    if (_formKey.currentState!.validate()) {
      // Handle RSVP submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you for your RSVP!')),
      );
    }
  }
}
```

## Animation & Interactions

### Parallax Scrolling Effect
```dart
class ParallaxWidget extends StatelessWidget {
  final Widget child;
  final double offset;

  const ParallaxWidget({
    Key? key,
    required this.child,
    this.offset = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Transform.translate(
            offset: Offset(0, offset * constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}
```

### Page Transitions
```dart
class PageTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const PageTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child.animate()
        .fadeIn(duration: duration)
        .slideY(begin: 0.3, end: 0);
  }
}
```

## Responsive Design

### Responsive Layout Helper
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### Responsive Text Sizing
```dart
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ResponsiveText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 14.0 : 16.0;
    
    return Text(
      text,
      style: style?.copyWith(fontSize: fontSize) ?? TextStyle(fontSize: fontSize),
      textAlign: textAlign,
    );
  }
}
```

## Deployment

### Build for Production
```bash
# Build Flutter web app
flutter build web --release

# The built files will be in build/web/
```

### Firebase Hosting Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init hosting

# Deploy
firebase deploy
```

### GitHub Pages Deployment
```bash
# Build the app
flutter build web --base-href "/kimleng-chunna-wedding/"

# Copy build/web contents to docs folder
cp -r build/web/* docs/

# Commit and push
git add docs/
git commit -m "Deploy wedding invitation"
git push origin main
```

## Additional Features

### Photo Gallery
```dart
class GallerySection extends StatelessWidget {
  final List<String> imageUrls = [
    'assets/images/couple1.jpg',
    'assets/images/couple2.jpg',
    'assets/images/couple3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            'Our Story',
            style: WeddingTextStyles.heading2,
          ),
          SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showImageDialog(context, imageUrls[index]),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(imageUrls[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.asset(imageUrl),
      ),
    );
  }
}
```

### Music Player
```dart
class MusicPlayer extends StatefulWidget {
  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: () {
          setState(() => _isPlaying = !_isPlaying);
          // Implement music playback
        },
        backgroundColor: WeddingColors.primary,
        child: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
}
```

## Performance Optimization

### Image Optimization
```dart
class OptimizedImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OptimizedImage({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }
}
```

### Lazy Loading
```dart
class LazyLoadWidget extends StatefulWidget {
  final Widget child;
  final double threshold;

  const LazyLoadWidget({
    Key? key,
    required this.child,
    this.threshold = 0.1,
  }) : super(key: key);

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('lazy-load-${widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction >= widget.threshold && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: _isVisible ? widget.child : Container(),
    );
  }
}
```

## Conclusion

This guide provides a comprehensive foundation for creating a beautiful, interactive Flutter Web e-invitation card. The modular approach allows for easy customization and extension. Remember to:

1. Test across different screen sizes and browsers
2. Optimize images and assets for web
3. Implement proper error handling
4. Add analytics for tracking engagement
5. Consider accessibility features
6. Test loading performance

For the Kimleng & Chunna wedding invitation, customize the colors, fonts, and content to match your specific theme and requirements.
