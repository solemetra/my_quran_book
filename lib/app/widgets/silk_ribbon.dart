import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_quran/app/design_tokens.dart';
import 'package:my_quran/app/services/ribbon_bookmark_service.dart';
import 'package:my_quran/app/utils.dart';
import 'package:my_quran/quran/quran.dart';

/// A physical-style silk cloth bookmark (Ляссе / شريط علامة القراءة)
/// that elegantly hangs from the top edge of a Quran page.
class SilkRibbonWidget extends StatelessWidget {
  const SilkRibbonWidget({
    required this.pageNumber,
    required this.isAr,
    this.onTapRibbon,
    super.key,
  });

  final int pageNumber;
  final bool isAr;
  final void Function(int surah, int verse)? onTapRibbon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ribbonService = RibbonBookmarkService();

    return ListenableBuilder(
      listenable: ribbonService.ribbonNotifier,
      builder: (context, _) {
        final pos = ribbonService.currentPosition;
        final isOnThisPage = pos?.pageNumber == pageNumber;
        if (!isOnThisPage || pos == null) return const SizedBox.shrink();

        final surahTitle = isAr
            ? Quran.instance.getSurahNameArabic(pos.surahNumber)
            : Quran.instance.getSurahName(pos.surahNumber);
        final verseNum = isAr
            ? getArabicNumber(pos.verseNumber)
            : pos.verseNumber.toString();

        final tooltip = isAr
            ? 'شريط القراءة: سورة $surahTitle • آية $verseNum\nانقر للتركيز على الآية، اضغط مطولاً للإزالة'
            : 'Шёлковая лента: $surahTitle • Аят $verseNum\nНажмите для перехода к аяту, удерживайте чтобы убрать';

        return Positioned(
          top: 0,
          right: isAr ? null : 16,
          left: isAr ? 16 : null,
          child: Md3SpringAppear(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (onTapRibbon != null) {
                  onTapRibbon!(pos.surahNumber, pos.verseNumber);
                }
              },
              onLongPress: () async {
                HapticFeedback.heavyImpact();
                await ribbonService.clearRibbon();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        isAr
                            ? 'تمت إزالة شريط القراءة'
                            : 'Шёлковая лента убрана со стр. $pageNumber',
                      ),
                    ),
                  );
                }
              },
              child: Tooltip(
                message: tooltip,
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

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

    canvas.save();
    canvas.translate(1.5, 2.5);
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();

    // 2. Ribbon body with inverted V-notch (swallowtail)
    final bodyPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(w / 2, h - notchDepth)
      ..lineTo(0, h)
      ..close();

    // Fabric sheen: vertical gradient simulating physical silk cloth reflection
    final silkGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(ribbonColor, Colors.white, 0.18)!,
        ribbonColor,
        Color.lerp(ribbonColor, Colors.black, 0.15)!,
      ],
      stops: const [0.0, 0.55, 1.0],
    );

    final bodyPaint = Paint()
      ..shader = silkGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    canvas.drawPath(bodyPath, bodyPaint);

    // 3. Subtle longitudinal fabric highlight across center
    final centerHighlightPath = Path()
      ..moveTo(w * 0.35, 0)
      ..lineTo(w * 0.65, 0)
      ..lineTo(w * 0.65, h - notchDepth)
      ..lineTo(w * 0.5, h - notchDepth - 2)
      ..lineTo(w * 0.35, h - notchDepth)
      ..close();

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    canvas.drawPath(centerHighlightPath, highlightPaint);

    // 4. Subtle gold rim / border stitching
    final stitchPaint = Paint()
      ..color = goldAccentColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawPath(bodyPath, stitchPaint);

    // 5. Gold ornamental Quran star symbol (۞) at bottom tip
    final textPainter = TextPainter(
      text: TextSpan(
        text: '۞',
        style: TextStyle(
          color: goldAccentColor,
          fontSize: 14,
          height: 1.0,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 1),
              blurRadius: 1.5,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (w - textPainter.width) / 2,
        h - notchDepth - textPainter.height - 4,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _SilkRibbonPainter oldDelegate) {
    return oldDelegate.ribbonColor != ribbonColor ||
        oldDelegate.goldAccentColor != goldAccentColor;
  }
}
