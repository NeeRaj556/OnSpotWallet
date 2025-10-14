import 'package:flutter/material.dart';

/// Mystic Evening Color Palette
/// Dark, mysterious fintech-grade color system with deep purples and midnight blues
class AppColors {
  // Primary Colors - Mystic Evening Theme
  static const Color primaryBlue =
      Color(0xFF6366F1); // #6366F1 - Indigo (Primary)
  static const Color accentCyan =
      Color(0xFF8B5CF6); // #8B5CF6 - Purple (Secondary)
  static const Color softYellow = Color(0xFFFBBF24); // #FBBF24 - Amber (Accent)
  static const Color deepGray =
      Color(0xFF1E1B4B); // #1E1B4B - Deep Indigo (Background)
  static const Color lightText = Color(0xFFF3F4F6); // #F3F4F6 - Light Gray Text

  // Dark Mode Variants
  static const Color darkPrimaryBlue =
      Color(0xFF4F46E5); // Darker indigo for dark mode
  static const Color darkAccentCyan = Color(0xFF7C3AED); // Darker purple
  static const Color darkBgPrimary =
      Color(0xFF0F0D1F); // Very dark indigo-black
  static const Color darkBgSecondary =
      Color(0xFF1A1736); // Secondary dark background

  // Semantic Colors
  static const Color successGreen = Color(0xFF10B981); // #10B981 - Emerald
  static const Color warningAmber = Color(0xFFF59E0B); // #F59E0B - Amber
  static const Color errorRed = Color(0xFFEF4444); // #EF4444 - Red
  static const Color softViolet = Color(0xFFA78BFA); // #A78BFA - Light Purple

  // Neutral Colors
  static const Color darkCharcoal = Color(0xFF111827); // #111827 - Gray-900
  static const Color white = Color(0xFFFFFFFF); // #FFFFFF - Pure white
  static const Color lightGray = Color(0xFFE5E7EB); // #E5E7EB - Gray-200
  static const Color mediumGray = Color(0xFF9CA3AF); // #9CA3AF - Gray-400
  static const Color darkGray = Color(0xFF4B5563); // #4B5563 - Gray-600

  // Backward compatibility aliases
  static const Color deepNavy = deepGray; // Alias for backward compatibility
  static const Color whiteSmoke = lightText; // Alias for backward compatibility

  // Gradients - Mystic Evening Premium Look
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentCyan], // Purple → Teal
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [deepGray, darkPrimaryBlue], // Dark purple-gray → Purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentCyan, softYellow], // Teal → Golden
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkModeGradient = LinearGradient(
    colors: [darkBgPrimary, darkBgSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleTealGradient = LinearGradient(
    colors: [Color(0xFF9333EA), Color(0xFF14B8A6)], // Deep Purple → Teal
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldenGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)], // Golden → Amber
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)], // Emerald gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [softViolet, Color(0xFF9333EA)], // Light purple → Deep purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows - Depth and Elevation
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primaryBlue.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> accentGlow = [
    BoxShadow(
      color: accentCyan.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> yellowGlow = [
    BoxShadow(
      color: softYellow.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> softElevation = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> darkElevation = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Backward compatibility - keep old names mapped to new colors
  static const Color neonBlue = primaryBlue;
  static const Color neonBlueDark = deepGray;
  static const Color neonBlueLight = accentCyan;
  static const LinearGradient neonGradient = primaryGradient;
  static List<BoxShadow> neonShadow = primaryShadow;
}
