import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_quran/quran/quran.dart';

class ReadingStatsService extends ChangeNotifier {
  ReadingStatsService._();
  static final ReadingStatsService instance = ReadingStatsService._();

  static const String _todayDateKey = 'stats_today_date';
  static const String _todaySecondsKey = 'stats_today_seconds';
  static const String _todayPagesKey = 'stats_today_pages';
  static const String _streakKey = 'stats_current_streak';
  static const String _lastActiveDateKey = 'stats_last_active_date';
  static const String _khatmPagesKey = 'stats_khatm_pages';

  final _prefs = SharedPreferencesAsync();

  int _todaySeconds = 0;
  Set<int> _todayPages = {};
  int _currentStreak = 0;
  String _lastActiveDate = '';
  Set<int> _khatmPages = {};
  bool _initialized = false;

  int get todaySeconds => _todaySeconds;
  int get todayMinutes => (_todaySeconds / 60).round();
  int get todayPagesCount => _todayPages.length;
  int get currentStreak => _currentStreak;
  int get khatmPagesCount => _khatmPages.length;
  double get khatmProgress =>
      (_khatmPages.length / Quran.totalPagesCount).clamp(0.0, 1.0);
  int get khatmPercentage => (khatmProgress * 100).round();

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static String _getTodayString() => _formatDate(DateTime.now());

  static String _getYesterdayString() =>
      _formatDate(DateTime.now().subtract(const Duration(days: 1)));

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final today = _getTodayString();
    final savedDate = await _prefs.getString(_todayDateKey) ?? today;
    _lastActiveDate = await _prefs.getString(_lastActiveDateKey) ?? '';
    _currentStreak = await _prefs.getInt(_streakKey) ?? 0;

    final khatmList = await _prefs.getStringList(_khatmPagesKey) ?? [];
    _khatmPages = khatmList.map(int.parse).toSet();

    if (savedDate == today) {
      _todaySeconds = await _prefs.getInt(_todaySecondsKey) ?? 0;
      final pagesList = await _prefs.getStringList(_todayPagesKey) ?? [];
      _todayPages = pagesList.map(int.parse).toSet();
    } else {
      final yesterday = _getYesterdayString();
      if (_lastActiveDate != yesterday && _lastActiveDate != today) {
        _currentStreak = 0;
        await _prefs.setInt(_streakKey, 0);
      }
      _todaySeconds = 0;
      _todayPages = {};
      await _prefs.setString(_todayDateKey, today);
      await _prefs.setInt(_todaySecondsKey, 0);
      await _prefs.setStringList(_todayPagesKey, []);
    }
    notifyListeners();
  }

  void _checkDateRollover() {
    final today = _getTodayString();
    if (_lastActiveDate.isNotEmpty && _lastActiveDate != today) {
      final yesterday = _getYesterdayString();
      if (_lastActiveDate != yesterday) {
        _currentStreak = 0;
        _prefs.setInt(_streakKey, 0);
      }
      _todaySeconds = 0;
      _todayPages.clear();
      _prefs.setString(_todayDateKey, today);
      _prefs.setInt(_todaySecondsKey, 0);
      _prefs.setStringList(_todayPagesKey, []);
    }
  }

  Future<void> addReadingTime(int seconds) async {
    await init();
    _checkDateRollover();

    _todaySeconds += seconds;
    _updateStreakOnActivity();

    notifyListeners();
    await _prefs.setInt(_todaySecondsKey, _todaySeconds);
  }

  Future<void> recordPageRead(int pageNumber) async {
    await init();
    _checkDateRollover();

    bool changed = false;
    if (_todayPages.add(pageNumber)) {
      changed = true;
      await _prefs.setStringList(
        _todayPagesKey,
        _todayPages.map((p) => p.toString()).toList(),
      );
    }

    if (_khatmPages.add(pageNumber)) {
      changed = true;
      await _prefs.setStringList(
        _khatmPagesKey,
        _khatmPages.map((p) => p.toString()).toList(),
      );
    }

    _updateStreakOnActivity();

    if (changed) {
      notifyListeners();
    }
  }

  void _updateStreakOnActivity() {
    final today = _getTodayString();
    if (_lastActiveDate != today) {
      final yesterday = _getYesterdayString();
      if (_lastActiveDate == yesterday) {
        _currentStreak += 1;
      } else {
        _currentStreak = 1;
      }
      _lastActiveDate = today;
      _prefs.setString(_lastActiveDateKey, today);
      _prefs.setInt(_streakKey, _currentStreak);
    }
  }

  Future<void> resetKhatm() async {
    _khatmPages.clear();
    notifyListeners();
    await _prefs.setStringList(_khatmPagesKey, []);
  }
}
