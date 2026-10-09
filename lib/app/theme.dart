import 'package:flutter/material.dart';
import 'package:my_quran/app/models.dart';

const _seedColor = Color(0xFF0F766E);

({ThemeData theme, ThemeData? darkTheme}) buildThemes(
  AppTheme appTheme, {
  ThemeMode themeMode = ThemeMode.system,
  ColorScheme? deviceLightScheme,
  ColorScheme? deviceDarkScheme,
}) {
  return switch (appTheme) {
    AppTheme.myQuran => switch (themeMode) {
      ThemeMode.light => (theme: _buildMyQuranLight(), darkTheme: null),
      ThemeMode.dark => (theme: _buildMyQuranDark(), darkTheme: null),

      ThemeMode.system => (
        theme: _buildMyQuranLight(),
        darkTheme: _buildMyQuranDark(),
      ),
    },
    AppTheme.sepia => switch (themeMode) {
      ThemeMode.light => (theme: _buildSepiaLight(), darkTheme: null),
      ThemeMode.dark => (theme: _buildSepiaDark(), darkTheme: null),
      ThemeMode.system => (
        theme: _buildSepiaLight(),
        darkTheme: _buildSepiaDark(),
      ),
    },
    AppTheme.dynamic => switch (themeMode) {
      ThemeMode.light => (
        theme: _buildDynamicLight(deviceLightScheme),
        darkTheme: null,
      ),
      ThemeMode.dark => (
        theme: _buildDynamicDark(deviceDarkScheme),
        darkTheme: null,
      ),
      ThemeMode.system => (
        theme: _buildDynamicLight(deviceLightScheme),
        darkTheme: _buildDynamicDark(deviceDarkScheme),
      ),
    },
  };
}

ThemeData _buildMyQuranLight() {
  final base = ColorScheme.fromSeed(seedColor: _seedColor);
  final colorScheme = base.copyWith(
    surface: const Color(0xFFFAFDFC),
    onSurface: const Color(0xFF0D1211),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF2F7F5),
    surfaceContainer: const Color(0xFFEBF2EF),
    surfaceContainerHigh: const Color(0xFFE4ECE9),
    surfaceContainerHighest: const Color(0xFFDDE6E3),
    outline: const Color(0xFF6F7976),
    outlineVariant: const Color(0xFFBEC9C5),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
  );
}

ThemeData _buildMyQuranDark() {
  final base = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  );
  final colorScheme = base.copyWith(
    surface: const Color(0xFF0F1514),
    onSurface: const Color(0xFFDEE4E1),
    surfaceContainerLowest: const Color(0xFF0A0F0E),
    surfaceContainerLow: const Color(0xFF171D1C),
    surfaceContainer: const Color(0xFF1B2221),
    surfaceContainerHigh: const Color(0xFF252C2B),
    surfaceContainerHighest: const Color(0xFF303736),
    outline: const Color(0xFF899390),
    outlineVariant: const Color(0xFF3F4946),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
  );
}

ThemeData _buildDynamicLight(ColorScheme? deviceScheme) {
  final seedColor = deviceScheme?.primary ?? Colors.blue;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    secondary: deviceScheme?.secondary,
    tertiary: deviceScheme?.tertiary,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
  );
}

ThemeData _buildDynamicDark(ColorScheme? deviceScheme) {
  final seedColor = deviceScheme?.primary ?? Colors.blue;
  final colorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: seedColor,
    secondary: deviceScheme?.secondary,
    tertiary: deviceScheme?.tertiary,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
  );
}

const _sepiaSeed = Color(0xFF7A5A3A);

// Light sepia surfaces (paper-like)
const _sepiaLightSurface = Color(0xFFF7F0E6);
const _sepiaLightOnSurface = Color(0xFF1A1410);

// Dark sepia surfaces (warm dark)
const _sepiaDarkSurface = Color(0xFF17110D);
const _sepiaDarkOnSurface = Color(0xFFF2E7DA);

ThemeData _buildSepiaLight() {
  final base = ColorScheme.fromSeed(seedColor: _sepiaSeed);

  final colorScheme = base.copyWith(
    surface: _sepiaLightSurface,
    onSurface: _sepiaLightOnSurface,

    // These help many Material3 widgets look cohesive on sepia backgrounds
    surfaceContainerLowest: const Color(0xFFFBF6EF),
    surfaceContainerLow: const Color(0xFFF4EBDD),
    surfaceContainer: const Color(0xFFF1E7DA),
    surfaceContainerHigh: const Color(0xFFEADCCE),
    surfaceContainerHighest: const Color(0xFFE2D1C2),

    outline: const Color(0xFFB8A999),
    outlineVariant: const Color(0xFFD7C7B7),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
  );
}

ThemeData _buildSepiaDark() {
  final base = ColorScheme.fromSeed(
    seedColor: _sepiaSeed,
    brightness: Brightness.dark,
  );

  final colorScheme = base.copyWith(
    surface: _sepiaDarkSurface,
    onSurface: _sepiaDarkOnSurface,

    surfaceContainerLowest: const Color(0xFF120D0A),
    surfaceContainerLow: const Color(0xFF1B1410),
    surfaceContainer: const Color(0xFF211813),
    surfaceContainerHigh: const Color(0xFF2A1F19),
    surfaceContainerHighest: const Color(0xFF33261F),

    outline: const Color(0xFF7E6B5D),
    outlineVariant: const Color(0xFF5D4C41),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
  );
}
