import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/colors.dart';
import 'package:grad_store_app/core/theme/typography.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  //
  // Light theme
  //
  static final light = ThemeData(
    fontFamily: GoogleFonts.montserrat().fontFamily,
  ).copyWith(
    extensions: [appColors, AppTypography.typography],
    colorScheme: ColorScheme.fromSeed(
      seedColor: appColors.primary,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: appColors.white,
      titleTextStyle: AppTypography.typography.bodyLarge.copyWith(
        color: appColors.black,
        fontSize: 17,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: appColors.white,
      labelTextStyle: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
        final Color color =
            states.contains(WidgetState.selected)
                ? appColors.primary
                : appColors.black;
        return TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        );
      }),
    ),
    scaffoldBackgroundColor: appColors.white,
  );

  static const appColors = AppColors(
    
  // Primary (Petrol Green)
  primary: Color(0xFF0F766E),
  primaryShade1: Color(0xFFCCFBF1),
  primaryShade2: Color(0xFF99F6E4),
  primaryShade3: Color(0xFF5EEAD4),
  primaryShade4: Color(0xFF2DD4BF),
  primaryShade5: Color(0xFF14B8A6),
  primaryTint1: Color(0xFF115E59),
  primaryTint2: Color(0xFF134E4A),
  primaryTint3: Color(0xFF042F2E),
  primaryTint4: Color(0xFF022C22),
  primaryTint5: Color(0xFF021C1A),

  // Secondary (Soft Neutral)
  secondary: Color(0xFFE5E7EB),
  secondaryShade1: Color(0xFFF3F4F6),
  secondaryShade2: Color(0xFFE5E7EB),
  secondaryShade3: Color(0xFFD1D5DB),
  secondaryShade4: Color(0xFF9CA3AF),
  secondaryShade5: Color.fromARGB(255, 215, 219, 228),

    // Neutral
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    gray: Color(0xFFEDEDED),
    gray2: Color(0xFFB5B5B5),
    gray4: Color(0xFF757575),

  // Status
  error: Color(0xFFDC2626),
  errorLight: Color(0xFFFEE2E2),
  errorExtraLight: Color(0xFFFFF1F2),
  success: Color(0xFF16A34A),
  successLight: Color(0xFFBBF7D0),
  warning: Color(0xFFF59E0B),
  warningLight: Color(0xFFFEF3C7), 
  secondaryTint1: Color(0xFFE5E5E5),
   secondaryTint2: Color(0xFFD4D4D4),
    secondaryTint3: Color(0xFFB3B3B3), 
    secondaryTint4: Color(0xFF929292), 
    secondaryTint5: Color(0xFF717171),
     brown: Color(0xFF6D4C41),
      brownLight: Color(0xFFD7CCC8), 
      brownExtraLight: Color(0xFFEFEBE9),
);

  //
  // Dark theme
  //
  static final dark = ThemeData.dark().copyWith(
    extensions: [appColors, AppTypography.typography],
    textTheme: TextTheme(
      bodyLarge: AppTypography.typography.bodyLarge.copyWith(
        color: Colors.white,
      ),
      bodyMedium: AppTypography.typography.bodyMedium.copyWith(
        color: Colors.white,
      ),
      bodySmall: AppTypography.typography.bodySmall.copyWith(
        color: Colors.white,
      ),
      displayLarge: AppTypography.typography.displayLarge.copyWith(
        color: Colors.white,
      ),
      displayMedium: AppTypography.typography.displayMedium.copyWith(
        color: Colors.white,
      ),
      displaySmall: AppTypography.typography.displaySmall.copyWith(
        color: Colors.white,
      ),
      labelLarge: AppTypography.typography.labelLarge.copyWith(
        color: Colors.white,
      ),
      labelMedium: AppTypography.typography.labelMedium.copyWith(
        color: Colors.white,
      ),
      labelSmall: AppTypography.typography.labelSmall.copyWith(
        color: Colors.white,
      ),
      headlineLarge: AppTypography.typography.headlineLarge.copyWith(
        color: Colors.white,
      ),
      headlineMedium: AppTypography.typography.headlineMedium.copyWith(
        color: Colors.white,
      ),
      headlineSmall: AppTypography.typography.headlineSmall.copyWith(
        color: Colors.white,
      ),
      titleLarge: AppTypography.typography.titleLarge.copyWith(
        color: Colors.white,
      ),
      titleMedium: AppTypography.typography.titleMedium.copyWith(
        color: Colors.white,
      ),
      titleSmall: AppTypography.typography.titleSmall.copyWith(
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: appColors.primary,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: appColors.black,
      titleTextStyle: AppTypography.typography.bodyLarge.copyWith(
        color: appColors.white,
        fontSize: 17,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: appColors.black,
      labelTextStyle: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
        final Color color =
            states.contains(WidgetState.selected)
                ? appColors.primary
                : appColors.white;
        return TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        );
      }),
    ),
    scaffoldBackgroundColor: appColors.black,
  );
}

extension ColorThemeExtension on ThemeData {
  /// Usage example: Theme.of(context).appColors;
  AppColors get appColors => extension<AppColors>()!;
}

extension FontThemeExtension on ThemeData {
  /// Usage example: Theme.of(context).appTypography;
  AppTypography get appTypography => extension<AppTypography>()!;
}

extension ThemeGetter on BuildContext {
  // Usage example: `context.theme`
  ThemeData get theme => Theme.of(this);
}
