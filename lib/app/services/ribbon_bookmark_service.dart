import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing the single physical-style "Silk Ribbon" bookmark (Ляссе).
///
/// Unlike verse bookmarks with categories and notes, the Silk Ribbon bookmark
/// marks the single page where the reader currently stopped reading,
/// mirroring the physical cloth ribbon found inside printed Mushafs.
class RibbonBookmarkService {
  factory RibbonBookmarkService() => _instance;
  RibbonBookmarkService._internal();
  static final RibbonBookmarkService _instance = RibbonBookmarkService._internal();

  static const String _prefKey = 'silk_ribbon_page_number';

  final ValueNotifier<int?> ribbonPageNotifier = ValueNotifier<int?>(null);
  bool _initialized = false;

  int? get currentRibbonPage => ribbonPageNotifier.value;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_prefKey);
    ribbonPageNotifier.value = page;
    _initialized = true;
  }

  /// Sets or updates the ribbon bookmark to [pageNumber].
  Future<void> setRibbonPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, pageNumber);
    ribbonPageNotifier.value = pageNumber;
  }

  /// Removes the ribbon bookmark.
  Future<void> clearRibbon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    ribbonPageNotifier.value = null;
  }

  /// Toggles the ribbon bookmark on [pageNumber].
  /// If it is already on [pageNumber], it removes it.
  /// If it is elsewhere or not set, it places it on [pageNumber].
  Future<bool> toggleRibbon(int pageNumber) async {
    if (ribbonPageNotifier.value == pageNumber) {
      await clearRibbon();
      return false; // removed
    } else {
      await setRibbonPage(pageNumber);
      return true; // placed
    }
  }

  bool isRibbonOnPage(int pageNumber) => ribbonPageNotifier.value == pageNumber;
}
