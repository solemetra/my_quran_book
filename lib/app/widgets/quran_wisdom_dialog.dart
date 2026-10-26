import 'dart:async';
import 'package:my_quran/app/utils.dart';
import 'package:flutter/material.dart';
import 'package:my_quran/app/design_tokens.dart';

/// Deterministic, letter-by-letter smooth typewriter renderer
class SmoothTypewriter extends StatelessWidget {
  const SmoothTypewriter({
    required this.text,
    required this.progress,
    required this.style,
    this.color,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final String text;
  final double progress;
  final TextStyle style;
  final Color? color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? style.color ?? Theme.of(context).colorScheme.onSurface;
    final typed = text.length * progress;
    final full = typed.floor().clamp(0, text.length);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, full)),
          if (full < text.length)
            TextSpan(
              text: text[full],
              style: TextStyle(
                color: effectiveColor.applyOpacity(
                  (typed - full).clamp(0.0, 1.0),
                ),
              ),
            ),
          if (full + 1 < text.length)
            TextSpan(
              text: text.substring(full + 1),
              style: const TextStyle(color: Colors.transparent),
            ),
        ],
      ),
      style: style,
      textAlign: textAlign,
    );
  }
}

/// The most beautiful easter egg card in the app:
/// Sequential, staged Typewriter animation with rich MD3 Expressive styling.
class QuranWisdomEasterEggDialog extends StatefulWidget {
  const QuranWisdomEasterEggDialog({
    required this.isAr,
    super.key,
  });

  final bool isAr;

  @override
  State<QuranWisdomEasterEggDialog> createState() =>
      _QuranWisdomEasterEggDialogState();
}

class _QuranWisdomEasterEggDialogState
    extends State<QuranWisdomEasterEggDialog>
    with TickerProviderStateMixin {
  // Animation controllers for sequential staged delivery
  late final AnimationController _ctrlQuote1;
  late final AnimationController _ctrlAuthor1;
  late final AnimationController _ctrlDivider;
  late final AnimationController _ctrlQuote2;
  late final AnimationController _ctrlAuthor2;

  bool _isFinished = false;
  Timer? _sequenceTimer1;
  Timer? _sequenceTimer2;
  Timer? _sequenceTimer3;
  Timer? _sequenceTimer4;

  @override
  void initState() {
    super.initState();

    _ctrlQuote1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    );

    _ctrlAuthor1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _ctrlDivider = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _ctrlQuote2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _ctrlAuthor2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _startSequence();
  }

  void _startSequence() {
    // Stage 1: Card opens -> small pause -> Quote 1 types out
    _sequenceTimer1 = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _ctrlQuote1.forward().then((_) {
        if (!mounted || _isFinished) return;
        // Stage 2: Author 1 fades in
        _ctrlAuthor1.forward().then((_) {
          if (!mounted || _isFinished) return;
          // Stage 3: Divider emerges
          _sequenceTimer2 = Timer(const Duration(milliseconds: 250), () {
            if (!mounted || _isFinished) return;
            _ctrlDivider.forward().then((_) {
              if (!mounted || _isFinished) return;
              // Stage 4: Quote 2 starts typing
              _sequenceTimer3 = Timer(const Duration(milliseconds: 200), () {
                if (!mounted || _isFinished) return;
                _ctrlQuote2.forward().then((_) {
                  if (!mounted || _isFinished) return;
                  // Stage 5: Author 2 fades in
                  _ctrlAuthor2.forward().then((_) {
                    if (!mounted) return;
                    setState(() {
                      _isFinished = true;
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  }

  void _fastForward() {
    if (_isFinished) return;
    _sequenceTimer1?.cancel();
    _sequenceTimer2?.cancel();
    _sequenceTimer3?.cancel();
    _sequenceTimer4?.cancel();

    _ctrlQuote1.value = 1.0;
    _ctrlAuthor1.value = 1.0;
    _ctrlDivider.value = 1.0;
    _ctrlQuote2.value = 1.0;
    _ctrlAuthor2.value = 1.0;

    setState(() {
      _isFinished = true;
    });
  }

  @override
  void dispose() {
    _sequenceTimer1?.cancel();
    _sequenceTimer2?.cancel();
    _sequenceTimer3?.cancel();
    _sequenceTimer4?.cancel();

    _ctrlQuote1.dispose();
    _ctrlAuthor1.dispose();
    _ctrlDivider.dispose();
    _ctrlQuote2.dispose();
    _ctrlAuthor2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isAr = widget.isAr;
    final isEn = !isAr && Localizations.localeOf(context).languageCode == 'en';

    final quote1Body = isAr
        ? '«إذا أردتم العلم فانثروا القرآن، فإن فيه علم الأولين والآخرين».\n\n«من كان يحب أن يعلم أنه يحب الله ورسوله، فلينظر: فإن كان يحب القرآن فهو يحب الله ورسوله».'
        : isEn
            ? '“If you wish for knowledge, immerse yourselves in the Quran, for verily it contains the knowledge of the earlier and later generations.”\n\n“Whoever loves the Quran loves Allah and His Messenger.”'
            : '«Если вы хотите обрести знания, то погрузитесь в Коран, ибо в нем содержатся знания первых и последних поколений».\n\n«Тот, кто любит Коран, пусть радуется, ибо он любит Аллаха и Его Посланника».';

    final quote1Author = isAr
        ? '— عبد الله بن مسعود رضي الله عنه'
        : isEn
            ? '— Abdullah ibn Mas\'ud'
            : '— Абдуллах ибн Мас\'уд';

    final quote2Body = isAr
        ? '«كتاب الله، فيه نبأ ما قبلكم، وخبر ما بعدكم، وحكم ما بينكم، وهو الفصل ليس بالهزل».'
        : isEn
            ? '“The Book of Allah contains news of what came before you, tidings of what will come after you, and judgment for what is between you. It is the decisive word, not amusement.”'
            : '«Коран — это Книга Аллаха. В ней — вести о том, что было до вас, предсказания о том, что будет после вас, и судейство между вами. Она — различение, а не забава».';

    final quote2Author = isAr
        ? '— علي بن أبي طالب رضي الله عنه'
        : isEn
            ? '— Ali ibn Abi Talib'
            : '— Али ибн Абу Талиб';

    final title = isAr
        ? 'عن فضل القرآن'
        : isEn
            ? 'Virtues of the Holy Quran'
            : 'О достоинстве Корана';
    final subtitle = isAr
        ? 'من أقوال الصحابة الكرام'
        : isEn
            ? 'Pearls of Wisdom from the Companions'
            : 'Жемчужины мудрости сподвижников';
    final closeBtnLabel = isAr
        ? 'إغلاق'
        : isEn
            ? 'Close'
            : 'Закрыть';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Md3SpringAppear(
          child: GestureDetector(
            onTap: _fastForward,
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 620),
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 22),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: colorScheme.primary.applyOpacity(0.32),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.applyOpacity(0.24),
                    blurRadius: 36,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: colorScheme.primary.applyOpacity(0.12),
                    blurRadius: 28,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top glowing medallion
                    Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.applyOpacity(0.38),
                              blurRadius: 22,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_stories_rounded,
                          size: 28,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Subtitle
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Master Quote Card (Unified luxury container)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colorScheme.outlineVariant.applyOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Quote 1 ──
                          AnimatedBuilder(
                            animation: _ctrlQuote1,
                            builder: (context, _) {
                              return SmoothTypewriter(
                                text: quote1Body,
                                progress: _ctrlQuote1.value,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  height: 1.62,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          // Author 1 (fades in)
                          FadeTransition(
                            opacity: _ctrlAuthor1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                quote1Author,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          // ── Ornamental Divider ──
                          AnimatedBuilder(
                            animation: _ctrlDivider,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _ctrlDivider.value,
                                child: Transform.scale(
                                  scale: 0.95 + (_ctrlDivider.value * 0.05),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outlineVariant
                                          .applyOpacity(0.5),
                                      thickness: 0.8,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      '✦   ✦   ✦',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary
                                            .applyOpacity(0.7),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outlineVariant
                                          .applyOpacity(0.5),
                                      thickness: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Quote 2 ──
                          AnimatedBuilder(
                            animation: _ctrlQuote2,
                            builder: (context, _) {
                              return SmoothTypewriter(
                                text: quote2Body,
                                progress: _ctrlQuote2.value,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  height: 1.62,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          // Author 2 (fades in)
                          FadeTransition(
                            opacity: _ctrlAuthor2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                quote2Author,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Bottom close button
                    Center(
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          closeBtnLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
