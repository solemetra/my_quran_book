import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing the single quick bookmark for the current reading page.
class RibbonBookmarkService {
  factory RibbonBookmarkService() => _instance;
  RibbonBookmarkService._internal();
  static final RibbonBookmarkService _instance =
      RibbonBookmarkService._internal();

  static const String _prefKey = 'quick_bookmark_page_number';

  final ValueNotifier<int?> ribbonPageNotifier = ValueNotifier<int?>(null);
  bool _initialized = false;

  int? get currentRibbonPage => ribbonPageNotifier.value;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final page =
        prefs.getInt(_prefKey) ?? prefs.getInt('silk_ribbon_page_number');
    ribbonPageNotifier.value = page;
    _initialized = true;
  }

  /// Sets the bookmark to [pageNumber].
  Future<void> setRibbonPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, pageNumber);
    ribbonPageNotifier.value = pageNumber;
  }

  /// Removes the bookmark.
  Future<void> clearRibbon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    await prefs.remove('silk_ribbon_page_number');
    await prefs.remove('silk_ribbon_surah_number');
    await prefs.remove('silk_ribbon_verse_number');
    ribbonPageNotifier.value = null;
  }

  /// Toggles the bookmark on [pageNumber].
  Future<bool> toggleRibbon(int pageNumber) async {
    if (ribbonPageNotifier.value == pageNumber) {
      await clearRibbon();
      return false; // removed
    } else {
      await setRibbonPage(pageNumber);
      return true; // placed
    }
  }

  bool isRibbonOnPage(int pageNumber) =>
      ribbonPageNotifier.value == pageNumber;
}
