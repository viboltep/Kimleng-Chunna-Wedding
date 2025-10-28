import 'package:flutter/material.dart';
import 'theme/wedding_theme.dart';
import 'widgets/invitation_card.dart';
import 'services/web_music_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start background music when app initializes
  await WebMusicService().startBackgroundMusic();
  
  runApp(const WeddingApp());
}

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kimleng & Chunna Wedding',
      theme: WeddingTheme.lightTheme,
      home: const InvitationCard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
