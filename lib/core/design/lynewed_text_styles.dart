import 'package:flutter/material.dart';
import 'lynewed_colors.dart';

/// Lynewed Typography System - Based on MVP FlutterFlow analysis
/// See /docs/App/DESIGN_SYSTEM.md for complete usage guide
/// All font sizes and weights extracted from actual usage
class LynewedTextStyles {
  LynewedTextStyles._();

  // Font Family - Unified across all styles
  static const String fontFamily = 'Haas Grot Text Trial';

  // Display Styles (Hero titles)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 64.0,
    fontWeight: FontWeight.w600,
    color: LynewedColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44.0,
    fontWeight: FontWeight.w600,
    color: LynewedColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.0,
    fontWeight: FontWeight.w600,
    color: LynewedColors.textPrimary,
    height: 1.2,
  );

  // Headline Styles (Section titles)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
    color: LynewedColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    color: LynewedColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: LynewedColors.textPrimary,
    height: 1.3,
  );

  // Title Styles (Component titles)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: LynewedColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: LynewedColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: LynewedColors.textPrimary,
    height: 1.3,
  );

  // Body Styles (Content text)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: LynewedColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: LynewedColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.normal,
    color: LynewedColors.textPrimary,
    height: 1.4,
  );

  // Label Styles (UI elements)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: LynewedColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.normal,
    color: LynewedColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    color: LynewedColors.textSecondary,
    height: 1.4,
  );

  // Caption Style (Smallest text)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.0,
    fontWeight: FontWeight.normal,
    color: LynewedColors.textSecondary,
    height: 1.4,
  );

  // Special Color Variants
  static TextStyle textOnDark(TextStyle baseStyle) {
    return baseStyle.copyWith(color: LynewedColors.textOnDark);
  }

  static TextStyle textSecondary(TextStyle baseStyle) {
    return baseStyle.copyWith(color: LynewedColors.textSecondary);
  }

  static TextStyle textOnPrimary(TextStyle baseStyle) {
    return baseStyle.copyWith(color: LynewedColors.textOnPrimary);
  }
}

/// Typography Utilities
class LynewedTextUtils {
  LynewedTextUtils._();

  /// Get responsive font size based on screen width
  static double getResponsiveFontSize(
    double baseSize, {
    double minSize = 12.0,
    double maxSize = 64.0,
  }) {
    // For now, return base size - can be enhanced later for responsive design
    return baseSize.clamp(minSize, maxSize);
  }

  /// Create custom text style with overrides
  static TextStyle customStyle({
    TextStyle? base,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    TextStyle style = base ?? LynewedTextStyles.bodyMedium;
    return style.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}
