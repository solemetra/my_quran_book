import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/settings_controller.dart';
import 'package:my_quran/app/utils.dart';
import 'package:my_quran/quran/quran.dart';
import 'package:my_quran/app/l10n.dart';

class PinnedHeader extends StatelessWidget {
  const PinnedHeader({
    required this.settingsController,
    required this.currentPositionNotifier,
    required this.goToPage,
    required this.decoration,
    super.key,
  });

  final ValueNotifier<ReadingPosition> currentPositionNotifier;
  final void Function(int page, {int? highlightSurah, int? highlightVerse})
  goToPage;
  final BoxDecoration decoration;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: s.isAr ? FontFamily.arabicNumbersFontFamily.name : null,
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      child: Container(
        decoration: decoration,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ValueListenableBuilder<ReadingPosition>(
          valueListenable: currentPositionNotifier,
          builder: (context, position, _) {
            final surahName = s.isAr
                ? Quran.instance.getSurahNameArabic(position.surahNumber)
                : Quran.instance.getSurahName(position.surahNumber);
            final surahNum = s.isAr ? getArabicNumber(position.surahNumber) : position.surahNumber.toString();
            final pageNum = s.isAr ? getArabicNumber(position.pageNumber) : position.pageNumber.toString();

            return Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => onSurahTapped(context),
                      child: Text(
                        '$surahNum - '
                        '$surahName',
                      ),
                    ),
                    // Juz + Hizb
                    ListenableBuilder(
                      listenable: settingsController,
                      builder: (context, child) {
                        final hizbDisplay = settingsController.hizbDisplay;
                        final parts = <String>[];

                        final juzNum = s.isAr ? getArabicNumber(position.juzNumber) : position.juzNumber.toString();
                        final hizbNum = s.isAr ? getArabicNumber(position.hizbNumber) : position.hizbNumber.toString();
                        final quarterNum = s.isAr ? getArabicNumber(position.hizbQuarter) : position.hizbQuarter.toString();

                        if (!hizbDisplay.isReplaceJuz) {
                          parts.add(
                            '${s.juz} $juzNum',
                          );
                        }

                        if (!hizbDisplay.isHidden) {
                          parts.add(
                            '${s.hizbLabel} $hizbNum',
                          );
                          if (hizbDisplay.withQuarter) {
                            parts.add(
                              ' ($quarterNum/${s.isAr ? '٤' : '4'})',
                            );
                          }
                        }

                        return GestureDetector(
                          onTap: () => hizbDisplay.isReplaceJuz
                              ? onHizbTapped(context)
                              : onJuzTapped(context),
                          child: Text(parts.join(' - ')),
                        );
                      },
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => onPageNumberTapped(context),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        pageNum,
                        key: ValueKey(position.pageNumber),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void onHizbTapped(BuildContext context) {
    final s = S.of(context);
    int? hizb;
    int selectedQuarter = 1;

    void validateAndGo(int? hizb, int quarter) {
      if (hizb is! int || hizb < 1 || hizb > 60) return;

      final (surah, verse) = Quran.instance.getHizbQuarterStart(
        hizb,
        quarter: quarter,
      );
      Navigator.pop(context);
      goToPage(
        Quran.instance.getPageNumber(surah, verse),
        highlightSurah: surah,
        highlightVerse: verse,
      );
    }

    showAdaptiveDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final colorScheme = Theme.of(context).colorScheme;

          return SimpleDialog(
            title: Text(s.enterHizbNumber),
            contentPadding: const EdgeInsets.all(24),
            children: [
              TextField(
                maxLength: 2,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      required maxLength,
                    }) => const SizedBox.shrink(),
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18),
                onChanged: (value) => hizb = int.tryParse(value),
                onSubmitted: (_) => validateAndGo(hizb, selectedQuarter),
              ),
              const SizedBox(height: 16),

              // Quarter selector
              Text(
                s.quarterLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: 1, label: Text(s.quarter1)),
                  ButtonSegment(value: 2, label: Text(s.quarter2)),
                  ButtonSegment(value: 3, label: Text(s.quarter3)),
                ],
                style: ButtonStyle(
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  foregroundColor: WidgetStateColor.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                  backgroundColor: WidgetStateColor.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? colorScheme.primary
                        : Colors.transparent,
                  ),
                  side: WidgetStatePropertyAll(
                    BorderSide(
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                ),
                selected: {selectedQuarter},
                onSelectionChanged: (v) {
                  setState(() => selectedQuarter = v.first);
                },
              ),

              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => validateAndGo(hizb, selectedQuarter),
                child: Text(s.navigate),
              ),
            ],
          );
        },
      ),
    );
  }

  void onJuzTapped(BuildContext context) {
    final s = S.of(context);
    int? juz;
    void validateAndGo(int? juz) {
      if (juz is! int || juz < 1 || juz > 30) {
        return;
      }
      final firstSurahOfJuz = Quran.instance
          .getSurahAndVersesFromJuz(juz)
          .entries
          .first;
      final surahNumber = firstSurahOfJuz.key;
      final verseNumber = firstSurahOfJuz.value.first;
      Navigator.pop(context);
      goToPage(
        Quran.instance.getPageNumber(surahNumber, verseNumber),
        highlightSurah: surahNumber,
        highlightVerse: verseNumber,
      );
    }

    showAdaptiveDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(s.enterJuzNumber),
        contentPadding: const EdgeInsets.all(24),
        children: [
          TextField(
            maxLength: 2,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) => const SizedBox.shrink(),
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18),
            onChanged: (value) => juz = int.tryParse(value),
            onSubmitted: (value) {
              validateAndGo(int.tryParse(value));
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => validateAndGo(juz),
            child: Text(s.navigate),
          ),
        ],
      ),
    );
  }

  void onPageNumberTapped(BuildContext context) {
    final s = S.of(context);
    int? page;
    void validateAndGo() {
      if (page == null) return;
      if (page is! int || page! < 1 || page! > Quran.totalPagesCount) {
        return;
      }

      Navigator.pop(context);
      goToPage(page!);
    }

    showAdaptiveDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(s.enterPageNumber),
        contentPadding: const EdgeInsets.all(24),
        children: [
          TextFormField(
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return s.enterPageNumberPrompt;
              }

              final page = int.tryParse(value!);
              if (page is! int || page < 1 || page > Quran.totalPagesCount) {
                return s.invalidPageNumber;
              }
              return null;
            },
            onChanged: (value) => page = int.tryParse(value),
            onFieldSubmitted: (value) => validateAndGo(),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: validateAndGo, child: Text(s.navigate)),
        ],
      ),
    );
  }

  void onSurahTapped(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => _SearchSurahDialog(
        onSurahTapped: (surahNumber) {
          Navigator.pop(context);
          final pageNumber = Quran.instance.getPageNumber(surahNumber, 1);
          goToPage(pageNumber, highlightSurah: surahNumber, highlightVerse: 1);
        },
      ),
    );
  }
}

class _SearchSurahDialog extends StatefulWidget {
  const _SearchSurahDialog({required this.onSurahTapped});
  final void Function(int surahNumber) onSurahTapped;
  @override
  State<_SearchSurahDialog> createState() => _SearchSurahDialogState();
}

class _SearchSurahDialogState extends State<_SearchSurahDialog> {
  late final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final s = S.of(context);
    return SimpleDialog(
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        TextField(controller: searchController, autofocus: true),
        SizedBox(
          width: screen.width * .8,
          height: screen.height * .5,
          child: ValueListenableBuilder(
            valueListenable: searchController,
            builder: (context, value, _) {
              final items = value.text.isEmpty
                  ? Quran.surahNames
                  : Quran.surahNames
                        .where(
                          (e) =>
                              e.arabic.contains(value.text) ||
                              e.english.toLowerCase().contains(
                                value.text.toLowerCase(),
                              ),
                        )
                        .toList();
              if (items.isEmpty) {
                return Center(child: Text(s.noResults));
              }
              return ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.only(top: 10, bottom: 32),
                itemBuilder: (context, index) => ListTile(
                  onTap: () => widget.onSurahTapped(items[index].number),
                  leading: Text(
                    getArabicNumber(items[index].number),
                    style: TextStyle(
                      fontFamily: FontFamily.arabicNumbersFontFamily.name,
                      fontSize: 16,
                    ),
                  ),
                  title: Text(
                    '${items[index].arabic} - ${items[index].english}',
                    style: TextStyle(
                      fontFamily: FontFamily.rustam.name,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
