import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_quran/app/l10n.dart';
import 'package:my_quran/app/models.dart';
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

  bool _isUpdating = false;
  Timer? _debounce;

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

  void _triggerUpdate(VoidCallback updateFn) {
    if (_isUpdating) return;

    HapticFeedback.selectionClick();
    setState(() {});

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _isUpdating = true);

      updateFn();

      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _isUpdating = false);
      });
    });
  }

  void _onSurahChanged(int index) {
    final surah = index + 1;
    _currentSurah = surah;
    _triggerUpdate(() {
      _currentVerse = 1;
      _currentPage = Quran.instance.getPageNumber(surah, 1);
      _currentJuz = Quran.instance.getJuzNumber(surah, 1);
      _animateAll();
    });
  }

  void _onJuzChanged(int index) {
    final juz = index + 1;
    _currentJuz = juz;
    _triggerUpdate(() {
      final surahs = Quran.instance.getSurahAndVersesFromJuz(juz);
      _currentSurah = surahs.keys.first;
      _currentVerse = surahs[_currentSurah]!.first;
      _currentPage = Quran.instance.getPageNumber(_currentSurah, _currentVerse);
      _animateAll();
    });
  }

  void _onVerseChanged(int index) {
    final verse = index + 1;
    _currentVerse = verse;
    _triggerUpdate(() {
      _currentPage = Quran.instance.getPageNumber(_currentSurah, verse);
      _currentJuz = Quran.instance.getJuzNumber(_currentSurah, verse);
      _animateAll(skipVerse: true);
    });
  }

  void _animateAll({bool skipVerse = false}) {
    _surahController.jumpToItem(_currentSurah - 1);
    _juzController.jumpToItem(_currentJuz - 1);
    if (!skipVerse) {
      final max = Quran.instance.getVerseCount(_currentSurah);
      _verseController.jumpToItem((_currentVerse - 1).clamp(0, max - 1));
    }
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
                _surahName(_currentSurah),
                textAlign: TextAlign.center,
                textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: s.isAr ? 22 : 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontFamily: s.isAr ? FontFamily.hafs.name : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 44,
                      margin: const EdgeInsets.only(top: 26),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFlatWheel(
                          controller: _surahController,
                          count: Quran.totalSurahCount,
                          label: s.surah,
                          onChanged: _onSurahChanged,
                          itemBuilder: (i) =>
                              _buildNumberItem(i + 1, _currentSurah),
                        ),
                      ),
                      Expanded(
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
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 44,
            physics: const FixedExtentScrollPhysics(),
            changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
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

  Widget _buildNumberItem(int number, int selected) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = number == selected;
    return Text(
      s.isAr ? _toArabicNumber(number) : number.toString(),
      style: TextStyle(
        fontSize: 21,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontFamily:
            s.isAr ? FontFamily.arabicNumbersFontFamily.name : null,
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
