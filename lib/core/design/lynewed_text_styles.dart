import 'package:flutter/material.dart';
import 'lynewed_colors.dart';

/// Lynewed Typography System - Refined Visual Hierarchy
/// 
/// DESIGN PRINCIPLES:
/// - Font weights are INTENTIONALLY LIGHT (w400-w500 max) for elegance
/// - Bold (w600+) should be used sparingly, only for CTAs
/// - All values extracted from Profile page (reference of elegance)
/// 
/// See /docs/App/DESIGN_SYSTEM.md for complete usage guide
class LynewedTextStyles {
  LynewedTextStyles._();

  // ============================================================
  // FONT FAMILY
  // ============================================================
  static const String fontFamily = 'Haas Grot Text Trial';

  // ============================================================
  // DISPLAY STYLES (Hero / Splash screens only)
  // ============================================================
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48.0,
    fontWeight: FontWeight.w500,
    color: LynewedColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.0,
    fontWeight: FontWeight.w500,
    color: LynewedColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w500,
    color: LynewedColors.textPrimary,
    height: 1.2,
  );

  // ============================================================
  // HEADLINE STYLES (Page titles, major sections)
  // ============================================================
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w500,
    color: LynewedColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    color: LynewedColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: LynewedColors.textPrimary,
    height: 1.3,
  );

  // ============================================================
  // TITLE STYLES (Sheet headers, dialog titles)
  // Extracted from Profile page: 18px, w500
  // ============================================================
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: LynewedColors.textPrimary,
    height: 1.3,
    letterSpacing: 0.0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: LynewedColors.textPrimary,
    height: 1.35,
    letterSpacing: 0.0,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: LynewedColors.textPrimary,
    height: 1.35,
    letterSpacing: 0.0,
  );

  // ============================================================
  // BODY STYLES (Content, paragraphs, list items)
  // bodyMedium = default text (14px, w400)
  // ============================================================
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: LynewedColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: LynewedColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    color: LynewedColors.textPrimary,
    height: 1.45,
    letterSpacing: 0.0,
  );

  // ============================================================
  // LABEL STYLES (Captions, hints, secondary info)
  // ============================================================
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: LynewedColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.0,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    color: LynewedColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.0,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    color: LynewedColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.0,
  );

  // ============================================================
  // SEMANTIC STYLES (Use these instead of raw styles)
  // ============================================================
  
  /// Sheet header title (e.g., "Create Alert", "Edit Wedding")
  /// 18px, w500 - matches Profile page header
  static const TextStyle sheetTitle = titleLarge;
  
  /// Form section title (e.g., "Alert Type", "Wedding Date *")
  /// 16px, w500 - matches Profile section headers
  static const TextStyle sectionTitle = titleMedium;
  
  /// List item text (e.g., menu items, settings rows)
  /// 14px, w400 - matches Profile list items
  static const TextStyle listItem = bodyMedium;
  
  /// Input hint text
  static TextStyle get inputHint => bodyMedium.copyWith(
    color: LynewedColors.gray300,
  );
  
  /// Button text (primary action)
  /// Slightly bolder for CTA emphasis
  static TextStyle get buttonPrimary => bodyLarge.copyWith(
    fontWeight: FontWeight.w500,
    color: LynewedColors.textOnPrimary,
  );
  
  /// Chip text (filter chips, tags)
  static const TextStyle chipText = bodyMedium;

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
