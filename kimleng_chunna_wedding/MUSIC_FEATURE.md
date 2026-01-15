# Music Feature Implementation

## Overview
The wedding invitation website now includes automatic background music that starts playing when the webpage loads.

## Features
- **Automatic Playback**: Music starts automatically when the webpage loads
- **Loop Playback**: The music loops continuously for a pleasant background experience
- **Volume Control**: Music plays at 30% volume for comfortable listening
- **User Control**: Users can pause/resume music using the floating action button
- **Web Optimized**: Configured specifically for web browsers

## Implementation Details

### Music Service (`lib/services/music_service.dart`)
- Singleton service that manages audio playback
- Handles web-specific audio context configuration
- Provides methods for play, pause, stop, and volume control
- Automatically loops the music file

### Integration Points
1. **Main App Initialization** (`lib/main.dart`):
   - Music service starts automatically when the app initializes
   - Uses `WidgetsFlutterBinding.ensureInitialized()` for proper async handling

2. **User Interface** (`lib/widgets/invitation_card.dart`):
   - Floating action button for music control
   - Visual feedback showing play/pause state
   - Positioned at bottom-left for easy access

### Music File
- **File**: `assets/music/plov-chivit-rum-knea.mp3`
- **Format**: MP3 (web-compatible)
- **Usage**: Automatically loaded as an asset

## User Experience
- Music starts playing immediately when the page loads
- Users can click the music note icon to pause/resume
- Icon changes to show current state (music note = playing, music off = paused)
- Tooltip provides clear indication of current action

## Technical Notes
- Uses `audioplayers` package for cross-platform audio support
- Configured with `AudioContext()` for web compatibility
- Volume set to 0.3 (30%) for comfortable background listening
- Release mode set to `loop` for continuous playback
- Error handling included for graceful degradation

## Browser Compatibility
- Works in all modern web browsers
- Requires user interaction for autoplay in some browsers (handled by Flutter)
- Optimized for web audio context
