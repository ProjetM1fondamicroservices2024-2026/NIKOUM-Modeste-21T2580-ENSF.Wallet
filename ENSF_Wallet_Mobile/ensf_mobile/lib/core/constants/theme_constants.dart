import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  // Colors based on the blue theme from screenshots
  static const Color primaryColor = Color(0xFF4169E1); // Royal Blue
  static const Color secondaryColor = Color(0xFF6A5ACD); // Slate Blue
  static const Color accentColor = Color(0xFF8A2BE2); // Blue Violet
  static const Color backgroundLight = Color(0xFFF5F7FB); // Light Blue-Grey
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slightly darker Blue-Grey
  static const Color errorColor = Color(0xFFE57373); // Light Red
  static const Color successColor = Color(0xFF81C784); // Light Green
  static const Color warningColor = Color(0xFFFFB74D); // Light Orange
  static const Color textDark = Color(0xFF333333); // Dark Grey for text
  static const Color textMedium = Color(0xFF666666); // Medium Grey for secondary text
  static const Color textLight = Color(0xFF999999); // Light Grey for tertiary text
  static const Color cardBackground = Color(0xFFFFFFFF); // White for card backgrounds
  static const Color dividerColor = Color(0xFFE0E0E0); // Light Grey for dividers

  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: textDark,
      );

  static TextStyle get subheadingStyle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: textDark,
      );

  static TextStyle get bodyStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: textDark,
      );

  static TextStyle get balanceNumberStyle => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: textDark,
      );

  static TextStyle get balanceLabelStyle => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textMedium,
      );

  static TextStyle get buttonTextStyle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: Colors.white,
      );

  static TextStyle get statNumberStyle => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: textDark,
      );

  static TextStyle get statLabelStyle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textMedium,
      );

  static TextStyle get cardTitleStyle => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: textDark,
      );
  
  static TextStyle get navLabelStyle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textMedium,
      );

  static TextStyle get chartLabelStyle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: textLight,
      );

  // Spacing and dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0; // More rounded corners as seen in screenshots
  static const double largeBorderRadius = 20.0;
  static const double smallBorderRadius = 15.0;
  static const double defaultElevation = 2.0;
  static const double largeElevation = 4.0;
  static const double buttonHeight = 56.0;
  static const double appBarHeight = 120.0;
  
  // Banking Card dimensions
  static const double bankingCardHeight = 200.0;
  static const double bankingCardWidth = 340.0;
  static const double bankingCardRadius = 16.0;


  // Update where text styles are used in the Banking Stats Card
  static Widget buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: statLabelStyle),
                const SizedBox(height: 4),
                Text(value, style: statNumberStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        textStyle: buttonTextStyle,
      );

/// Caption style (12px, Regular)
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: textLight,
    height: 1.4,
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 2),
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        textStyle: buttonTextStyle.copyWith(color: primaryColor),
      );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: backgroundLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: secondaryButtonStyle,
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLight,
        selectedLabelStyle: navLabelStyle.copyWith(color: primaryColor),
        unselectedLabelStyle: navLabelStyle,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
  
  // Dark Theme - Optional but useful if you plan to add dark mode
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: Color(0xFF1E1E1E),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: navLabelStyle.copyWith(color: primaryColor),
        unselectedLabelStyle: navLabelStyle,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
    );
  }
}