import 'package:flutter/material.dart';
import '../theme/wedding_theme.dart';
import '../widgets/hero_section.dart';
import '../widgets/wedding_details_section.dart';
import '../widgets/wedding_agenda_section.dart';
import '../widgets/location_section.dart';
import '../widgets/rsvp_section.dart';
import '../widgets/gallery_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/photo_popup.dart';

class InvitationCard extends StatefulWidget {
  const InvitationCard({Key? key}) : super(key: key);

  @override
  State<InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends State<InvitationCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WeddingColors.background,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 475,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // Hero Section
                    const HeroSection(),
                    
                    // Wedding Details
                    const WeddingDetailsSection(),
                    
                      // Wedding Agenda
                      const WeddingAgendaSection(),
                      
                      // Location Section
                      const LocationSection(),
                      
                      // RSVP Section
                      const RSVPSection(),
                    
                    // Gallery Section
                    const GallerySection(),
                    
                    // Footer
                    const FooterSection(),
                  ],
                ),
              ),
            ),
          ),
          
          // Photo Popup
          const PhotoPopup(),
        ],
      ),
    );
  }
}
