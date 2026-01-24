import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shared shimmer image widget with rounded corners support.
class ShimmerImageAsset extends StatefulWidget {
  const ShimmerImageAsset({
    super.key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String imagePath;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerImageAsset> createState() => _ShimmerImageAssetState();
}

class _ShimmerImageAssetState extends State<ShimmerImageAsset> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.zero;
    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (_isLoading)
            _ShimmerPlaceholder(
              width: widget.width,
              height: widget.height,
              borderRadius: widget.borderRadius,
            ),
          Image.asset(
            widget.imagePath,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                if (_isLoading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  });
                }
                return child;
              }
              return _ShimmerPlaceholder(
                width: widget.width,
                height: widget.height,
                borderRadius: widget.borderRadius,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder({
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
      ),
    );
  }
}
