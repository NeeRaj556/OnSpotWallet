import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Mystic Evening Wallet Theme
/// Modern fintech-grade design with Deep Purple (#9333EA), Teal (#14B8A6), and Golden Amber (#FBBF24)
/// Maintains backward compatibility with existing NeonBlueTheme references
class NeonBlueTheme {
  // Mystic Evening Primary Colors
  static const Color neonBlue = AppColors.primaryBlue; // #9333EA - Deep Purple
  static const Color neonBlueDark =
      AppColors.deepGray; // #1F1937 - Deep Purple-Gray
  static const Color neonBlueLight = AppColors.accentCyan; // #14B8A6 - Teal
  static const Color electricBlue = AppColors.primaryBlue;

  // Accent Colors
  static const Color neonPurple = AppColors.softViolet; // #7D5FFF
  static const Color neonPink = AppColors.errorRed; // #FF4C4C
  static const Color neonGreen = AppColors.successGreen; // #00C896
  static const Color neonOrange = AppColors.warningAmber; // #FFB300
  static const Color neonYellow =
      AppColors.softYellow; // #FBBF24 - Golden Amber

  // Base Colors
  static const Color white = AppColors.white;
  static const Color offWhite = AppColors.lightText; // #F8F9FA
  static const Color lightGray = AppColors.lightGray;
  static const Color mediumGray = AppColors.mediumGray;
  static const Color darkGray = AppColors.darkGray;
  static const Color almostBlack = AppColors.deepGray;

  // Gradient Definitions
  static const LinearGradient neonGradient = AppColors.primaryGradient;
  static const LinearGradient purpleGradient = AppColors.violetGradient;
  static const LinearGradient successGradient = AppColors.successGradient;
  static const LinearGradient accentGradient = AppColors.accentGradient;
  static const LinearGradient darkModeGradient = AppColors.darkModeGradient;
  static const LinearGradient warningGradient = LinearGradient(
    colors: [AppColors.warningAmber, Color(0xFFFF8800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Effects
  static List<BoxShadow> neonShadow = AppColors.primaryShadow;
  static List<BoxShadow> neonGlow = AppColors.accentGlow;
  static List<BoxShadow> yellowGlow = AppColors.yellowGlow;
  static List<BoxShadow> softShadow = AppColors.softElevation;

  // Theme Data - Light Mode (Mystic Evening Style)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor:
          AppColors.lightText, // #F8F9FA - Light text color as background
      fontFamily: 'Inter', // Default font

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue, // #0D6EFD Electric Blue
        secondary: AppColors.accentCyan, // #00E7FF Aqua Cyan
        tertiary: AppColors.softYellow, // #FFD60A Soft Yellow
        surface: AppColors.white,
        error: AppColors.errorRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.deepGray,
        onSurface: AppColors.deepGray, // #101820 for text on light surfaces
        onError: AppColors.white,
        outline: AppColors.lightGray,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.deepGray, // #101820 text color
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.deepGray, // #101820
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Button Themes (Electric Blue Premium Style)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          elevation: 8,
          shadowColor: AppColors.primaryBlue.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          // Gradient background for elevated buttons
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.lightGray;
            }
            return null; // Use gradient via decoration
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightGray, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.mediumGray,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.primaryBlue,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryBlue,
        size: 24,
      ),

      // Text Theme (Poppins for headings, Inter for body) - Deep Gray text (#101820)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.deepGray, // #101820
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.deepGray, // #101820
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.deepGray, // #101820
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.deepGray, // #101820
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.deepGray, // #101820
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.deepGray, // #101820
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.deepGray, // #101820
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.deepGray, // #101820
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepGray, // #101820
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.lightText, // #F8F9FA
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Theme Data - Dark Mode (Mystic Evening Dark Style)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.accentCyan, // #00E7FF Aqua Cyan for dark mode
      scaffoldBackgroundColor:
          AppColors.darkBgPrimary, // #0A0E14 - Very dark background
      fontFamily: 'Inter',

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCyan, // #00E7FF Aqua Cyan
        secondary: AppColors.primaryBlue, // #0D6EFD Electric Blue
        tertiary: AppColors.softYellow, // #FFD60A Soft Yellow
        surface: AppColors.darkBgSecondary, // #161D27 Secondary dark bg
        error: AppColors.errorRed,
        onPrimary: AppColors.darkBgPrimary, // Dark text on cyan
        onSecondary: AppColors.white,
        onSurface: AppColors.lightText, // #F8F9FA Light text on dark
        onError: AppColors.white,
        outline: AppColors.darkGray,
      ),

      // AppBar Theme (Dark)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepGray, // #101820
        foregroundColor: AppColors.lightText, // #F8F9FA
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.lightText, // #F8F9FA
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Card Theme (Dark)
      cardTheme: CardTheme(
        color: AppColors.darkBgSecondary, // #161D27
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ), // Button Themes (Dark Mode)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.deepNavy,
          elevation: 8,
          shadowColor: AppColors.accentCyan.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          side: const BorderSide(color: AppColors.accentCyan, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Input Decoration Theme (Dark)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgSecondary, // #161D27
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkGray, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColors.accentCyan, width: 2), // #00E7FF
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.mediumGray,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.accentCyan, // #00E7FF
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Chip Theme (Dark)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accentCyan.withOpacity(0.2),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.accentCyan,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.deepNavy,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Icon Theme (Dark)
      iconTheme: const IconThemeData(
        color: AppColors.accentCyan,
        size: 24,
      ),

      // Text Theme (Dark - Poppins for headings, Inter for body) - Light text (#F8F9FA)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.lightText, // #F8F9FA
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.lightText, // #F8F9FA
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.lightText, // #F8F9FA
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText, // #F8F9FA
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText, // #F8F9FA
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText, // #F8F9FA
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.lightText, // #F8F9FA
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.lightText, // #F8F9FA
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkBgPrimary, // #0A0E14 - Dark text on cyan buttons
          letterSpacing: 0.5,
        ),
      ),

      // Snackbar Theme (Dark)
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepGray, // #101820
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.lightText, // #F8F9FA
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
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
