import 'package:flutter/material.dart';
import '../theme/wedding_theme.dart';

class PhotoPopup extends StatefulWidget {
  const PhotoPopup({super.key});

  @override
  State<PhotoPopup> createState() => _PhotoPopupState();
}

class _PhotoPopupState extends State<PhotoPopup> {
  @override
  void initState() {
    super.initState();
    // Show popup after a short delay to ensure the page is loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showPhotoDialog();
      }
    });
  }

  void _showPhotoDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Clickable area to dismiss
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
              
              // Photo in center
              Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent dismissal when clicking photo
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
                        'assets/images/IMG_8350.jpg',
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_camera,
                                  size: 80,
                                  color: WeddingColors.white,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'IMG_8350.jpg',
                                  style: WeddingTextStyles.heading2.copyWith(
                                    color: WeddingColors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Special Moment',
                                  style: WeddingTextStyles.bodyLarge.copyWith(
                                    color: WeddingColors.white,
                                  ),
                                  textAlign: TextAlign.center,
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
                top: 20,
                right: 20,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // This widget doesn't render anything
  }
}
