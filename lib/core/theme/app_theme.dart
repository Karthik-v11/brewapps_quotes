import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme({
    required bool isDarkMode,
    required Color accentColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      surface: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF2F2F7), // Light grey for light mode
      cardColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: accentColor,
        unselectedItemColor: isDarkMode ? Colors.white38 : Colors.black38,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        (isDarkMode ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
          bodyColor: isDarkMode ? Colors.white : Colors.black,
          displayColor: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  static ThemeData lightTheme = getTheme(
    isDarkMode: false,
    accentColor: Colors.deepPurple,
  );
  static ThemeData darkTheme = getTheme(
    isDarkMode: true,
    accentColor: Colors.deepPurple,
  );
}
