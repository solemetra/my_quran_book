import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_quran/app/l10n.dart';
import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/services/ribbon_bookmark_service.dart';
import 'package:my_quran/app/settings_controller.dart';
import 'package:my_quran/quran/quran.dart';

class QuranNavigationBottomSheet extends StatefulWidget {
  const QuranNavigationBottomSheet({
    required this.initialPage,
    required this.onNavigate,
    required this.settingsController,
    super.key,
  });

  final int initialPage;
  final SettingsController settingsController;
  final void Function({
    required int page,
    required int surah,
    required int verse,
  })
  onNavigate;

  @override
  State<QuranNavigationBottomSheet> createState() =>
      _QuranNavigationBottomSheetState();
}

class _QuranNavigationBottomSheetState
    extends State<QuranNavigationBottomSheet> {
  late FixedExtentScrollController _surahController;
  late FixedExtentScrollController _juzController;
  late FixedExtentScrollController _verseController;

  int _currentPage = 1;
  int _currentSurah = 1;
  int _currentJuz = 1;
  int _currentVerse = 1;

  Timer? _debounce;
  int _lastHapticTime = 0;

  void _safeHaptic() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastHapticTime > 60) {
      _lastHapticTime = now;
      HapticFeedback.selectionClick();
    }
  }

  S get s => S(widget.settingsController.language);

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _initDataFromPage(_currentPage);

    _surahController = FixedExtentScrollController(
      initialItem: _currentSurah - 1,
    );
    _juzController = FixedExtentScrollController(initialItem: _currentJuz - 1);
    _verseController = FixedExtentScrollController(
      initialItem: _currentVerse - 1,
    );
  }

  void _initDataFromPage(int page) {
    final pageData = Quran.instance.getPageData(page);
    if (pageData.isNotEmpty) {
      final firstEntry = pageData.first;
      _currentSurah = firstEntry['surah']!;
      _currentVerse = firstEntry['start']!;
      _currentJuz = Quran.instance.getJuzNumber(_currentSurah, _currentVerse);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _surahController.dispose();
    _juzController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  void _onSurahChanged(int index) {
    final surah = index + 1;
    if (surah == _currentSurah) return;
    _currentSurah = surah;
    _currentPage = Quran.instance.getPageNumber(
      surah,
      _currentVerse.clamp(1, Quran.instance.getVerseCount(surah)),
    );
    _safeHaptic();
    setState(() {});

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _currentVerse = 1;
      _currentPage = Quran.instance.getPageNumber(surah, 1);
      _currentJuz = Quran.instance.getJuzNumber(surah, 1);

      if (_juzController.hasClients) {
        _juzController.animateToItem(
          _currentJuz - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
      if (_verseController.hasClients) {
        _verseController.jumpToItem(0);
      }
      setState(() {});
    });
  }

  void _onJuzChanged(int index) {
    final juz = index + 1;
    if (juz == _currentJuz) return;
    _currentJuz = juz;
    _safeHaptic();
    setState(() {});

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final surahs = Quran.instance.getSurahAndVersesFromJuz(juz);
      _currentSurah = surahs.keys.first;
      _currentVerse = surahs[_currentSurah]!.first;
      _currentPage = Quran.instance.getPageNumber(_currentSurah, _currentVerse);

      if (_surahController.hasClients) {
        _surahController.animateToItem(
          _currentSurah - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
      if (_verseController.hasClients) {
        _verseController.jumpToItem(_currentVerse - 1);
      }
      setState(() {});
    });
  }

  void _onVerseChanged(int index) {
    final verse = index + 1;
    if (verse == _currentVerse) return;
    _currentVerse = verse;
    _currentPage = Quran.instance.getPageNumber(_currentSurah, verse);
    _safeHaptic();
    setState(() {});

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _currentJuz = Quran.instance.getJuzNumber(_currentSurah, verse);

      if (_juzController.hasClients) {
        _juzController.animateToItem(
          _currentJuz - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
      setState(() {});
    });
  }

  String _surahName(int surah) => s.isAr
      ? Quran.instance.getSurahNameArabic(surah)
      : Quran.instance.getSurahName(surah);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                s.isAr
                    ? 'سُورَةُ ${_surahName(_currentSurah)} • ${s.page} ${_toArabicNumber(_currentPage)}'
                    : 'Сура ${_surahName(_currentSurah)} • Стр. $_currentPage',
                textAlign: TextAlign.center,
                textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: s.isAr ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontFamily: s.isAr ? FontFamily.hafs.name : null,
                ),
              ),
            ),
            const SizedBox(height: 8),

            ListenableBuilder(
              listenable: RibbonBookmarkService().ribbonPageNotifier,
              builder: (context, _) {
                final ribbonPage = RibbonBookmarkService().currentRibbonPage;
                if (ribbonPage == null) return const SizedBox(height: 4);

                final pageData = Quran.instance.getPageData(ribbonPage);
                final ribbonSurah =
                    pageData.isNotEmpty ? pageData.first['surah']! : 1;
                final surahTitle = s.isAr
                    ? Quran.instance.getSurahNameArabic(ribbonSurah)
                    : Quran.instance.getSurahName(ribbonSurah);
                final pageText = s.isAr
                    ? _toArabicNumber(ribbonPage)
                    : ribbonPage.toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ActionChip(
                    avatar: Icon(
                      Icons.bookmark_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      s.isAr
                          ? 'علامة القراءة: $surahTitle (صفحة $pageText)'
                          : 'Закладка: $surahTitle (стр. $pageText)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    side: BorderSide(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                    backgroundColor:
                        colorScheme.primaryContainer.withOpacity(0.35),
                    onPressed: () {
                      final first =
                          pageData.isNotEmpty ? pageData.first : null;
                      widget.onNavigate(
                        page: ribbonPage,
                        surah: first?['surah'] ?? 1,
                        verse: first?['start'] ?? 1,
                      );
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),

            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.only(top: 26, left: 12, right: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildFlatWheel(
                          controller: _surahController,
                          count: Quran.totalSurahCount,
                          label: s.surah,
                          labelAlignment: Alignment.centerLeft,
                          onChanged: _onSurahChanged,
                          itemBuilder: (i) =>
                              _buildSurahWheelItem(i + 1, _currentSurah),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildFlatWheel(
                          controller: _juzController,
                          count: Quran.totalJuzCount,
                          label: s.juz,
                          onChanged: _onJuzChanged,
                          itemBuilder: (i) =>
                              _buildNumberItem(i + 1, _currentJuz),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildFlatWheel(
                          controller: _verseController,
                          count: Quran.instance.getVerseCount(_currentSurah),
                          label: s.verse,
                          onChanged: _onVerseChanged,
                          itemBuilder: (i) =>
                              _buildNumberItem(i + 1, _currentVerse),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(s.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        widget.onNavigate(
                          page: _currentPage,
                          surah: _currentSurah,
                          verse: _currentVerse,
                        );
                        Navigator.pop(context);
                      },
                      child: Text(s.navigate),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatWheel({
    required FixedExtentScrollController controller,
    required int count,
    required String label,
    required ValueChanged<int> onChanged,
    required Widget Function(int) itemBuilder,
    Alignment labelAlignment = Alignment.center,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Align(
            alignment: labelAlignment,
            child: Padding(
              padding: EdgeInsets.only(
                left: labelAlignment == Alignment.centerLeft ? 16 : 0,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 48,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 100,
            perspective: 0.0001,
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index >= count) return null;
                return GestureDetector(
                  onTap: () {
                    controller.animateToItem(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: itemBuilder(index),
                );
              },
              childCount: count,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurahWheelItem(int number, int selected) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = number == selected;
    final surahName = s.isAr
        ? Quran.instance.getSurahNameArabic(number)
        : Quran.instance.getSurahName(number);
    final meaning = s.isAr
        ? ''
        : ' (${Quran.instance.getSurahMeaningRussian(number)})';
    final numStr = s.isAr ? _toArabicNumber(number) : '$number';

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Text(
        '$numStr. $surahName$meaning',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: isSelected ? 20 : 16,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontFamily: s.isAr ? FontFamily.hafs.name : null,
        ),
      ),
    );
  }

  Widget _buildNumberItem(int number, int selected) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = number == selected;
    return Center(
      child: Text(
        s.isAr ? _toArabicNumber(number) : number.toString(),
        style: TextStyle(
          fontSize: isSelected ? 20 : 16,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontFamily:
              s.isAr ? FontFamily.arabicNumbersFontFamily.name : null,
        ),
      ),
    );
  }

  String _toArabicNumber(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicNumerals[int.parse(digit)])
        .join();
  }
}
