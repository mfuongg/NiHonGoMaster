import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFF179B8);
  static const Color primaryDark = Color(0xFF956AD6);
  static const Color accentGold = Color(0xFFF0BD74);
  static const Color accentBlue = Color(0xFF92B9E3);
  static const Color accentOrange = Color(0xFFFFC4A4);
  static const Color accentMint = Color(0xFF70C2B4);
  static const Color bgLight = Color(0xFFF8F3FA);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF34284F);
  static const Color textMedium = Color(0xFF6F6591);
  static const Color textLight = Color(0xFFBBB1D3);
  static const Color successGreen = Color(0xFF70C2B4);
  static const Color warningOrange = Color(0xFFF0BD74);
  static const Color errorRed = Color(0xFFF179B8);
  static const Color n5Color = Color(0xFFFBA2D0);
  static const Color n4Color = Color(0xFFC688EB);
  static const Color n3Color = Color(0xFF92B9E3);
  static const Color n2Color = Color(0xFFF0BD74);
  static const Color n1Color = Color(0xFF6C7EE1);

  static const List<Color> dreamyGradient = [
    Color(0xFFF179B8),
    Color(0xFF956AD6),
    Color(0xFF6C7EE1),
  ];

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryDark,
        secondary: primaryRed,
        tertiary: accentGold,
        surface: bgCard,
        error: errorRed,
        onPrimary: Colors.white,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: bgLight,
      splashColor: primaryRed.withOpacity(0.08),
      highlightColor: primaryDark.withOpacity(0.05),
      cardColor: bgCard,
      dividerColor: textLight.withOpacity(0.3),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shadowColor: primaryDark.withOpacity(0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          foregroundColor: textDark,
          side: BorderSide(color: primaryDark.withOpacity(0.18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryDark.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryDark.withOpacity(0.12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: primaryDark, width: 1.8),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: errorRed, width: 1.4),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: errorRed, width: 1.8),
        ),
        prefixIconColor: textMedium,
        suffixIconColor: textMedium,
        labelStyle: GoogleFonts.poppins(color: textMedium, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.poppins(color: textLight),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryDark,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 11),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primaryDark,
        secondarySelectedColor: primaryRed,
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: primaryDark.withOpacity(0.12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w800, color: textDark),
        headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: textDark),
        titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: textDark),
        titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: textDark),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textDark),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: textMedium),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primaryDark,
        secondary: accentBlue,
        tertiary: accentGold,
        surface: const Color(0xFF1F1832),
        error: errorRed,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF171226),
      cardColor: const Color(0xFF221A37),
      dividerColor: Colors.white12,
      cardTheme: CardThemeData(
        color: const Color(0xFF221A37),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: lightTheme.elevatedButtonTheme,
      outlinedButtonTheme: lightTheme.outlinedButtonTheme,
      inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
        fillColor: const Color(0xFF221A37),
        labelStyle: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF221A37),
        selectedItemColor: accentBlue,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 11),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }

  static Color jlptColor(String level) {
    switch (level) {
      case 'N5':
        return n5Color;
      case 'N4':
        return n4Color;
      case 'N3':
        return n3Color;
      case 'N2':
        return n2Color;
      case 'N1':
        return n1Color;
      default:
        return n5Color;
    }
  }
}
