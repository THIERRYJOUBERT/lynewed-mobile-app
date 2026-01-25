import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/lynewed_borders.dart';

void main() {
  group('LynewedBorders', () {
    group('Border Radius Values', () {
      test('should have none border radius defined', () {
        expect(LynewedBorders.none, isA<double>());
        expect(LynewedBorders.none, 0.0);
      });

      test('should have sm border radius defined', () {
        expect(LynewedBorders.sm, isA<double>());
        expect(LynewedBorders.sm, 2.0);
      });

      test('should have xs border radius defined', () {
        expect(LynewedBorders.xs, isA<double>());
        expect(LynewedBorders.xs, 4.0);
      });

      test('should have md border radius defined', () {
        expect(LynewedBorders.md, isA<double>());
        expect(LynewedBorders.md, 8.0);
      });

      test('should have lg border radius defined', () {
        expect(LynewedBorders.lg, isA<double>());
        expect(LynewedBorders.lg, 12.0);
      });

      test('should have xl border radius defined', () {
        expect(LynewedBorders.xl, isA<double>());
        expect(LynewedBorders.xl, 24.0);
      });

      test('border radius values should be in ascending order except sm and xs', () {
        expect(LynewedBorders.none, lessThan(LynewedBorders.sm));
        expect(LynewedBorders.sm, lessThan(LynewedBorders.xs));
        expect(LynewedBorders.xs, lessThan(LynewedBorders.md));
        expect(LynewedBorders.md, lessThan(LynewedBorders.lg));
        expect(LynewedBorders.lg, lessThan(LynewedBorders.xl));
      });
    });

    group('BorderRadius Patterns', () {
      test('borderRadiusNone should have zero radius', () {
        expect(
          LynewedBorders.borderRadiusNone,
          const BorderRadius.all(Radius.circular(0.0)),
        );
      });

      test('borderRadiusSm should have sm radius', () {
        expect(
          LynewedBorders.borderRadiusSm,
          const BorderRadius.all(Radius.circular(2.0)),
        );
      });

      test('borderRadiusMd should have md radius', () {
        expect(
          LynewedBorders.borderRadiusMd,
          const BorderRadius.all(Radius.circular(8.0)),
        );
      });

      test('borderRadiusLg should have lg radius', () {
        expect(
          LynewedBorders.borderRadiusLg,
          const BorderRadius.all(Radius.circular(12.0)),
        );
      });

      test('borderRadiusXl should have xl radius', () {
        expect(
          LynewedBorders.borderRadiusXl,
          const BorderRadius.all(Radius.circular(24.0)),
        );
      });
    });

    group('Top Border Radius', () {
      test('topBorderRadiusXl should only have top corners rounded', () {
        expect(
          LynewedBorders.topBorderRadiusXl,
          const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        );
      });

      test('topBorderRadiusLg should only have top corners rounded', () {
        expect(
          LynewedBorders.topBorderRadiusLg,
          const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        );
      });
    });

    group('Bottom Border Radius', () {
      test('bottomBorderRadiusXl should only have bottom corners rounded', () {
        expect(
          LynewedBorders.bottomBorderRadiusXl,
          const BorderRadius.only(
            bottomLeft: Radius.circular(24.0),
            bottomRight: Radius.circular(24.0),
          ),
        );
      });
    });

    group('Component Border Radius', () {
      test('buttonBorderRadius should be zero', () {
        expect(LynewedBorders.buttonBorderRadius, BorderRadius.circular(0));
      });

      test('inputBorderRadius should be sm', () {
        expect(LynewedBorders.inputBorderRadius, BorderRadius.circular(2.0));
      });

      test('cardBorderRadius should be zero', () {
        expect(LynewedBorders.cardBorderRadius, BorderRadius.circular(0));
      });

      test('sheetBorderRadius should have top corners rounded at xl', () {
        expect(
          LynewedBorders.sheetBorderRadius,
          const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        );
      });
    });

    group('Border Utilities', () {
      test('circular utility should create uniform border radius', () {
        final result = LynewedBorders.circular(10.0);
        expect(result, BorderRadius.circular(10.0));
      });

      test('only utility should create directional border radius', () {
        final result = LynewedBorders.only(
          topLeft: 10.0,
          bottomRight: 5.0,
        );
        expect(
          result,
          const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          ),
        );
      });
    });

    group('BorderSide Utilities', () {
      test('borderSide should create border side with defaults', () {
        final result = LynewedBorders.borderSide();
        expect(result.color, const Color(0xFFEBEBEB));
        expect(result.width, 1.0);
        expect(result.style, BorderStyle.solid);
      });

      test('borderSide should accept custom parameters', () {
        final result = LynewedBorders.borderSide(
          color: Colors.red,
          width: 2.0,
        );
        expect(result.color, Colors.red);
        expect(result.width, 2.0);
      });
    });

    group('Border Utilities', () {
      test('borderAll should create uniform border', () {
        final result = LynewedBorders.borderAll();
        expect(result.isUniform, true);
        expect(result.top.color, const Color(0xFFEBEBEB));
        expect(result.top.width, 1.0);
      });

      test('borderAll should accept custom color', () {
        final result = LynewedBorders.borderAll(color: Colors.blue, width: 2.0);
        expect(result.top.color, Colors.blue);
        expect(result.top.width, 2.0);
      });

      test('borderSymmetric should create symmetric border with both vertical and horizontal', () {
        // In Flutter Border.symmetric:
        // - 'vertical' param sets LEFT and RIGHT sides
        // - 'horizontal' param sets TOP and BOTTOM sides
        final result = LynewedBorders.borderSymmetric(
          vertical: 1.0,
          horizontal: 1.0,
        );
        // All sides should have width when both params > 0
        expect(result.top.width, 1.0);
        expect(result.left.width, 1.0);
      });

      test('borderSymmetric should hide vertical sides (left/right) when vertical is 0', () {
        final result = LynewedBorders.borderSymmetric(
          vertical: 0.0,
          horizontal: 1.0,
        );
        // vertical = 0 means LEFT/RIGHT are transparent with 0 width
        expect(result.left.color, Colors.transparent);
        expect(result.left.width, 0.0);
        expect(result.right.color, Colors.transparent);
        expect(result.right.width, 0.0);
        // horizontal > 0 means TOP/BOTTOM have color
        expect(result.top.color, const Color(0xFFEBEBEB));
        expect(result.top.width, 1.0);
      });

      test('borderSymmetric should hide horizontal sides (top/bottom) when horizontal is 0', () {
        final result = LynewedBorders.borderSymmetric(
          vertical: 1.0,
          horizontal: 0.0,
        );
        // horizontal = 0 means TOP/BOTTOM are transparent with 0 width
        expect(result.top.color, Colors.transparent);
        expect(result.top.width, 0.0);
        expect(result.bottom.color, Colors.transparent);
        expect(result.bottom.width, 0.0);
        // vertical > 0 means LEFT/RIGHT have the color
        expect(result.left.color, const Color(0xFFEBEBEB));
        expect(result.left.width, 1.0);
      });
    });

    group('Input Decoration Borders', () {
      test('inputBorder should create outline input border', () {
        final result = LynewedBorders.inputBorder();
        expect(result, isA<OutlineInputBorder>());
        expect(result.borderRadius, BorderRadius.circular(2.0));
        expect(result.borderSide.color, const Color(0xFFEBEBEB));
      });

      test('inputErrorBorder should use error color', () {
        final result = LynewedBorders.inputErrorBorder();
        expect(result, isA<OutlineInputBorder>());
        expect(result.borderSide.color, const Color(0xFFFF5963));
      });

      test('inputFocusedBorder should use primary color and thicker width', () {
        final result = LynewedBorders.inputFocusedBorder();
        expect(result, isA<OutlineInputBorder>());
        expect(result.borderSide.color, const Color(0xFF000000));
        expect(result.borderSide.width, 2.0);
      });
    });
  });
}
