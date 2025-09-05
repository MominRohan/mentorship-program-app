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
  // Define the primary color constant
  static const Color primaryColor = Color(0xFFBA8900);
  static const Color primaryColorDark = Color(0xFF8B6600);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primaryColor,
      onPrimaryContainer: Colors.white,
      surface: Colors.white,
      background: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: primaryColor,
    ),
    primaryIconTheme: IconThemeData(
      color: Colors.white,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: primaryColor,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColorDark,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryColorDark,
      onPrimary: Colors.white,
      primaryContainer: primaryColorDark,
      onPrimaryContainer: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColorDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: const Color(0xFF2D2D2D), // Dark card background
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColorDark,
      foregroundColor: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: Colors.white, // All icons white in dark mode
    ),
    primaryIconTheme: IconThemeData(
      color: Colors.white,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: primaryColorDark, // ListTile icons use primaryColorDark in dark mode
      textColor: Colors.white,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColorDark,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColorDark,
        side: BorderSide(color: primaryColorDark),
      ),
    ),
  );
}
