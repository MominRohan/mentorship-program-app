import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme state class
class ThemeState {
  final ThemeMode themeMode;
  final bool isDarkMode;

  ThemeState({
    required this.themeMode,
    required this.isDarkMode,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// Theme notifier class
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeState(
    themeMode: ThemeMode.system,
    isDarkMode: false,
  )) {
    _loadTheme();
  }

  // Load theme from shared preferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      
      ThemeMode themeMode;
      bool isDarkMode;
      
      switch (themeIndex) {
        case 0:
          themeMode = ThemeMode.system;
          isDarkMode = false;
          break;
        case 1:
          themeMode = ThemeMode.light;
          isDarkMode = false;
          break;
        case 2:
          themeMode = ThemeMode.dark;
          isDarkMode = true;
          break;
        default:
          themeMode = ThemeMode.system;
          isDarkMode = false;
      }

      state = state.copyWith(
        themeMode: themeMode,
        isDarkMode: isDarkMode,
      );
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  // Save theme to shared preferences
  Future<void> _saveTheme(int themeIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeIndex);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    int themeIndex;
    bool isDarkMode;

    switch (themeMode) {
      case ThemeMode.system:
        themeIndex = 0;
        isDarkMode = false;
        break;
      case ThemeMode.light:
        themeIndex = 1;
        isDarkMode = false;
        break;
      case ThemeMode.dark:
        themeIndex = 2;
        isDarkMode = true;
        break;
    }

    state = state.copyWith(
      themeMode: themeMode,
      isDarkMode: isDarkMode,
    );

    await _saveTheme(themeIndex);
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (state.themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// App theme data
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
  );
}
