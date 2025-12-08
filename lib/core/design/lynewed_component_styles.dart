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

  // ============================================================
  // CHIP STYLES - Standard Design System (4px radius)
  // ============================================================
  
  /// Standard chip border radius (4px for elegance)
  static const double chipBorderRadius = 4.0;
  
  /// Standard chip padding
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 8.0,
    vertical: 6.0,
  );

  /// Chip decoration for custom Container-based chips
  static BoxDecoration chipDecoration({
    bool selected = false,
    Color? backgroundColor,
    Color? selectedBackgroundColor,
  }) {
    return BoxDecoration(
      color: selected 
          ? (selectedBackgroundColor ?? LynewedColors.primary)
          : (backgroundColor ?? LynewedColors.gray200),
      borderRadius: BorderRadius.circular(chipBorderRadius),
    );
  }

  /// Chip text style
  static TextStyle chipTextStyle({
    bool selected = false,
    Color? color,
    Color? selectedColor,
  }) {
    return LynewedTextStyles.chipText.copyWith(
      color: selected 
          ? (selectedColor ?? LynewedColors.textOnPrimary)
          : (color ?? LynewedColors.textPrimary),
      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
    );
  }

  /// Standard FilterChip with Lynewed styling
  /// Usage: Use this for all filter chips in the app
  static FilterChip buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: chipTextStyle(selected: selected),
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      backgroundColor: LynewedColors.gray200,
      selectedColor: LynewedColors.primary,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipBorderRadius),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: chipPadding,
    );
  }

  /// ChipThemeData for ThemeData integration
  static ChipThemeData chipTheme({
    Color? backgroundColor,
    Color? selectedColor,
    Color? labelColor,
  }) {
    return ChipThemeData(
      backgroundColor: backgroundColor ?? LynewedColors.gray200,
      selectedColor: selectedColor ?? LynewedColors.primary,
      labelStyle: LynewedTextStyles.chipText.copyWith(
        color: labelColor ?? LynewedColors.textPrimary,
      ),
      padding: chipPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipBorderRadius),
      ),
      showCheckmark: false,
      side: BorderSide.none,
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

  // ============================================================
  // FORM FIELD STYLES - Standardized inputs
  // ============================================================
  
  /// Standard border radius for form inputs (4px for elegance)
  static const double inputBorderRadius = 4.0;
  
  /// Standard form field InputDecoration
  /// Usage: TextField(decoration: LynewedComponentStyles.formInputDecoration(...))
  static InputDecoration formInputDecoration({
    String? hintText,
    String? labelText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool hasError = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: LynewedTextStyles.inputHint,
      labelStyle: LynewedTextStyles.bodyMedium.copyWith(
        color: LynewedColors.textSecondary,
      ),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 14.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: LynewedColors.gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: LynewedColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: LynewedColors.textPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: LynewedColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: LynewedColors.error, width: 1.5),
      ),
    );
  }

  /// Date picker / Selectable field decoration
  static BoxDecoration selectableFieldDecoration({
    bool hasValue = false,
    bool hasError = false,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: hasError 
            ? LynewedColors.error 
            : LynewedColors.gray200,
      ),
      borderRadius: BorderRadius.circular(inputBorderRadius),
    );
  }

  // ============================================================
  // SHEET STYLES - Bottom sheets, modals
  // ============================================================
  
  /// Sheet header container decoration
  static BoxDecoration sheetHeaderDecoration() {
    return const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: LynewedColors.gray200, width: 1),
      ),
    );
  }
  
  /// Sheet header padding (matches LynewedSheet: 20px horizontal, 20px top, 12px bottom)
  static const EdgeInsets sheetHeaderPadding = EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0);
  
  /// Sheet content padding
  static const EdgeInsets sheetContentPadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 16.0,
  );
  
  /// Gap between form sections in sheets (30px - from wedding_create_sheet reference)
  static const double formSectionGap = 30.0;
  
  /// Gap between label and field (10px - from wedding_create_sheet reference)
  static const double labelFieldGap = 10.0;

  // ============================================================
  // BACK BUTTON STYLES - Standard navigation back button
  // ============================================================
  
  /// Standard back button icon size (28x28 for better visibility)
  static const double backButtonIconSize = 28.0;
  
  /// Standard back button tap target size (44x44 for accessibility)
  static const double backButtonTapTargetSize = 44.0;
  
  /// Standard back button widget
  /// Usage: LynewedComponentStyles.backButton(context)
  static Widget backButton(
    BuildContext context, {
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: backButtonTapTargetSize,
        height: backButtonTapTargetSize,
        child: Center(
          child: Icon(
            Icons.chevron_left,
            size: backButtonIconSize,
            color: iconColor ?? LynewedColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR BANNER STYLES
  // ============================================================
  
  /// Error banner decoration
  static BoxDecoration errorBannerDecoration() {
    return BoxDecoration(
      color: LynewedColors.error.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(inputBorderRadius),
      border: Border.all(
        color: LynewedColors.error.withValues(alpha: 0.3),
      ),
    );
  }

  // ============================================================
  // SLIDER STYLES
  // ============================================================
  
  /// Slider theme data
  static SliderThemeData sliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: LynewedColors.primary,
      inactiveTrackColor: LynewedColors.gray200,
      thumbColor: LynewedColors.primary,
      overlayColor: LynewedColors.primary.withValues(alpha: 0.12),
      trackHeight: 3.0,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
    );
  }
}
