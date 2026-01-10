import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/wedding_theme.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  // Placeholder images - replace with actual couple photos
  static const List<String> imageUrls = [
    'assets/images/couple1.jpg',
    'assets/images/couple2.jpg',
    'assets/images/couple3.jpg',
    'assets/images/couple4.jpg',
    'assets/images/couple5.jpg',
    'assets/images/couple6.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Section title
          Text(
            'Our Story',
            style: WeddingTextStyles.heading2,
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 500.ms, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 20),
          
          Text(
            'Moments that led us to this beautiful day',
            style: WeddingTextStyles.body,
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 700.ms, duration: 1.seconds)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 30),
          
          // Photo grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showImageDialog(context, imageUrls[index], index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: WeddingColors.primary.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                    child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        // Actual image
                        Image.asset(
                          imageUrls[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    WeddingColors.primary.withValues(alpha: 0.3),
                                    WeddingColors.secondary.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.photo_camera,
                                  size: 40,
                                  color: WeddingColors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Overlay with photo number
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: WeddingColors.primary.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: WeddingTextStyles.small.copyWith(
                                color: WeddingColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate()
                  .fadeIn(delay: (1 + index * 0.1).seconds, duration: 1.seconds)
                  .scale(begin: const Offset(0.8, 0.8));
            },
          ),
          
          const SizedBox(height: 40),
          
          // Call to action
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WeddingColors.primary.withValues(alpha: 0.1),
                  WeddingColors.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  size: 40,
                  color: WeddingColors.primary,
                ),
                const SizedBox(height: 15),
                Text(
                  'Thank you for being part of our journey',
                  style: WeddingTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'We can\'t wait to celebrate this special day with all of you!',
                  style: WeddingTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate()
              .fadeIn(delay: 2.seconds, duration: 1.seconds)
              .slideY(begin: 0.3),
        ],
      ),
    );
  }
  
  void _showImageDialog(BuildContext context, String imageUrl, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Background overlay
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
            
            // Image
            Center(
              child: GestureDetector(
                onTap: () {}, // Prevent dismissal when clicking image
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 350,
                          height: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                WeddingColors.primary.withValues(alpha: 0.3),
                                WeddingColors.secondary.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_camera,
                                size: 80,
                                color: WeddingColors.white,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Photo ${index + 1}',
                                style: WeddingTextStyles.heading3.copyWith(
                                  color: WeddingColors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Image not found',
                                style: WeddingTextStyles.body.copyWith(
                                  color: WeddingColors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // Close button
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
