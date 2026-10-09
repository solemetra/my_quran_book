import 'package:flutter/foundation.dart';

import 'package:my_quran/app/models.dart';
import 'package:my_quran/quran/quran.dart';

@immutable
class VerseSegment {
  const VerseSegment({
    required this.verse,
    required this.text,
    required this.symbolText,
    required this.start, // inclusive in the final paragraph text
    required this.end, // exclusive
  });

  final int verse;
  final String text;
  final String symbolText;
  final int start;
  final int end;
}

@immutable
class SurahBlockText {
  const SurahBlockText({required this.surahNumber, required this.segments});

  final int surahNumber;
  final List<VerseSegment> segments; // in visual order
}

@immutable
class QuranPageTextModel {
  const QuranPageTextModel({
    required this.pageNumber,
    required this.surahs,
    required this.blocks,
  });

  final int pageNumber;
  final List<SurahInPage> surahs;
  final List<SurahBlockText> blocks; // same length/order as surahs
}

class QuranPageTextCache {
  QuranPageTextCache._();
  static final instance = QuranPageTextCache._();

  // Bump this when Quran.data changes (i.e., switching JSON dataset).
  int _revision = 0;

  // Cache all 604 pages in memory for 120 FPS buttery-smooth scrolling
  final _cache = <({int rev, int page}), QuranPageTextModel>{};
  static const int maxEntries = 604;

  void invalidateForNewQuranData() {
    _revision++;
    _cache.clear();
  }

  void preloadAll() {
    for (int p = 1; p <= Quran.totalPagesCount; p++) {
      get(p);
    }
  }

  void prewarmAround(int pageNumber, {int window = 4}) {
    for (int p = pageNumber - window; p <= pageNumber + window; p++) {
      if (p >= 1 && p <= Quran.totalPagesCount) {
        get(p);
      }
    }
  }

  QuranPageTextModel get(int pageNumber) {
    final key = (rev: _revision, page: pageNumber);

    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    final built = _build(pageNumber);
    _cache[key] = built;
    return built;
  }

  QuranPageTextModel _build(int pageNumber) {
    final rawData = Quran.instance.getPageData(pageNumber);
    final surahs = <SurahInPage>[];

    for (final item in rawData) {
      final surahNum = item['surah']!;
      final start = item['start']!;
      final end = item['end']!;

      final verses = <Verse>[];
      for (int v = start; v <= end; v++) {
        verses.add((number: v, text: Quran.instance.getVerse(surahNum, v)));
      }
      surahs.add(SurahInPage(surahNumber: surahNum, verses: verses));
    }

    final blocks = <SurahBlockText>[];
    for (final surah in surahs) {
      blocks.add(_buildSurahBlockText(surah));
    }

    return QuranPageTextModel(
      pageNumber: pageNumber,
      surahs: surahs,
      blocks: blocks,
    );
  }

  SurahBlockText _buildSurahBlockText(SurahInPage surah) {
    final segments = <VerseSegment>[];
    var charCount = 0;

    for (final verse in surah.verses) {
      // Al-Fatiha verse 1 is the Basmala, rendered separately in the UI.
      if (surah.surahNumber == 1 && verse.number == 1) continue;

      final start = charCount;

      final text = verse.text;
      charCount += text.length;

      // Put spaces here so they are part of the symbol span.
      final symbol = Quran.instance.getVerseEndSymbol(verse.number);
      final symbolText = ' $symbol '; // tweak spacing as you like
      charCount += symbolText.length;

      segments.add(
        VerseSegment(
          verse: verse.number,
          text: text,
          symbolText: symbolText,
          start: start,
          end: charCount,
        ),
      );
    }

    return SurahBlockText(surahNumber: surah.surahNumber, segments: segments);
  }
}
