import 'package:flutter/material.dart';

class HeartShape extends StatelessWidget {
  final double size;
  final Color color;
  final double borderWidth;
  final Color borderColor;
  final double opacity;

  const HeartShape({
    super.key,
    required this.size,
    required this.color,
    this.borderWidth = 1.0,
    this.borderColor = Colors.white,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HeartPainter(
        color: color.withOpacity(opacity),
        borderColor: borderColor.withOpacity(opacity),
        borderWidth: borderWidth,
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  HeartPainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = _createHeartPath(size);
    
    // Draw filled heart
    canvas.drawPath(path, paint);
    
    // Draw heart border
    canvas.drawPath(path, borderPaint);
  }

  Path _createHeartPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    
    // Heart shape calculation
    final centerX = width / 2;
    final centerY = height / 2;
    final radius = width / 4;
    
    // Left curve of heart
    path.moveTo(centerX, centerY + radius * 0.3);
    path.cubicTo(
      centerX - radius * 1.2, centerY - radius * 0.8,
      centerX - radius * 0.5, centerY - radius * 1.2,
      centerX, centerY - radius * 0.5,
    );
    
    // Right curve of heart
    path.cubicTo(
      centerX + radius * 0.5, centerY - radius * 1.2,
      centerX + radius * 1.2, centerY - radius * 0.8,
      centerX, centerY + radius * 0.3,
    );
    
    // Bottom point of heart
    path.cubicTo(
      centerX - radius * 0.3, centerY + radius * 0.1,
      centerX - radius * 0.1, centerY + radius * 0.3,
      centerX, centerY + radius * 0.3,
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is HeartPainter &&
        (oldDelegate.color != color ||
         oldDelegate.borderColor != borderColor ||
         oldDelegate.borderWidth != borderWidth);
  }
}
