import 'package:flutter/material.dart';
import 'lynewed_colors.dart';
import 'lynewed_text_styles.dart';
import 'lynewed_borders.dart';
import 'lynewed_component_styles.dart';

/// Lynewed App Theme - Complete ThemeData replacement
/// See /docs/App/DESIGN_SYSTEM.md for complete usage guide
/// Provides unified theme for the entire application
class LynewedAppTheme {
  LynewedAppTheme._();

  /// Get light theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: LynewedColors.primary,
        onPrimary: LynewedColors.textOnPrimary,
        secondary: LynewedColors.border,
        onSecondary: LynewedColors.textPrimary,
        error: LynewedColors.error,
        onError: LynewedColors.textOnPrimary,
        surface: LynewedColors.background,
        onSurface: LynewedColors.textPrimary,
      ),

      // Typography
      textTheme: const TextTheme(
        // Display styles
        displayLarge: LynewedTextStyles.displayLarge,
        displayMedium: LynewedTextStyles.displayMedium,
        displaySmall: LynewedTextStyles.displaySmall,
        
        // Headline styles
        headlineLarge: LynewedTextStyles.headlineLarge,
        headlineMedium: LynewedTextStyles.headlineMedium,
        headlineSmall: LynewedTextStyles.headlineSmall,
        
        // Title styles
        titleLarge: LynewedTextStyles.titleLarge,
        titleMedium: LynewedTextStyles.titleMedium,
        titleSmall: LynewedTextStyles.titleSmall,
        
        // Body styles
        bodyLarge: LynewedTextStyles.bodyLarge,
        bodyMedium: LynewedTextStyles.bodyMedium,
        bodySmall: LynewedTextStyles.bodySmall,
        
        // Label styles
        labelLarge: LynewedTextStyles.labelLarge,
        labelMedium: LynewedTextStyles.labelMedium,
        labelSmall: LynewedTextStyles.labelSmall,
      ),

      // AppBar Theme
      appBarTheme: LynewedComponentStyles.appBarTheme(),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: LynewedComponentStyles.primaryButton(),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: LynewedComponentStyles.secondaryButton(),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: LynewedComponentStyles.textButton(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: LynewedTextStyles.labelSmall,
        labelStyle: LynewedTextStyles.labelMedium,
        filled: true,
        fillColor: LynewedColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        border: LynewedBorders.inputBorder(),
        enabledBorder: LynewedBorders.inputBorder(),
        focusedBorder: LynewedBorders.inputFocusedBorder(),
        errorBorder: LynewedBorders.inputErrorBorder(),
        focusedErrorBorder: LynewedBorders.inputErrorBorder(),
        errorStyle: LynewedTextStyles.labelSmall.copyWith(
          color: LynewedColors.error,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: LynewedColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: LynewedBorders.borderRadiusNone,
          side: const BorderSide(color: LynewedColors.border, width: 1.0),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: LynewedComponentStyles.bottomNavigationBarTheme(),

      // List Tile Theme
      listTileTheme: LynewedComponentStyles.listTileTheme(),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: LynewedColors.border,
        thickness: 1.0,
        space: 1.0,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: LynewedColors.primary,
        size: 24.0,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: LynewedColors.primary,
        linearTrackColor: LynewedColors.border,
        circularTrackColor: LynewedColors.border,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: LynewedColors.primary,
        foregroundColor: LynewedColors.textOnPrimary,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: LynewedBorders.borderRadiusNone,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: LynewedColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(LynewedBorders.xl),
            topRight: Radius.circular(LynewedBorders.xl),
          ),
        ),
        elevation: 8.0,
        modalElevation: 8.0,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: LynewedColors.background,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LynewedBorders.lg),
        ),
        titleTextStyle: LynewedTextStyles.titleMedium,
        contentTextStyle: LynewedTextStyles.bodyMedium,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LynewedColors.textPrimary,
        contentTextStyle: LynewedTextStyles.bodyMedium.copyWith(
          color: LynewedColors.textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LynewedBorders.sm),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4.0,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: LynewedColors.surface,
        brightness: Brightness.light,
        labelStyle: LynewedTextStyles.labelMedium,
        secondaryLabelStyle: LynewedTextStyles.labelMedium.copyWith(
          color: LynewedColors.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LynewedBorders.sm),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: LynewedColors.primary,
        unselectedLabelColor: LynewedColors.textSecondary,
        labelStyle: LynewedTextStyles.labelMedium,
        unselectedLabelStyle: LynewedTextStyles.labelMedium,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: LynewedColors.primary, width: 2.0),
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return LynewedColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(LynewedColors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LynewedBorders.sm),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return LynewedColors.primary;
          }
          return LynewedColors.gray300;
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return LynewedColors.primary;
          }
          return LynewedColors.gray300;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return LynewedColors.primary.withValues(alpha: 0.5);
          }
          return LynewedColors.gray200;
        }),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: LynewedColors.background,

      // Splash Colors
      splashColor: LynewedColors.transparent,
      highlightColor: LynewedColors.transparent,
      focusColor: LynewedColors.transparent,
      hoverColor: LynewedColors.transparent,

      // Cursor Color
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: LynewedColors.primary,
        selectionColor: LynewedColors.gray300,
        selectionHandleColor: LynewedColors.primary,
      ),
    );
  }

  /// Get dark theme (not used in Lynewed, but available for completeness)
  static ThemeData get darkTheme {
    // Lynewed doesn't use dark theme, but this is included for completeness
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LynewedColors.primary,
    );
  }
}

