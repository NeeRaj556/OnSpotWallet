import 'package:flutter/material.dart';

/// Neon Blue Theme for OnSpot Wallet
/// Modern, sleek design with neon blue accents and white backgrounds
class NeonBlueTheme {
  // Primary Neon Blue Colors
  static const Color neonBlue = Color(0xFF00D9FF); // Bright cyan blue
  static const Color neonBlueDark = Color(0xFF0099CC); // Deep cyan
  static const Color neonBlueLight = Color(0xFF66E5FF); // Light cyan
  static const Color electricBlue = Color(0xFF0A84FF); // Electric blue

  // Accent Colors
  static const Color neonPurple = Color(0xFF7B61FF); // Purple accent
  static const Color neonPink = Color(0xFFFF006E); // Pink accent for errors
  static const Color neonGreen = Color(0xFF00FF88); // Green for success
  static const Color neonOrange = Color(0xFFFF9500); // Orange for warnings

  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color lightGray = Color(0xFFE0E5EA);
  static const Color mediumGray = Color(0xFF8E9AA5);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color almostBlack = Color(0xFF1A1F2E);

  // Gradient Definitions
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonBlue, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [neonPurple, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [neonGreen, Color(0xFF00CC70)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [neonOrange, Color(0xFFFF6B00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Effects
  static List<BoxShadow> neonShadow = [
    BoxShadow(
      color: neonBlue.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> neonGlow = [
    BoxShadow(
      color: neonBlue.withOpacity(0.5),
      blurRadius: 30,
      spreadRadius: 5,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: neonBlue,
      scaffoldBackgroundColor: offWhite,
      colorScheme: const ColorScheme.light(
        primary: neonBlue,
        secondary: electricBlue,
        tertiary: neonPurple,
        surface: white,
        error: neonPink,
        onPrimary: white,
        onSecondary: white,
        onSurface: almostBlack,
        onError: white,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: neonBlue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: white,
        elevation: 8,
        shadowColor: neonBlue.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonBlue,
          foregroundColor: white,
          elevation: 8,
          shadowColor: neonBlue.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonBlue,
          side: const BorderSide(color: neonBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: lightGray, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: lightGray, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: neonBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: neonPink, width: 2),
        ),
        labelStyle: const TextStyle(
          color: mediumGray,
          fontSize: 16,
        ),
        floatingLabelStyle: const TextStyle(
          color: neonBlue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: neonBlueLight.withOpacity(0.2),
        labelStyle: const TextStyle(
          color: neonBlueDark,
          fontWeight: FontWeight.bold,
        ),
        secondaryLabelStyle: const TextStyle(color: white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: neonBlue,
        size: 24,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: almostBlack,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: almostBlack,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: almostBlack,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: almostBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: almostBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: almostBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkGray,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: mediumGray,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: white,
          letterSpacing: 1.2,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: almostBlack,
        contentTextStyle: const TextStyle(color: white, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper Methods
  static BoxDecoration glassCard({Color? color}) {
    return BoxDecoration(
      color: (color ?? white).withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: neonBlue.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: neonShadow,
    );
  }

  static BoxDecoration neonCard({required Gradient gradient}) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: neonGlow,
    );
  }

  static BoxDecoration statusBadge({required bool isOnline}) {
    return BoxDecoration(
      gradient: isOnline ? successGradient : warningGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: (isOnline ? neonGreen : neonOrange).withOpacity(0.4),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
