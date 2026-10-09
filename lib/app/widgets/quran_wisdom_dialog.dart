import 'package:flutter/material.dart';
import 'package:my_quran/app/design_tokens.dart';

/// Smooth Typewriter effect inspired by InlitX/streak
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    required this.text,
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 2400),
    this.delay = Duration.zero,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final TextAlign textAlign;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.style ?? DefaultTextStyle.of(context).style;
    final colour = base.color ?? Theme.of(context).colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final typed = widget.text.length * _controller.value;
        final full = typed.floor().clamp(0, widget.text.length);

        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: widget.text.substring(0, full)),
              if (full < widget.text.length)
                TextSpan(
                  text: widget.text[full],
                  style: TextStyle(
                    color: colour.withOpacity((typed - full).clamp(0.0, 1.0)),
                  ),
                ),
              if (full + 1 < widget.text.length)
                TextSpan(
                  text: widget.text.substring(full + 1),
                  style: const TextStyle(color: Colors.transparent),
                ),
            ],
          ),
          style: base,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

/// Easter egg dialog displaying sacred quotes on the virtues of the Quran
class QuranWisdomEasterEggDialog extends StatelessWidget {
  const QuranWisdomEasterEggDialog({
    required this.isAr,
    super.key,
  });

  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final quote1Body = isAr
        ? '«إذا أردتم العلم فانثروا القرآن، فإن فيه علم الأولين والآخرين».\n\n«من كان يحب أن يعلم أنه يحب الله ورسوله، فلينظر: فإن كان يحب القرآن فهو يحب الله ورسوله».'
        : '«Если вы хотите обрести знания, то погрузитесь в Коран, ибо в нем содержатся знания первых и последних поколений».\n\n«Тот, кто любит Коран, пусть радуется, ибо он любит Аллаха и Его Посланника».';

    final quote1Author = isAr ? '— عبد الله بن مسعود' : '— Абдуллах ибн Мас\'уд';

    final quote2Body = isAr
        ? '«كتاب الله، فيه نبأ ما قبلكم، وخبر ما بعدكم، وحكم ما بينكم، وهو الفصل ليس بالهزل».'
        : '«Коран — это Книга Аллаха. В ней — вести о том, что было до вас, предсказания о том, что будет после вас, и судейство между вами. Она — различение, а не забава».';

    final quote2Author = isAr ? '— علي بن أبي طالب' : '— Али ибн Абу Талиб';

    final title = isAr ? 'عن فضل القرآن' : 'О достоинстве Корана';
    final closeBtnLabel = isAr ? 'إغلاق' : 'Закрыть';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Md3SpringAppear(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Decorative top icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        size: 28,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quote 1 card
                  _QuoteCard(
                    colorScheme: colorScheme,
                    body: quote1Body,
                    author: quote1Author,
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 2200),
                  ),
                  const SizedBox(height: 16),

                  // Quote 2 card
                  _QuoteCard(
                    colorScheme: colorScheme,
                    body: quote2Body,
                    author: quote2Author,
                    delay: const Duration(milliseconds: 1400),
                    duration: const Duration(milliseconds: 2000),
                  ),
                  const SizedBox(height: 24),

                  // Close button
                  Align(
                    alignment: Alignment.center,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
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
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.colorScheme,
    required this.body,
    required this.author,
    required this.delay,
    required this.duration,
  });

  final ColorScheme colorScheme;
  final String body;
  final String author;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TypewriterText(
            text: body,
            delay: delay,
            duration: duration,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TypewriterText(
              text: author,
              delay: delay + const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 900),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
