import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF0D0F14);
  static const Color surface = Color(0xFF161B25);
  static const Color surfaceElevated = Color(0xFF1E2535);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentSecondary = Color(0xFFFF6B6B);
  static const Color accentGold = Color(0xFFFFD93D);
  static const Color textPrimary = Color(0xFFE8EDF5);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color textMuted = Color(0xFF4A5568);
  static const Color border = Color(0xFF2D3748);
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFFC8181);

  // Difficulty colors
  static const Color easy = Color(0xFF48BB78);
  static const Color medium = Color(0xFFED8936);
  static const Color hard = Color(0xFFFC8181);

  // Category colors
  static const Map<String, Color> categoryColors = {
    'math': Color(0xFF667EEA),
    'programming': Color(0xFF4ECDC4),
    'hardware': Color(0xFFED8936),
    'theory': Color(0xFF9F7AEA),
    'ai': Color(0xFFFF6B6B),
    'systems': Color(0xFF48BB78),
    'general': Color(0xFF8892A4),
  };

  static Color categoryColor(String cat) =>
      categoryColors[cat] ?? textSecondary;

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          background: background,
          surface: surface,
          primary: accent,
          secondary: accentSecondary,
          error: error,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
                color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32),
            displayMedium: TextStyle(
                color: textPrimary, fontWeight: FontWeight.w600, fontSize: 24),
            displaySmall: TextStyle(
                color: textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
            headlineMedium: TextStyle(
                color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
            titleLarge: TextStyle(
                color: textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
            bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
            bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
            bodySmall: TextStyle(color: textMuted, fontSize: 12),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: textSecondary),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: accent.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.spaceGrotesk(
                  color: accent, fontSize: 12, fontWeight: FontWeight.w600);
            }
            return GoogleFonts.spaceGrotesk(
                color: textSecondary, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: accent, size: 22);
            }
            return const IconThemeData(color: textSecondary, size: 22);
          }),
        ),
        dividerColor: border,
        cardColor: surface,
      );
}
