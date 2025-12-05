import 'package:flutter/material.dart';
import 'lynewed_colors.dart';
import 'lynewed_text_styles.dart';

/// Lynewed Design System - Main entry point
/// See /docs/App/DESIGN_SYSTEM.md for complete usage guide
/// Mirrors FlutterFlowTheme API for seamless migration
class LynewedTheme {
  const LynewedTheme._();

  static const LynewedTheme _instance = LynewedTheme._();

  /// Get the current theme from context
  static LynewedTheme of(BuildContext context) {
    return _instance;
  }

  // Color properties (mirroring FlutterFlowTheme)
  Color get primary => LynewedColors.primary;
  Color get secondary => LynewedColors.border;
  Color get tertiary => LynewedColors.gray200;
  Color get alternate => LynewedColors.gray100;
  Color get primaryText => LynewedColors.textPrimary;
  Color get secondaryText => LynewedColors.textSecondary;
  Color get primaryBackground => LynewedColors.background;
  Color get secondaryBackground => LynewedColors.surface;
  Color get accent1 => LynewedColors.gray300;
  Color get accent2 => LynewedColors.error;
  Color get accent3 => LynewedColors.warning.withValues(alpha: 0.3);
  Color get accent4 => LynewedColors.background.withValues(alpha: 0.8);
  Color get success => LynewedColors.success;
  Color get warning => LynewedColors.warning;
  Color get error => LynewedColors.error;
  Color get info => LynewedColors.info;
  Color get backgroundIcons => LynewedColors.gray300.withValues(alpha: 0.2);

  // Typography properties (mirroring FlutterFlowTheme)
  _LynewedTypography get typography => _LynewedTypography(this);

  // Deprecated properties (for compatibility)
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  // Typography shortcuts (mirroring FlutterFlowTheme)
  TextStyle get displayLarge => LynewedTextStyles.displayLarge;
  TextStyle get displayMedium => LynewedTextStyles.displayMedium;
  TextStyle get displaySmall => LynewedTextStyles.displaySmall;
  TextStyle get headlineLarge => LynewedTextStyles.headlineLarge;
  TextStyle get headlineMedium => LynewedTextStyles.headlineMedium;
  TextStyle get headlineSmall => LynewedTextStyles.headlineSmall;
  TextStyle get titleLarge => LynewedTextStyles.titleLarge;
  TextStyle get titleMedium => LynewedTextStyles.titleMedium;
  TextStyle get titleSmall => LynewedTextStyles.titleSmall;
  TextStyle get bodyLarge => LynewedTextStyles.bodyLarge;
  TextStyle get bodyMedium => LynewedTextStyles.bodyMedium;
  TextStyle get bodySmall => LynewedTextStyles.bodySmall;
  TextStyle get labelLarge => LynewedTextStyles.labelLarge;
  TextStyle get labelMedium => LynewedTextStyles.labelMedium;
  TextStyle get labelSmall => LynewedTextStyles.labelSmall;
  // TextStyle get caption => LynewedTextStyles.caption; // Removed - not used in new system

  // Legacy typography properties (for compatibility)
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => displaySmall;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => headlineMedium;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => headlineSmall;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => titleMedium;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => titleSmall;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => bodyMedium;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => bodySmall;
}

/// Typography class mirroring FlutterFlowTheme structure
/// Custom typography class (not extending Material's Typography)
class _LynewedTypography {
  _LynewedTypography(this.theme);

  final LynewedTheme theme;

  TextStyle get displayLarge => LynewedTextStyles.displayLarge;
  TextStyle get displayMedium => LynewedTextStyles.displayMedium;
  TextStyle get displaySmall => LynewedTextStyles.displaySmall;
  TextStyle get headlineLarge => LynewedTextStyles.headlineLarge;
  TextStyle get headlineMedium => LynewedTextStyles.headlineMedium;
  TextStyle get headlineSmall => LynewedTextStyles.headlineSmall;
  TextStyle get titleLarge => LynewedTextStyles.titleLarge;
  TextStyle get titleMedium => LynewedTextStyles.titleMedium;
  TextStyle get titleSmall => LynewedTextStyles.titleSmall;
  TextStyle get labelLarge => LynewedTextStyles.labelLarge;
  TextStyle get labelMedium => LynewedTextStyles.labelMedium;
  TextStyle get labelSmall => LynewedTextStyles.labelSmall;
  TextStyle get bodyLarge => LynewedTextStyles.bodyLarge;
  TextStyle get bodyMedium => LynewedTextStyles.bodyMedium;
  TextStyle get bodySmall => LynewedTextStyles.bodySmall;
}

/// Design System Utilities
class LynewedDesignSystem {
  LynewedDesignSystem._();

  /// Get responsive value based on screen width
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024 && desktop != null) return desktop;
    if (width >= 768 && tablet != null) return tablet;
    return mobile;
  }

  /// Get text color based on background
  static Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 
        ? LynewedColors.textPrimary 
        : LynewedColors.textOnDark;
  }

  /// Create custom text style with design system colors
  static TextStyle createTextStyle({
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

  /// Get spacing value based on context
  static double getSpacing(BuildContext context, double baseValue) {
    // For now, return base value - can be enhanced for responsive design
    return baseValue;
  }

  /// Apply safe area padding
  static EdgeInsets applySafeArea(BuildContext context, EdgeInsets padding) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    
    return EdgeInsets.only(
      top: padding.top + topPadding,
      left: padding.left,
      right: padding.right,
      bottom: padding.bottom,
    );
  }

  /// Check if theme is dark (always false for Lynewed)
  static bool isDark(BuildContext context) {
    return false; // Lynewed uses light theme only
  }

  /// Get theme brightness
  static Brightness getBrightness(BuildContext context) {
    return Brightness.light;
  }
}

/// Extension methods for easy theme access
extension LynewedThemeExtension on BuildContext {
  /// Get LynewedTheme - convenient shorthand for LynewedTheme.of(context)
  LynewedTheme get lynewedTheme => LynewedTheme.of(this);
}
