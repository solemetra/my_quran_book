import 'package:flutter/foundation.dart';
import 'package:my_quran/quran/quran.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Position tracked by the Silk Ribbon (Ляссе / شريط علامة القراءة).
@immutable
class RibbonPosition {
  const RibbonPosition({
    required this.pageNumber,
    required this.surahNumber,
    required this.verseNumber,
  });

  final int pageNumber;
  final int surahNumber;
  final int verseNumber;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RibbonPosition &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber;

  @override
  int get hashCode => Object.hash(pageNumber, surahNumber, verseNumber);

  @override
  String toString() =>
      'RibbonPosition(page: $pageNumber, surah: $surahNumber, verse: $verseNumber)';
}

/// Service managing the single physical-style "Silk Ribbon" bookmark (Ляссе).
///
/// Marks the exact reading spot (page, surah, and verse) where the reader stopped,
/// providing physical-style aesthetics with precision reading resumption.
class RibbonBookmarkService {
  factory RibbonBookmarkService() => _instance;
  RibbonBookmarkService._internal();
  static final RibbonBookmarkService _instance =
      RibbonBookmarkService._internal();

  static const String _prefKeyPage = 'silk_ribbon_page_number';
  static const String _prefKeySurah = 'silk_ribbon_surah_number';
  static const String _prefKeyVerse = 'silk_ribbon_verse_number';

  final ValueNotifier<RibbonPosition?> ribbonNotifier =
      ValueNotifier<RibbonPosition?>(null);
  final ValueNotifier<int?> ribbonPageNotifier = ValueNotifier<int?>(null);
  bool _initialized = false;

  RibbonPosition? get currentPosition => ribbonNotifier.value;
  int? get currentRibbonPage => ribbonPageNotifier.value;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_prefKeyPage);
    if (page != null) {
      int? surah = prefs.getInt(_prefKeySurah);
      int? verse = prefs.getInt(_prefKeyVerse);

      // Fallback for previous versions that only stored pageNumber
      if (surah == null || verse == null) {
        final pageData = Quran.instance.getPageData(page);
        if (pageData.isNotEmpty) {
          surah = pageData.first['surah'];
          verse = pageData.first['start'];
        }
      }

      if (surah != null && verse != null) {
        final pos = RibbonPosition(
          pageNumber: page,
          surahNumber: surah,
          verseNumber: verse,
        );
        ribbonNotifier.value = pos;
        ribbonPageNotifier.value = page;
      }
    }
    _initialized = true;
  }

  /// Sets or updates the ribbon bookmark to an exact verse.
  Future<void> setRibbon({
    required int pageNumber,
    required int surahNumber,
    required int verseNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyPage, pageNumber);
    await prefs.setInt(_prefKeySurah, surahNumber);
    await prefs.setInt(_prefKeyVerse, verseNumber);

    final pos = RibbonPosition(
      pageNumber: pageNumber,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
    );
    ribbonNotifier.value = pos;
    ribbonPageNotifier.value = pageNumber;
  }

  /// Sets ribbon bookmark using page number (defaults to first verse of page).
  Future<void> setRibbonPage(int pageNumber) async {
    final pageData = Quran.instance.getPageData(pageNumber);
    final surah = pageData.isNotEmpty ? pageData.first['surah']! : 1;
    final verse = pageData.isNotEmpty ? pageData.first['start']! : 1;
    await setRibbon(
      pageNumber: pageNumber,
      surahNumber: surah,
      verseNumber: verse,
    );
  }

  /// Removes the ribbon bookmark.
  Future<void> clearRibbon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyPage);
    await prefs.remove(_prefKeySurah);
    await prefs.remove(_prefKeyVerse);
    ribbonNotifier.value = null;
    ribbonPageNotifier.value = null;
  }

  /// Toggles the ribbon bookmark on [pageNumber].
  Future<bool> toggleRibbon(int pageNumber) async {
    if (ribbonPageNotifier.value == pageNumber) {
      await clearRibbon();
      return false; // removed
    } else {
      await setRibbonPage(pageNumber);
      return true; // placed
    }
  }

  /// Toggles the ribbon bookmark on a specific verse.
  Future<bool> toggleRibbonVerse({
    required int pageNumber,
    required int surahNumber,
    required int verseNumber,
  }) async {
    final current = ribbonNotifier.value;
    if (current != null &&
        current.surahNumber == surahNumber &&
        current.verseNumber == verseNumber) {
      await clearRibbon();
      return false; // removed
    } else {
      await setRibbon(
        pageNumber: pageNumber,
        surahNumber: surahNumber,
        verseNumber: verseNumber,
      );
      return true; // placed
    }
  }

  bool isRibbonOnVerse(int surah, int verse) {
    final current = ribbonNotifier.value;
    return current != null &&
        current.surahNumber == surah &&
        current.verseNumber == verse;
  }

  bool isRibbonOnPage(int pageNumber) => ribbonPageNotifier.value == pageNumber;
}
