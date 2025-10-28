import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/wedding_theme.dart';

class PhotoPopup extends StatefulWidget {
  const PhotoPopup({Key? key}) : super(key: key);

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
          child: Center(
            child: Container(
              width: 475,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Stack(
                children: [
                  // Clickable area to dismiss
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  
                  // Photo in center
                  Center(
                    child: GestureDetector(
                      onTap: () {}, // Prevent dismissal when clicking photo
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/IMG_8350.jpg',
                          width: 350,
                          height: 350,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    WeddingColors.primary.withOpacity(0.3),
                                    WeddingColors.secondary.withOpacity(0.3),
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
                ],
              ),
            ),
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
