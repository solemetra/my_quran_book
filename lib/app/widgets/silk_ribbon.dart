import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_quran/app/design_tokens.dart';
import 'package:my_quran/app/services/ribbon_bookmark_service.dart';

/// A physical-style silk cloth bookmark (Ляссе / شريط علامة القراءة)
/// that elegantly hangs from the top edge of a Quran page.
class SilkRibbonWidget extends StatelessWidget {
  const SilkRibbonWidget({
    required this.pageNumber,
    required this.isAr,
    super.key,
  });

  final int pageNumber;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ribbonService = RibbonBookmarkService();

    return ListenableBuilder(
      listenable: ribbonService.ribbonPageNotifier,
      builder: (context, _) {
        final isOnThisPage = ribbonService.isRibbonOnPage(pageNumber);
        if (!isOnThisPage) return const SizedBox.shrink();

        return Positioned(
          top: 0,
          right: isAr ? null : 16,
          left: isAr ? 16 : null,
          child: Md3SpringAppear(
            child: GestureDetector(
              onTap: () async {
                HapticFeedback.selectionClick();
                final removed = await ribbonService.toggleRibbon(pageNumber);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        removed
                            ? (isAr
                                ? 'تم وضع الشريط في صفحة $pageNumber'
                                : 'Шёлковая лента заложена на стр. $pageNumber')
                            : (isAr
                                ? 'تمت إزالة الشريط'
                                : 'Шёлковая лента убрана со стр. $pageNumber'),
                      ),
                    ),
                  );
                }
              },
              child: Tooltip(
                message: isAr
                    ? 'شريط علامة القراءة • انقر للإزالة'
                    : 'Шёлковая лента-закладка • Нажмите, чтобы убрать',
                child: CustomPaint(
                  size: const Size(26, 68),
                  painter: _SilkRibbonPainter(
                    ribbonColor: colorScheme.primary,
                    goldAccentColor: const Color(0xFFD4AF37), // Antique gold
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SilkRibbonPainter extends CustomPainter {
  const _SilkRibbonPainter({
    required this.ribbonColor,
    required this.goldAccentColor,
  });

  final Color ribbonColor;
  final Color goldAccentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const notchDepth = 10.0;

    // 1. Shadow for tactile realism
    final shadowPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(w / 2, h - notchDepth)
      ..lineTo(0, h)
      ..close();

    canvas.drawShadow(shadowPath, Colors.black.withOpacity(0.35), 4.0, true);

    // 2. Silk Body with subtle vertical gradient sheen
    final rect = Rect.fromLTWH(0, 0, w, h);
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        ribbonColor.withOpacity(0.92),
        ribbonColor,
        ribbonColor.withOpacity(0.85),
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    final ribbonPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(shadowPath, ribbonPaint);

    // 3. Gold Trim / Stitching down the sides
    final trimPaint = Paint()
      ..color = goldAccentColor.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final leftStitch = Path()
      ..moveTo(2.5, 0)
      ..lineTo(2.5, h - (notchDepth * 0.25));
    canvas.drawPath(leftStitch, trimPaint);

    final rightStitch = Path()
      ..moveTo(w - 2.5, 0)
      ..lineTo(w - 2.5, h - (notchDepth * 0.25));
    canvas.drawPath(rightStitch, trimPaint);

    // 4. Embroidered Gold Rosette ۞ in the center
    final textPainter = TextPainter(
      text: TextSpan(
        text: '۞',
        style: TextStyle(
          color: goldAccentColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((w - textPainter.width) / 2, (h - notchDepth) * 0.48),
    );
  }

  @override
  bool shouldRepaint(covariant _SilkRibbonPainter oldDelegate) {
    return oldDelegate.ribbonColor != ribbonColor ||
        oldDelegate.goldAccentColor != goldAccentColor;
  }
}
