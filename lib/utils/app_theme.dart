import 'package:flutter/material.dart';

class AppColors {
  // Professional color palette matching web design
  // Primary: hsl(160 84% 39%) = RGB(15, 156, 99) = #0F9C63
  static const Color primary = Color(0xFF0F9C63); // Teal/Emerald matching web
  static const Color primaryDark = Color(0xFF0A7A4D); // Darker shade
  static const Color primaryGlow = Color(0xFF00E673); // hsl(160 100% 45%) - Glow effect
  // Secondary: hsl(45 93% 47%) = RGB(245, 200, 7) = #F5C807
  static const Color secondary = Color(0xFFF5C807); // Amber/Yellow matching web
  static const Color secondaryForeground = Color(0xFFFFFFFF); // White text on secondary
  static const Color accent = Color(0xFFE6F7F2); // hsl(160 60% 96%) - Light accent
  static const Color accentForeground = Color(0xFF0A7A4D); // hsl(160 84% 25%) - Dark text on accent
  static const Color danger = Color(0xFFEF4444); // Red-500
  static const Color warning = Color(0xFFF5C807); // Amber matching secondary
  static const Color success = Color(0xFF0F9C63); // Primary color
  static const Color info = Color(0xFF0EA5E9); // Sky-500

  // Background and surface colors matching web
  static const Color background = Color(0xFFFFFFFF); // hsl(0 0% 100%) - White
  static const Color surface = Color(0xFFFFFFFF); // Card background
  static const Color surfaceLight = Color(0xFFF5F5F5); // hsl(240 4.8% 95.9%) - Muted
  static const Color surfaceDark = Color(0xFFF3F4F6); // Gray-100

  // Text colors matching web
  static const Color textPrimary = Color(0xFF0A0A0A); // hsl(240 10% 3.9%) - Foreground
  static const Color textSecondary = Color(0xFF6B7280); // hsl(240 3.8% 46.1%) - Muted foreground
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray-400
  static const Color textLight = Color(0xFFD1D5DB); // Gray-300

  // Border colors matching web
  static const Color border = Color(0xFFE5E5E5); // hsl(240 5.9% 90%) - Border
  static const Color borderLight = Color(0xFFF3F4F6); // Gray-100
  static const Color input = Color(0xFFE5E5E5); // hsl(240 5.9% 90%) - Input border
  static const Color ring = Color(0xFF0F9C63); // Primary color for focus ring

  // Gradient colors matching web design
  // gradient-primary: linear-gradient(135deg, hsl(160 84% 39%), hsl(160 100% 45%))
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F9C63), Color(0xFF00E673)], // Primary to Primary Glow
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // gradient-secondary: linear-gradient(135deg, hsl(45 93% 47%), hsl(35 100% 55%))
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFF5C807), Color(0xFFFFA500)], // Secondary to Orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0F9C63), Color(0xFF00E673)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadow effects matching web
  // shadow-elegant: 0 10px 30px -10px hsl(160 84% 39% / 0.3)
  static List<BoxShadow> get elegantShadow => [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 30,
      offset: Offset(0, 10),
      spreadRadius: -10,
    ),
  ];
  
  // shadow-glow: 0 0 40px hsl(160 100% 45% / 0.2)
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryGlow.withOpacity(0.2),
      blurRadius: 40,
      offset: Offset(0, 0),
    ),
  ];

  // Category colors - modern palette
  static const List<Color> categoryColors = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFFEAB308), // Yellow
    Color(0xFF84CC16), // Lime
    Color(0xFF10B981), // Emerald
    Color(0xFF14B8A6), // Teal
    Color(0xFF0891B2), // Cyan
    Color(0xFF0EA5E9), // Sky
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFA855F7), // Purple
    Color(0xFFD946EF), // Fuchsia
    Color(0xFFEC4899), // Pink
  ];
}

class AppColorsDark {
  // Dark mode color palette matching web
  // Primary stays the same in dark mode: hsl(160 84% 39%)
  static const Color primary = Color(0xFF0F9C63); // Same as light mode
  static const Color primaryDark = Color(0xFF0A7A4D);
  static const Color primaryGlow = Color(0xFF00E673); // hsl(160 100% 45%)
  // Secondary: hsl(45 93% 47%)
  static const Color secondary = Color(0xFFF5C807); // Same as light mode
  static const Color secondaryForeground = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF1A3D2E); // hsl(160 84% 15%) - Dark accent
  static const Color accentForeground = Color(0xFFB8F5D9); // hsl(160 100% 85%) - Light text on accent
  static const Color danger = Color(0xFF9E1F1F); // hsl(0 62.8% 30.6%) - Darker red
  static const Color warning = Color(0xFFF5C807); // Amber
  static const Color success = Color(0xFF0F9C63); // Primary
  static const Color info = Color(0xFF0EA5E9); // Sky-500

  // Background and surface colors matching web dark mode
  static const Color background = Color(0xFF0A0A0A); // hsl(240 10% 3.9%) - Dark background
  static const Color surface = Color(0xFF141414); // hsl(240 8% 8%) - Card background
  static const Color surfaceLight = Color(0xFF1F1F1F); // hsl(240 3.7% 15.9%) - Muted
  static const Color surfaceDark = Color(0xFF0A0A0A); // Same as background

  // Text colors matching web dark mode
  static const Color textPrimary = Color(0xFFFAFAFA); // hsl(0 0% 98%) - Foreground
  static const Color textSecondary = Color(0xFFA3A3A3); // hsl(240 5% 64.9%) - Muted foreground
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray-400
  static const Color textLight = Color(0xFF6B7280); // Gray-500

  // Border colors matching web dark mode
  static const Color border = Color(0xFF282828); // hsl(240 3.7% 15.9%) - Border
  static const Color borderLight = Color(0xFF3A3A3A); // Gray-600
  static const Color input = Color(0xFF282828); // Input border
  static const Color ring = Color(0xFF0F9C63); // Primary for focus ring
  
  // Shadow effects for dark mode
  static List<BoxShadow> get elegantShadow => [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 30,
      offset: Offset(0, 10),
      spreadRadius: -10,
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryGlow.withOpacity(0.3),
      blurRadius: 40,
      offset: Offset(0, 0),
    ),
  ];
}

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        error: AppColors.danger,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.1),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0, // Use custom shadows instead
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Matching web --radius: 0.75rem
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
          height: 1.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.ring, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.danger),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white, // Primary foreground
          elevation: 0, // Use custom shadows
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary, // Use primary color for selected
        unselectedItemColor: AppColors.textSecondary,
        selectedIconTheme: IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
        selectedLabelStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.surface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0, // Use custom shadows
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColorsDark.primary,
        secondary: AppColorsDark.secondary,
        tertiary: AppColorsDark.accent,
        error: AppColorsDark.danger,
        surface: AppColorsDark.surface,
        onSurface: AppColorsDark.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsDark.surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColorsDark.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColorsDark.textPrimary),
      ),
      scaffoldBackgroundColor: AppColorsDark.background,
      cardTheme: CardThemeData(
        color: AppColorsDark.surface,
        elevation: 0, // Use custom shadows
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Matching web
          side: BorderSide(color: AppColorsDark.border, width: 1),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColorsDark.textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColorsDark.textPrimary,
          letterSpacing: -0.8,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColorsDark.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColorsDark.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColorsDark.textSecondary,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColorsDark.textTertiary,
          height: 1.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorsDark.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorsDark.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorsDark.ring, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorsDark.danger),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: AppColorsDark.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.surface,
        selectedItemColor: AppColorsDark.primary,
        unselectedItemColor: AppColorsDark.textSecondary,
        selectedIconTheme: IconThemeData(color: AppColorsDark.primary),
        unselectedIconTheme: IconThemeData(color: AppColorsDark.textSecondary),
        selectedLabelStyle: TextStyle(
          color: AppColorsDark.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          color: AppColorsDark.textSecondary,
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColorsDark.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColorsDark.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
