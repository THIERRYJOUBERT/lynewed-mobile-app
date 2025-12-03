import 'package:flutter/widgets.dart';

/// Lynewed Spacing System - Refined Visual Hierarchy
/// 
/// DESIGN PRINCIPLES:
/// - 4px baseline grid
/// - Consistent padding across sheets and forms
/// - Values extracted from Profile page (reference of elegance)
/// 
/// See /docs/App/DESIGN_SYSTEM.md for complete usage guide
class LynewedSpacing {
  LynewedSpacing._();

  // ============================================================
  // BASE SPACING SCALE (4px baseline)
  // ============================================================
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // ============================================================
  // SAFE AREA SPACING (Mobile status bars, navigation)
  // ============================================================
  static const double safeTop = 70.0;
  static const double safeTopLarge = 84.0;
  static const double safeTopXL = 110.0;
  static const double safeTopXXL = 130.0;

  // ============================================================
  // COMPONENT HEIGHTS
  // ============================================================
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const double iconSize = 18.0;        // Standard icon size (from Profile)
  static const double iconSizeLarge = 24.0;   // Larger icons

  // ============================================================
  // SHEET LAYOUT - Extracted from Profile page
  // ============================================================
  
  /// Horizontal padding for sheet content (matches Profile: 20px)
  static const double sheetHorizontalPadding = 20.0;
  
  /// Vertical padding for sheet content
  static const double sheetVerticalPadding = 16.0;
  
  /// Sheet header vertical padding
  static const double sheetHeaderVerticalPadding = 12.0;
  
  /// Gap between form sections (extracted from Profile: 14-20px)
  static const double formSectionGap = 20.0;
  
  /// Gap between label and input field
  static const double labelFieldGap = 10.0;
  
  /// Gap between items in a list (extracted from Profile: 14px)
  static const double listItemGap = 14.0;
  
  /// Separator height
  static const double separatorHeight = 1.0;

  // ============================================================
  // CHAT MESSAGE SPACING
  // ============================================================
  
  /// Spacing between messages from the same user
  static const double chatMessageSameUser = 8.0;
  
  /// Spacing between messages from different users
  static const double chatMessageDifferentUser = 30.0;

  // ============================================================
  // FORM LIST ITEM PADDING (Profile-style rows)
  // ============================================================
  
  /// Vertical padding for list items (Profile: 12px top/bottom)
  static const double listItemVerticalPadding = 12.0;

  // Legacy aliases
  static const double cardPadding = xl;
  static const double sectionSpacing = xxxl;

  // EdgeInsets helpers
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);
  static const EdgeInsets allXxxl = EdgeInsets.all(xxxl);

  // Symmetric padding
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);
  static const EdgeInsets horizontalXxxl = EdgeInsets.symmetric(horizontal: xxxl);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  // Common padding patterns from MVP
  static const EdgeInsetsDirectional pageContent = EdgeInsetsDirectional.fromSTEB(20.0, 70.0, 20.0, 0.0);
  static const EdgeInsetsDirectional pageContentLarge = EdgeInsetsDirectional.fromSTEB(32.0, 70.0, 32.0, 40.0);
  static const EdgeInsetsDirectional pageContentXL = EdgeInsetsDirectional.fromSTEB(20.0, 110.0, 20.0, 84.0);
  static const EdgeInsetsDirectional pageContentXXL = EdgeInsetsDirectional.fromSTEB(20.0, 130.0, 20.0, 84.0);
  static const EdgeInsetsDirectional formSection = EdgeInsetsDirectional.fromSTEB(32.0, 70.0, 32.0, 40.0);
  static const EdgeInsetsDirectional cardPaddingHorizontal = EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0);

  // Spacing utilities
  static EdgeInsets horizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets only({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => EdgeInsets.only(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );

  // Responsive spacing helpers
  static EdgeInsets responsiveHorizontal({
    required BuildContext context,
    double mobile = 20.0,
    double tablet = 32.0,
  }) {
    final width = MediaQuery.of(context).size.width;
    final horizontal = width >= 768 ? tablet : mobile;
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  // Safe area helpers
  static EdgeInsets safeAreaTop({
    required BuildContext context,
    double standard = 70.0,
    double withNav = 84.0,
    double large = 110.0,
    double xlarge = 130.0,
  }) {
    // For now, return standard - can be enhanced based on actual safe area detection
    return EdgeInsets.only(top: standard);
  }

  // ============================================================
  // SHEET-SPECIFIC EDGE INSETS
  // ============================================================
  
  /// Sheet header padding
  static const EdgeInsets sheetHeader = EdgeInsets.symmetric(
    horizontal: sheetHorizontalPadding,
    vertical: sheetHeaderVerticalPadding,
  );
  
  /// Sheet content padding
  static const EdgeInsets sheetContent = EdgeInsets.symmetric(
    horizontal: sheetHorizontalPadding,
    vertical: sheetVerticalPadding,
  );
  
  /// Sheet content with extra bottom padding (for button area)
  static const EdgeInsets sheetContentWithBottom = EdgeInsets.only(
    left: sheetHorizontalPadding,
    right: sheetHorizontalPadding,
    top: sheetVerticalPadding,
    bottom: xxxl,
  );
}

/// Gap utilities for consistent spacing between widgets
class LynewedGap {
  LynewedGap._();

  static const SizedBox xxs = SizedBox(width: LynewedSpacing.xxs, height: LynewedSpacing.xxs);
  static const SizedBox xs = SizedBox(width: LynewedSpacing.xs, height: LynewedSpacing.xs);
  static const SizedBox sm = SizedBox(width: LynewedSpacing.sm, height: LynewedSpacing.sm);
  static const SizedBox md = SizedBox(width: LynewedSpacing.md, height: LynewedSpacing.md);
  static const SizedBox lg = SizedBox(width: LynewedSpacing.lg, height: LynewedSpacing.lg);
  static const SizedBox xl = SizedBox(width: LynewedSpacing.xl, height: LynewedSpacing.xl);
  static const SizedBox xxl = SizedBox(width: LynewedSpacing.xxl, height: LynewedSpacing.xxl);
  static const SizedBox xxxl = SizedBox(width: LynewedSpacing.xxxl, height: LynewedSpacing.xxxl);

  // Horizontal gaps
  static const SizedBox horizontalXxs = SizedBox(width: LynewedSpacing.xxs);
  static const SizedBox horizontalXs = SizedBox(width: LynewedSpacing.xs);
  static const SizedBox horizontalSm = SizedBox(width: LynewedSpacing.sm);
  static const SizedBox horizontalMd = SizedBox(width: LynewedSpacing.md);
  static const SizedBox horizontalLg = SizedBox(width: LynewedSpacing.lg);
  static const SizedBox horizontalXl = SizedBox(width: LynewedSpacing.xl);
  static const SizedBox horizontalXxl = SizedBox(width: LynewedSpacing.xxl);
  static const SizedBox horizontalXxxl = SizedBox(width: LynewedSpacing.xxxl);

  // Vertical gaps
  static const SizedBox verticalXxs = SizedBox(height: LynewedSpacing.xxs);
  static const SizedBox verticalXs = SizedBox(height: LynewedSpacing.xs);
  static const SizedBox verticalSm = SizedBox(height: LynewedSpacing.sm);
  static const SizedBox verticalMd = SizedBox(height: LynewedSpacing.md);
  static const SizedBox verticalLg = SizedBox(height: LynewedSpacing.lg);
  static const SizedBox verticalXl = SizedBox(height: LynewedSpacing.xl);
  static const SizedBox verticalXxl = SizedBox(height: LynewedSpacing.xxl);
  static const SizedBox verticalXxxl = SizedBox(height: LynewedSpacing.xxxl);

  // Custom gaps
  static SizedBox horizontal(double width) => SizedBox(width: width);
  static SizedBox vertical(double height) => SizedBox(height: height);
  static SizedBox square(double size) => SizedBox(width: size, height: size);
}
