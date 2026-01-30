import 'package:flutter/material.dart';
import 'theme/wedding_theme.dart';
import 'widgets/home_screen.dart';
import 'widgets/welcome_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeddingApp());
}

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kimleng & Chunna',
      theme: WeddingTheme.lightTheme,
      home: const EntryFlow(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class EntryFlow extends StatefulWidget {
  const EntryFlow({super.key});

  @override
  State<EntryFlow> createState() => _EntryFlowState();
}

class _EntryFlowState extends State<EntryFlow> {
  bool _showHome = false;

  void _openHome() {
    setState(() {
      _showHome = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showHome) {
      return const HomeScreen();
    }
    return WelcomeCard(onOpen: _openHome);
  }
}
