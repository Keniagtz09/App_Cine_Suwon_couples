import 'package:flutter/material.dart';

import '../core/theme/irworobongdo_theme.dart';

class IrworobongdoMountainIcon extends StatelessWidget {
  const IrworobongdoMountainIcon({
    super.key,
    this.size = 26,
    this.isSelected = false,
  });

  final double size;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.35,
      height: size,
      child: CustomPaint(
        painter: _MountainPeaksPainter(isSelected: isSelected),
      ),
    );
  }
}

class _MountainPeaksPainter extends CustomPainter {
  const _MountainPeaksPainter({required this.isSelected});

  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final backPeakPaint = Paint()
      ..color = isSelected
          ? IrworobongdoColors.vermilion.withValues(alpha: 0.78)
          : IrworobongdoColors.warmGold.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final frontPeakPaint = Paint()
      ..color = isSelected
          ? IrworobongdoColors.warmGold
          : IrworobongdoColors.mutedIvory
      ..style = PaintingStyle.fill;

    // Picos secundarios (fondo)
    final backPath = Path()
      ..moveTo(0, h * 0.92)
      ..quadraticBezierTo(w * 0.16, h * 0.25, w * 0.30, h * 0.65)
      ..quadraticBezierTo(w * 0.50, h * 0.05, w * 0.70, h * 0.65)
      ..quadraticBezierTo(w * 0.84, h * 0.25, w, h * 0.92)
      ..close();

    // Picos principales (frente, estilo Irworobongdo)
    final frontPath = Path()
      ..moveTo(w * 0.06, h * 0.92)
      ..quadraticBezierTo(w * 0.22, h * 0.42, w * 0.36, h * 0.78)
      ..quadraticBezierTo(w * 0.50, h * 0.18, w * 0.64, h * 0.78)
      ..quadraticBezierTo(w * 0.78, h * 0.42, w * 0.94, h * 0.92)
      ..close();

    canvas.drawPath(backPath, backPeakPaint);
    canvas.drawPath(frontPath, frontPeakPaint);
  }

  @override
  bool shouldRepaint(covariant _MountainPeaksPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected;
  }
}