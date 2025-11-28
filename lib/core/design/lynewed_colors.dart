import 'package:flutter/material.dart';

/// Lynewed Color System - Based on MVP FlutterFlow analysis
/// See /docs/App/DESIGN_SYSTEM.md for complete usage guide
/// All colors extracted from actual usage in the app
class LynewedColors {
  LynewedColors._();

  // Primary Colors (validated by Thierry)
  static const Color primary = Color(0xFF000000);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFEBEBEB);
  static const Color textPrimary = Color(0xFF141414);
  static const Color textSecondary = Color(0xFF545454);

  // Functional Colors
  static const Color success = Color(0xFF249689);
  static const Color warning = Color(0xFFF9CF58);
  static const Color error = Color(0xFFFF5963);
  static const Color info = Color(0xFFFFFFFF);

  // Neutral Colors
  static const Color gray100 = Color(0xFF727272);
  static const Color gray200 = Color(0xFFD9D9D9);
  static const Color gray300 = Color(0xFFBFBFBF);
  static const Color transparent = Colors.transparent;

  // Special Colors (for specific contexts)
  static const Color textOnDark = Colors.white;
  static const Color textOnPrimary = Colors.white;
  static const Color splashColor = Colors.transparent;
  static const Color focusColor = Colors.transparent;
  static const Color hoverColor = Colors.transparent;
  static const Color highlightColor = Colors.transparent;

  // Border Colors
  static const Color borderColor = Colors.transparent;
  static const Color inputBorderColor = Color(0xFFEBEBEB);
}

/// Color Utilities
class LynewedColorUtils {
  LynewedColorUtils._();

  /// Get text color based on background
  static Color getTextOnBackground(Color background) {
    return background.computeLuminance() > 0.5 
        ? LynewedColors.textPrimary 
        : LynewedColors.textOnDark;
  }

  /// Get opacity variant of color
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
