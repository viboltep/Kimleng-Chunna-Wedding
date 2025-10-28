# Moulpali Font Setup

To use the Moulpali Khmer font in this Flutter app, you need to download the font files and place them in this directory.

## Required Font Files:
- `Moulpali.ttf` - Regular weight
- `Moulpali-Bold.ttf` - Bold weight (700)

## Where to Download:
1. **Google Fonts**: Search for "Moulpali" on fonts.google.com
2. **Khmer Fonts**: Visit khmerfonts.info or similar Khmer font websites
3. **Font Squirrel**: Check for Moulpali font downloads

## Installation Steps:
1. Download the Moulpali font files
2. Place `Moulpali.ttf` and `Moulpali-Bold.ttf` in this `fonts/` directory
3. Run `flutter pub get` to refresh dependencies
4. Run `flutter build web --release` to test the font

## Font Usage:
The font is already configured in the wedding agenda section:
- Main title: "កម្មវិធីសិរីមង្គល"
- Date tabs: "23 មីនា", "24 មីនា"
- Event times and descriptions

## Fallback:
If the font files are not available, the app will fall back to the system default font for Khmer text display.
