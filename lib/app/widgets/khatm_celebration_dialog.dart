import 'package:flutter/material.dart';
import 'package:my_quran/app/design_tokens.dart';
import 'package:my_quran/app/l10n.dart';
import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/services/reading_stats_service.dart';

class KhatmCelebrationDialog extends StatelessWidget {
  const KhatmCelebrationDialog({
    required this.s,
    required this.isAr,
    super.key,
  });

  final S s;
  final bool isAr;

  static Future<void> show(BuildContext context, {required S s, required bool isAr}) {
    return showDialog<void>(
      context: context,
      builder: (_) => KhatmCelebrationDialog(s: s, isAr: isAr),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide >= 600;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Center(
        child: Md3SpringAppear(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 560 : 380,
              maxHeight: mq.size.height * 0.85,
            ),
            child: Dialog(
              backgroundColor: colorScheme.surface,
              shape: AppShapes.shapeLarge,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hero Badge
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          size: 40,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        s.khatmCongratulations,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        s.khatmCompletedDesc,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Du'a Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: AppShapes.borderMedium,
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  s.khatmDuaTitle,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.khatmDuaText,
                              textAlign: TextAlign.center,
                              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                                fontFamily: isAr ? FontFamily.hafs.name : null,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(s.gotIt),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(s.startNewKhatm),
                            onPressed: () {
                              ReadingStatsService.instance.resetKhatm();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
