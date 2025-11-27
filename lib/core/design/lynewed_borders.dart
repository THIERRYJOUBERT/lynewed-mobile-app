import 'package:flutter/material.dart';

/// Lynewed Border System - Based on MVP FlutterFlow analysis
/// See /docs/App/DESIGN_SYSTEM.md for complete usage guide
/// All border radius values extracted from actual usage patterns
class LynewedBorders {
  LynewedBorders._();

  // Border radius values
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 24.0;

  // Common border radius patterns
  static const BorderRadius borderRadiusNone = BorderRadius.circular(none);
  static const BorderRadius borderRadiusSm = BorderRadius.circular(sm);
  static const BorderRadius borderRadiusMd = BorderRadius.circular(md);
  static const BorderRadius borderRadiusLg = BorderRadius.circular(lg);
  static const BorderRadius borderRadiusXl = BorderRadius.circular(xl);

  // Top borders (for sheets and modals)
  static const BorderRadius topBorderRadiusXl = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  static const BorderRadius topBorderRadiusLg = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  // Bottom borders
  static const BorderRadius bottomBorderRadiusXl = BorderRadius.only(
    bottomLeft: Radius.circular(xl),
    bottomRight: Radius.circular(xl),
  );

  // Asymmetric borders
  static const BorderRadius buttonBorderRadius = BorderRadius.circular(none);
  static const BorderRadius inputBorderRadius = BorderRadius.circular(sm);
  static const BorderRadius cardBorderRadius = BorderRadius.circular(none);
  static const BorderRadius sheetBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  // Border utilities
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
  static BorderRadius only({
    double topLeft = 0.0,
    double topRight = 0.0,
    double bottomLeft = 0.0,
    double bottomRight = 0.0,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft),
    topRight: Radius.circular(topRight),
    bottomLeft: Radius.circular(bottomLeft),
    bottomRight: Radius.circular(bottomRight),
  );

  // Border side utilities
  static BorderSide borderSide({
    Color color = const Color(0xFFEBEBEB),
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
  }) {
    return BorderSide(
      color: color,
      width: width,
      style: style,
    );
  }

  // Common border styles
  static Border borderAll({
    Color color = const Color(0xFFEBEBEB),
    double width = 1.0,
  }) {
    return Border.all(
      color: color,
      width: width,
    );
  }

  static Border borderSymmetric({
    Color color = const Color(0xFFEBEBEB),
    double width = 1.0,
    double vertical = 0.0,
    double horizontal = 0.0,
  }) {
    return Border.symmetric(
      vertical: BorderSide(
        color: vertical > 0 ? color : Colors.transparent,
        width: vertical > 0 ? width : 0.0,
      ),
      horizontal: BorderSide(
        color: horizontal > 0 ? color : Colors.transparent,
        width: horizontal > 0 ? width : 0.0,
      ),
    );
  }

  // Input decoration borders
  static OutlineInputBorder inputBorder({
    Color color = const Color(0xFFEBEBEB),
    double width = 1.0,
    double radius = 2.0,
  }) {
    return OutlineInputBorder(
      borderSide: borderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static OutlineInputBorder inputErrorBorder({
    Color color = const Color(0xFFFF5963),
    double width = 1.0,
    double radius = 2.0,
  }) {
    return OutlineInputBorder(
      borderSide: borderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static OutlineInputBorder inputFocusedBorder({
    Color color = const Color(0xFF000000),
    double width = 2.0,
    double radius = 2.0,
  }) {
    return OutlineInputBorder(
      borderSide: borderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
