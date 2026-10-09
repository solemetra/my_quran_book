import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:my_quran/app/l10n.dart';
import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/search/processor.dart';
import 'package:my_quran/app/services/search_service.dart';
import 'package:my_quran/app/design_tokens.dart';
import 'package:my_quran/app/utils.dart';
import 'package:my_quran/quran/data/surah_data.dart';
import 'package:my_quran/quran/quran.dart';

class QuranSearchBottomSheet extends StatefulWidget {
  const QuranSearchBottomSheet({
    required this.verseFontFamily,
    required this.onNavigateToPage,
    required this.language,
    super.key,
  });

  final void Function(int page, {int? surah, int? verse}) onNavigateToPage;
  final FontFamily verseFontFamily;
  final String language;

  @override
  State<QuranSearchBottomSheet> createState() => _QuranSearchBottomSheetState();
}

class _QuranSearchBottomSheetState extends State<QuranSearchBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  bool _isSearching = false;
  List<int> _matchedSurahs = [];

  SearchMatchMode _matchMode = SearchMatchMode.auto;
  SearchOperator _operator = SearchOperator.and;

  SearchResponse _response = const SearchResponse(
    hits: [],
    effectiveMode: SearchMatchMode.auto,
    normalizedQueryTokens: {},
    operatorUsed: SearchOperator.and,
    isTruncated: false,
    totalHits: 0,
  );

  S get s => S(widget.language);

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _performSearch(query);
    });
  }

  int _searchSeq = 0;

  List<int> _findMatchingSurahs(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const [];

    String stripPrefixes(String s) {
      var res = s.toLowerCase().trim();
      if (res.startsWith('сура ')) res = res.substring(5).trim();
      if (res.startsWith('сура')) res = res.substring(4).trim();
      if (res.startsWith('surah ')) res = res.substring(6).trim();
      if (res.startsWith('surah')) res = res.substring(5).trim();
      res = res
          .replaceAll('я', 'йа')
          .replaceAll('ю', 'йу')
          .replaceAll(RegExp(r"['`’\-\s]"), '');
      return res;
    }

    final cleanSimplified = stripPrefixes(clean);
    final asNum = int.tryParse(cleanSimplified);
    if (asNum != null && asNum >= 1 && asNum <= 114) {
      return [asNum];
    }

    final normArabic = ArabicTextProcessor.normalize(clean);
    final List<int> matched = [];

    for (int i = 0; i < 114; i++) {
      final surahNum = i + 1;
      final ruName = surahNamesRussian[i];
      final enName = surah[i]['name'] as String;
      final arName = surah[i]['arabic'] as String;

      final ruClean = stripPrefixes(ruName);
      final ruMeaning = surahMeaningsRussian[i];
      final ruMeaningClean = stripPrefixes(ruMeaning);
      final enClean = stripPrefixes(enName);
      final arNorm = ArabicTextProcessor.normalize(arName);

      bool match = false;
      if (ruClean.contains(cleanSimplified) ||
          ruMeaningClean.contains(cleanSimplified)) {
        match = true;
      } else if (enClean.contains(cleanSimplified)) {
        match = true;
      } else if (normArabic.isNotEmpty && arNorm.contains(normArabic)) {
        match = true;
      }

      if (match) {
        matched.add(surahNum);
      }
    }

    matched.sort((a, b) {
      final aRu = stripPrefixes(surahNamesRussian[a - 1]);
      final bRu = stripPrefixes(surahNamesRussian[b - 1]);
      final aExact = aRu == cleanSimplified;
      final bExact = bRu == cleanSimplified;
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;

      final aStarts = aRu.startsWith(cleanSimplified);
      final bStarts = bRu.startsWith(cleanSimplified);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      return a.compareTo(b);
    });

    return matched;
  }

  Future<void> _performSearch(String query) async {
    final mySeq = ++_searchSeq;

    if (query.trim().isEmpty) {
      setState(() {
        _matchedSurahs = [];
        _response = const SearchResponse(
          hits: [],
          effectiveMode: SearchMatchMode.auto,
          normalizedQueryTokens: {},
          operatorUsed: SearchOperator.and,
          isTruncated: false,
          totalHits: 0,
        );
        _isSearching = false;
      });
      return;
    }

    final matched = _findMatchingSurahs(query);
    setState(() {
      _matchedSurahs = matched;
      _isSearching = true;
    });

    final resp = await SearchService.search(
      query,
      mode: _matchMode,
      operator: _operator,
    );

    if (!mounted || mySeq != _searchSeq) return; // stale result

    setState(() {
      _response = resp;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hits = _response.hits;
    final isAr = widget.language == 'ar';
    final hasNoResults = _matchedSurahs.isEmpty &&
        hits.isEmpty &&
        _controller.text.trim().isNotEmpty &&
        !_isSearching;
    final hasSectionHeader = _matchedSurahs.isNotEmpty && hits.isNotEmpty;
    final totalCount = _matchedSurahs.length +
        (hasSectionHeader ? 1 : 0) +
        hits.length;

    return AdaptiveContent(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // --- Search Bar (M3 Expressive 28dp stadium style) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(letterSpacing: 0),
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(
                    borderRadius: AppShapes.borderExtraLarge,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppShapes.borderExtraLarge,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppShapes.borderExtraLarge,
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            _buildFiltersBar(context),

          // --- Results List ---
          Expanded(
            child: hasNoResults
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.noResults,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      ListView.separated(
                        itemCount: totalCount,
                        separatorBuilder: (c, i) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, index) {
                          if (index < _matchedSurahs.length) {
                            return _buildSurahCard(
                              context,
                              _matchedSurahs[index],
                            );
                          }
                          if (hasSectionHeader &&
                              index == _matchedSurahs.length) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                              child: Text(
                                'Найденные аяты (${_response.totalHits}):',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            );
                          }
                          final hitIndex = index -
                              _matchedSurahs.length -
                              (hasSectionHeader ? 1 : 0);
                          final hit = hits[hitIndex];
                          return SearchResultItem(
                            language: widget.language,
                            verseFontFamily: widget.verseFontFamily,
                            hit: hit,
                            effectiveMode: _response.effectiveMode,
                            onTap: () {
                              Navigator.pop(context);

                              final page = Quran.instance.getPageNumber(
                                hit.surah,
                                hit.verse,
                              );

                              widget.onNavigateToPage(
                                page,
                                surah: hit.surah,
                                verse: hit.verse,
                              );
                            },
                          );
                        },
                      ),
                      if (_isSearching)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            color: colorScheme.primary,
                            backgroundColor: Colors.transparent,
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

  Widget _buildSurahCard(BuildContext context, int surahNum) {
    final colorScheme = Theme.of(context).colorScheme;
    final ruName = surahNamesRussian[surahNum - 1];
    final ruMeaning = surahMeaningsRussian[surahNum - 1];
    final arName = surah[surahNum - 1]['arabic'] as String;
    final totalAyah = surah[surahNum - 1]['aya'] as int;
    final page = Quran.instance.getPageNumber(surahNum, 1);
    final isMakkah = surah[surahNum - 1]['place'] == 'Makkah';
    final placeRu = isMakkah ? 'Мекканская' : 'Мединская';

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onNavigateToPage(page, surah: surahNum, verse: 1);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.applyOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$surahNum',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Сура $ruName ($ruMeaning)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'سُورَةُ $arName',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: widget.verseFontFamily.name,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$placeRu • $totalAyah аятов • Стр. $page',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tokensCount = ArabicTextProcessor.tokenize(
      _controller.text,
    ).map(ArabicTextProcessor.normalize).where((t) => t.isNotEmpty).length;

    if (tokensCount == 0) {
      return const SizedBox.shrink();
    }

    final showOperator = tokensCount >= 2;

    final shown = _response.hits.length;
    final total = _response.totalHits;

    // When Auto is active, highlight the effective mode in
    // the segmented control.
    SearchMatchMode selectedModeForUi() {
      if (!_matchMode.isAuto) return _matchMode;
      return _response.effectiveMode == SearchMatchMode.auto
          ? SearchMatchMode.prefix
          : _response.effectiveMode;
    }

    String operatorLabel(SearchOperator op) => switch (op) {
      SearchOperator.and => s.matchAllWords,
      SearchOperator.or => s.matchAnyWord,
    };

    Widget countWidget() {
      if (total == 0) return const SizedBox.shrink();
      final countText = _response.isTruncated 
          ? s.showingNofM(shown, total)
          : s.resultsCountN(total);
          
      return Text(
        countText,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    void selectUserMode(SearchMatchMode m) {
      setState(() => _matchMode = m);
      _performSearch(_controller.text);
    }

    Widget modeSegmented() {
      return SegmentedButton<SearchMatchMode>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.comfortable),
        segments: [
          ButtonSegment(value: SearchMatchMode.exact, label: Text(s.matchExact)),
          ButtonSegment(value: SearchMatchMode.prefix, label: Text(s.matchPrefix)),
          ButtonSegment(value: SearchMatchMode.contains, label: Text(s.matchContains)),
          ButtonSegment(value: SearchMatchMode.flexible, label: Text(s.matchFlexible)),
        ],
        selected: {selectedModeForUi()},
        onSelectionChanged: (v) => selectUserMode(v.first),
      );
    }

    Widget operatorControl() {
      final s = S(widget.language);
      final labelPrefix = s.matchLabel;
      return PopupMenuButton<SearchOperator>(
        initialValue: _operator,
        onSelected: (op) {
          setState(() => _operator = op);
          _performSearch(_controller.text);
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: SearchOperator.and,
            child: Text('$labelPrefix: ${s.matchAllWords}'),
          ),
          PopupMenuItem(
            value: SearchOperator.or,
            child: Text('$labelPrefix: ${s.matchAnyWord}'),
          ),
        ],
        child: Chip(
          avatar: const Icon(Icons.filter_alt_outlined, size: 18),
          label: Text('$labelPrefix: ${operatorLabel(_operator)}'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          modeSegmented(),
          const SizedBox(height: 8),

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [if (showOperator) operatorControl(), countWidget()],
          ),
        ],
      ),
    );
  }

  bool get isAr => widget.language == 'ar';
}

class SearchResultItem extends StatelessWidget {
  const SearchResultItem({
    required this.verseFontFamily,
    required this.hit,
    required this.effectiveMode,
    required this.onTap,
    required this.language,
    super.key,
  });

  final SearchHit hit;
  final SearchMatchMode effectiveMode;
  final VoidCallback onTap;
  final FontFamily verseFontFamily;
  final String language;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAr = language == 'ar';

    final plain = Quran.instance.getVerseInPlainText(hit.surah, hit.verse);
    final display = Quran.instance.getVerse(hit.surah, hit.verse);
    
    final surahName = isAr 
        ? Quran.instance.getSurahNameArabic(hit.surah) 
        : Quran.instance.getSurahName(hit.surah);
    final verseNum = isAr ? getArabicNumber(hit.verse) : hit.verse.toString();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Surah Name & Verse Number ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$surahName - $verseNum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                      fontFamily: isAr ? FontFamily.arabicNumbersFontFamily.name : null,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isAr ? Icons.arrow_forward_ios_rounded : Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 8),

            _HighlightedText(
              debug: kDebugMode,
              plainText: plain,
              displayText: display,
              matchedPlainWordIndexes: hit.matchedWordIndexes.toSet(),
              highlightColor: colorScheme.primary,
              baseColor: colorScheme.onSurface,
              verseFontFamily: verseFontFamily,
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.verseFontFamily,
    required this.plainText,
    required this.displayText,
    required this.matchedPlainWordIndexes,
    required this.highlightColor,
    required this.baseColor,
    this.debug = false,
  });

  final String plainText;
  final String displayText;
  final Set<int> matchedPlainWordIndexes;
  final Color highlightColor;
  final Color baseColor;
  final FontFamily verseFontFamily;
  final bool debug;

  void _d(String msg) {
    if (kDebugMode && debug) debugPrint(msg);
  }

  // Tokenization helpers
  List<String> _splitDisplayTokens(String s) =>
      s.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();

  String _stripBidi(String s) =>
      s.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u2066-\u2069]'), '');

  bool _containsPua(String s) => s.runes.any((r) => r >= 0xE000 && r <= 0xF8FF);

  bool _hasArabicLetter(String s) =>
      RegExp(r'[\u0621-\u064A\u0671]').hasMatch(s);

  bool _isDisplayWordToken(String token) {
    final t = _stripBidi(token).trim();
    if (t.isEmpty) return false;
    if (_containsPua(t)) return true;

    // Support normal-unicode display too:
    final norm = ArabicTextProcessor.normalize(t);
    return norm.isNotEmpty && _hasArabicLetter(norm);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ---- 1) Plain "content words" count must match SearchService's
    // indexing logic.
    final plainTokens = ArabicTextProcessor.tokenize(plainText);

    final plainContentWords = <String>[];
    for (final t in plainTokens) {
      final n = ArabicTextProcessor.normalize(t);
      if (n.isEmpty) continue;
      if (!_hasArabicLetter(n)) continue;
      plainContentWords.add(t);
    }

    // ---- 2) Keep original display tokens for rendering (PUA+RLM ordering),
    // but remove tokens that become empty after stripping bidi.
    final displayTokens = _splitDisplayTokens(
      displayText,
    ).where((t) => _stripBidi(t).trim().isNotEmpty).toList();

    // ---- 3) Build display->plain mapping (consume only display word tokens)
    final displayToPlain = <int?>[];
    int p = 0;

    for (final dt in displayTokens) {
      if (_isDisplayWordToken(dt)) {
        displayToPlain.add(p < plainContentWords.length ? p : null);
        p++;
      } else {
        displayToPlain.add(null);
      }
    }

    // ---- 4) Find first match for slicing
    int firstMatchPlainIndex = -1;
    if (matchedPlainWordIndexes.isNotEmpty) {
      firstMatchPlainIndex = matchedPlainWordIndexes.reduce(
        (a, b) => a < b ? a : b,
      );
    }

    int firstMatchDisplayIndex = -1;
    if (firstMatchPlainIndex != -1) {
      firstMatchDisplayIndex = displayToPlain.indexWhere(
        (m) => m == firstMatchPlainIndex,
      );
    }

    int startDisplayIndex = 0;
    bool showStartEllipsis = false;
    if (firstMatchDisplayIndex > 10) {
      startDisplayIndex = firstMatchDisplayIndex - 3;
      showStartEllipsis = true;
    }

    final slicedDisplayTokens = displayTokens.sublist(startDisplayIndex);
    final slicedMap = displayToPlain.sublist(startDisplayIndex);

    // Optional trimming similar to your old behavior:
    if (verseFontFamily == FontFamily.hafs) {
      while (slicedDisplayTokens.isNotEmpty &&
          !_isDisplayWordToken(slicedDisplayTokens.last)) {
        slicedDisplayTokens.removeLast();
        slicedMap.removeLast();
      }
    }

    final isWarsh = verseFontFamily == FontFamily.warsh;

    _d(
      'plainContentWords=${plainContentWords.length}'
      ' displayTokens=${displayTokens.length}',
    );

    return RichText(
      textDirection: TextDirection.rtl,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontSize: isWarsh ? 26 : 20,
          color: baseColor,
          height: 1.8,
          fontWeight: isWarsh ? FontWeight.w500 : null,
          fontFamily: verseFontFamily.name,
          letterSpacing: 0,
        ),
        children: [
          if (showStartEllipsis)
            TextSpan(
              text: '... ',
              style: TextStyle(color: baseColor.applyOpacity(0.8)),
            ),
          ...List.generate(slicedDisplayTokens.length, (i) {
            final displayTok = slicedDisplayTokens[i];
            final plainIndex = slicedMap[i];

            final isMatch =
                plainIndex != null &&
                matchedPlainWordIndexes.contains(plainIndex);

            return TextSpan(
              text: '$displayTok ',
              style: isMatch
                  ? TextStyle(
                      backgroundColor: highlightColor,
                      color: colorScheme.onPrimary,
                    )
                  : null,
            );
          }),
        ],
      ),
    );
  }
}
