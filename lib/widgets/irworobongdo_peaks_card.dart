import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/theme/irworobongdo_theme.dart';

class IrworobongdoPeaksCard extends StatelessWidget {
  const IrworobongdoPeaksCard({
    super.key,
    required this.watchedCount,
    required this.totalSavedCount,
    required this.onTap,
  });

  final int watchedCount;
  final int totalSavedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headline = watchedCount == 1
        ? '¡Llevamos 1 peli juntos!'
        : '¡Llevamos $watchedCount pelis juntos!';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: const Color(0xFF14274E),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 178,
            width: double.infinity,
            child: Stack(
              children: [
                // Ilustración vectorial Irworobongdo (Sol, Luna, 5 picos y olas)
                const Positioned.fill(
                  child: CustomPaint(
                    painter: _IrworobongdoScenePainter(),
                  ),
                ),
                // Textos superiores
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: textTheme.titleLarge?.copyWith(
                          color: IrworobongdoColors.ivory,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalSavedCount películas guardadas en su sala privada',
                        style: textTheme.bodyMedium?.copyWith(
                          color: IrworobongdoColors.ivory.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IrworobongdoScenePainter extends CustomPainter {
  const _IrworobongdoScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Luna marfil (izquierda) y Sol bermellón (derecha)
    final moonPaint = Paint()
      ..color = IrworobongdoColors.ivory
      ..style = PaintingStyle.fill;
    final sunPaint = Paint()
      ..color = IrworobongdoColors.vermilion
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.21, h * 0.42), 11, moonPaint);
    canvas.drawCircle(Offset(w * 0.79, h * 0.42), 11, sunPaint);

    // 2. Cinco picos de Irworobongdo (capas jade y verde profundo con vetas)
    _drawPeak(
      canvas: canvas,
      centerX: w * 0.11,
      peakY: h * 0.50,
      baseWidth: w * 0.30,
      baseY: h * 0.88,
      outerColor: const Color(0xFF1F4E4A),
      innerColor: const Color(0xFF397D70),
    );
    _drawPeak(
      canvas: canvas,
      centerX: w * 0.89,
      peakY: h * 0.50,
      baseWidth: w * 0.30,
      baseY: h * 0.88,
      outerColor: const Color(0xFF1F4E4A),
      innerColor: const Color(0xFF397D70),
    );
    _drawPeak(
      canvas: canvas,
      centerX: w * 0.29,
      peakY: h * 0.43,
      baseWidth: w * 0.34,
      baseY: h * 0.88,
      outerColor: const Color(0xFF28635B),
      innerColor: const Color(0xFF4B9989),
    );
    _drawPeak(
      canvas: canvas,
      centerX: w * 0.71,
      peakY: h * 0.43,
      baseWidth: w * 0.34,
      baseY: h * 0.88,
      outerColor: const Color(0xFF28635B),
      innerColor: const Color(0xFF4B9989),
    );
    // Pico central dominante
    _drawPeak(
      canvas: canvas,
      centerX: w * 0.50,
      peakY: h * 0.36,
      baseWidth: w * 0.40,
      baseY: h * 0.88,
      outerColor: const Color(0xFF2D6E64),
      innerColor: const Color(0xFF56A897),
    );

    // 3. Cresta de espuma blanca en la base de las montañas
    final foamPaint = Paint()
      ..color = IrworobongdoColors.ivory.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (double x = 8; x < w; x += 26) {
      final crest = Path()
        ..moveTo(x, h * 0.84)
        ..quadraticBezierTo(x + 6, h * 0.76, x + 13, h * 0.82)
        ..quadraticBezierTo(x + 17, h * 0.77, x + 22, h * 0.84);
      canvas.drawPath(crest, foamPaint);
    }

    // 4. Olas tradicionales coreanas (abanicos concéntricos en la base)
    final waveFill = Paint()
      ..color = const Color(0xFF26302E)
      ..style = PaintingStyle.fill;
    final waveRing = Paint()
      ..color = const Color(0xFF7D8A82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    const double waveRadius = 24;
    for (int row = 0; row < 2; row++) {
      final yCenter = h * (0.91 + row * 0.08);
      final xOffset = row.isOdd ? waveRadius * 0.5 : 0.0;
      for (double x = -waveRadius + xOffset;
          x <= w + waveRadius;
          x += waveRadius * 1.45) {
        final center = Offset(x, yCenter);
        canvas.drawCircle(center, waveRadius, waveFill);
        for (double r = waveRadius; r >= 8; r -= 5.5) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: r),
            math.pi,
            math.pi,
            false,
            waveRing,
          );
        }
      }
    }
  }

  void _drawPeak({
    required Canvas canvas,
    required double centerX,
    required double peakY,
    required double baseWidth,
    required double baseY,
    required Color outerColor,
    required Color innerColor,
  }) {
    final halfW = baseWidth / 2;
    final outlinePaint = Paint()
      ..color = const Color(0xFF0E1B33)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final outerPath = Path()
      ..moveTo(centerX - halfW, baseY)
      ..quadraticBezierTo(
        centerX - halfW * 0.42,
        peakY + (baseY - peakY) * 0.15,
        centerX,
        peakY,
      )
      ..quadraticBezierTo(
        centerX + halfW * 0.42,
        peakY + (baseY - peakY) * 0.15,
        centerX + halfW,
        baseY,
      )
      ..close();

    final innerHalfW = halfW * 0.62;
    final innerPeakY = peakY + (baseY - peakY) * 0.16;
    final innerPath = Path()
      ..moveTo(centerX - innerHalfW, baseY)
      ..quadraticBezierTo(
        centerX - innerHalfW * 0.42,
        innerPeakY + (baseY - innerPeakY) * 0.15,
        centerX,
        innerPeakY,
      )
      ..quadraticBezierTo(
        centerX + innerHalfW * 0.42,
        innerPeakY + (baseY - innerPeakY) * 0.15,
        centerX + innerHalfW,
        baseY,
      )
      ..close();

    canvas.drawPath(outerPath, Paint()..color = outerColor);
    canvas.drawPath(outerPath, outlinePaint);
    canvas.drawPath(innerPath, Paint()..color = innerColor);
  }

  @override
  bool shouldRepaint(covariant _IrworobongdoScenePainter oldDelegate) => false;
}