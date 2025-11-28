import 'package:flutter/material.dart';
import 'lynewed_colors.dart';
import 'lynewed_text_styles.dart';
import 'lynewed_spacing.dart';
import 'lynewed_borders.dart';

/// Lynewed Component Styles - Based on MVP FlutterFlow analysis
/// See /docs/App/DESIGN_SYSTEM.md for complete usage guide
/// Common component styles used throughout the application
class LynewedComponentStyles {
  LynewedComponentStyles._();

  // Button Styles
  static ButtonStyle primaryButton({
    Color? backgroundColor,
    Color? foregroundColor,
    double? height,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? LynewedColors.primary,
      foregroundColor: foregroundColor ?? LynewedColors.textOnPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: LynewedBorders.borderRadiusNone,
      ),
      minimumSize: Size(0, height ?? LynewedSpacing.buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
    );
  }

  static ButtonStyle secondaryButton({
    Color? backgroundColor,
    Color? foregroundColor,
    double? height,
  }) {
    return OutlinedButton.styleFrom(
      backgroundColor: backgroundColor ?? LynewedColors.background,
      foregroundColor: foregroundColor ?? LynewedColors.primary,
      side: const BorderSide(color: LynewedColors.primary, width: 1.0),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: LynewedBorders.borderRadiusNone,
      ),
      minimumSize: Size(0, height ?? LynewedSpacing.buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
    );
  }

  static ButtonStyle textButton({
    Color? foregroundColor,
    double? height,
  }) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor ?? LynewedColors.primary,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: LynewedBorders.borderRadiusNone,
      ),
      minimumSize: Size(0, height ?? LynewedSpacing.buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }

  // Input Decoration Styles
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool error = false,
    bool focused = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: LynewedTextStyles.labelSmall,
      labelStyle: LynewedTextStyles.labelMedium,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
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
    );
  }

  // Card Styles
  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double? borderRadius,
    double? elevation,
  }) {
    return BoxDecoration(
      color: color ?? LynewedColors.background,
      border: Border.all(
        color: borderColor ?? LynewedColors.border,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(borderRadius ?? LynewedBorders.none),
      boxShadow: elevation != null && elevation > 0
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: elevation,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration surfaceDecoration({
    Color? color,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? LynewedColors.surface,
      borderRadius: BorderRadius.circular(borderRadius ?? LynewedBorders.none),
    );
  }

  // Sheet Styles
  static BoxDecoration bottomSheetDecoration({
    Color? color,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? LynewedColors.background,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadius ?? LynewedBorders.xl),
        topRight: Radius.circular(borderRadius ?? LynewedBorders.xl),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 10.0,
          offset: Offset(0, -2),
        ),
      ],
    );
  }

  // Avatar Styles
  static BoxDecoration avatarDecoration({
    Color? borderColor,
    double size = 48.0,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: borderColor ?? LynewedColors.border,
        width: 2.0,
      ),
    );
  }

  // AppBar Styles
  static AppBarTheme appBarTheme({
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    return AppBarTheme(
      backgroundColor: backgroundColor ?? LynewedColors.background,
      foregroundColor: foregroundColor ?? LynewedColors.primary,
      elevation: elevation ?? 0,
      centerTitle: true,
      titleTextStyle: LynewedTextStyles.titleMedium.copyWith(
        color: foregroundColor ?? LynewedColors.primary,
      ),
      iconTheme: IconThemeData(
        color: foregroundColor ?? LynewedColors.primary,
        size: 24.0,
      ),
    );
  }

  // Bottom Navigation Bar Styles
  static BottomNavigationBarThemeData bottomNavigationBarTheme({
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: backgroundColor ?? LynewedColors.background,
      selectedItemColor: selectedItemColor ?? LynewedColors.primary,
      unselectedItemColor: unselectedItemColor ?? LynewedColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: LynewedTextStyles.labelSmall,
      unselectedLabelStyle: LynewedTextStyles.labelSmall,
    );
  }

  // Loading Indicator Styles
  static Color progressIndicatorColor({Color? color}) {
    return color ?? LynewedColors.primary;
  }

  static double progressIndicatorSize({double? size}) {
    return size ?? 24.0;
  }

  // Divider Styles
  static Divider divider({
    Color? color,
    double? thickness,
    double? height,
  }) {
    return Divider(
      color: color ?? LynewedColors.border,
      thickness: thickness ?? 1.0,
      height: height ?? 1.0,
    );
  }

  // List Tile Styles
  static ListTileThemeData listTileTheme({
    Color? tileColor,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTileThemeData(
      tileColor: tileColor ?? LynewedColors.background,
      textColor: textColor ?? LynewedColors.textPrimary,
      iconColor: iconColor ?? LynewedColors.primary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: LynewedSpacing.xl,
        vertical: LynewedSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: LynewedBorders.borderRadiusNone,
      ),
    );
  }
}
