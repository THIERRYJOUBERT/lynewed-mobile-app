import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/lynewed_colors.dart';

void main() {
  group('LynewedColors', () {
    group('Primary Colors', () {
      test('should have primary color defined', () {
        expect(LynewedColors.primary, isA<Color>());
        expect(LynewedColors.primary, isNotNull);
      });

      test('should have background color defined', () {
        expect(LynewedColors.background, isA<Color>());
        expect(LynewedColors.background, isNotNull);
      });

      test('should have surface color defined', () {
        expect(LynewedColors.surface, isA<Color>());
        expect(LynewedColors.surface, isNotNull);
      });

      test('should have border color defined', () {
        expect(LynewedColors.border, isA<Color>());
        expect(LynewedColors.border, isNotNull);
      });

      test('should have text primary color defined', () {
        expect(LynewedColors.textPrimary, isA<Color>());
        expect(LynewedColors.textPrimary, isNotNull);
      });

      test('should have text secondary color defined', () {
        expect(LynewedColors.textSecondary, isA<Color>());
        expect(LynewedColors.textSecondary, isNotNull);
      });
    });

    group('Functional Colors', () {
      test('should have success color defined', () {
        expect(LynewedColors.success, isA<Color>());
        expect(LynewedColors.success, isNotNull);
      });

      test('should have warning color defined', () {
        expect(LynewedColors.warning, isA<Color>());
        expect(LynewedColors.warning, isNotNull);
      });

      test('should have error color defined', () {
        expect(LynewedColors.error, isA<Color>());
        expect(LynewedColors.error, isNotNull);
      });

      test('should have info color defined', () {
        expect(LynewedColors.info, isA<Color>());
        expect(LynewedColors.info, isNotNull);
      });
    });

    group('Neutral Colors', () {
      test('should have gray100 color defined', () {
        expect(LynewedColors.gray100, isA<Color>());
        expect(LynewedColors.gray100, isNotNull);
      });

      test('should have gray200 color defined', () {
        expect(LynewedColors.gray200, isA<Color>());
        expect(LynewedColors.gray200, isNotNull);
      });

      test('should have gray300 color defined', () {
        expect(LynewedColors.gray300, isA<Color>());
        expect(LynewedColors.gray300, isNotNull);
      });

      test('should have transparent color defined', () {
        expect(LynewedColors.transparent, Colors.transparent);
      });
    });

    group('Special Colors', () {
      test('should have textOnDark color defined', () {
        expect(LynewedColors.textOnDark, isA<Color>());
        expect(LynewedColors.textOnDark, Colors.white);
      });

      test('should have textOnPrimary color defined', () {
        expect(LynewedColors.textOnPrimary, isA<Color>());
        expect(LynewedColors.textOnPrimary, Colors.white);
      });

      test('should have inputBorderColor defined', () {
        expect(LynewedColors.inputBorderColor, isA<Color>());
        expect(LynewedColors.inputBorderColor, isNotNull);
      });
    });

    group('Color consistency', () {
      test('primary and textPrimary should be consistent dark colors', () {
        // Both should be dark colors (low luminance)
        expect(LynewedColors.primary.computeLuminance(), lessThan(0.5));
        expect(LynewedColors.textPrimary.computeLuminance(), lessThan(0.5));
      });

      test('background should be a light color', () {
        expect(LynewedColors.background.computeLuminance(), greaterThan(0.5));
      });

      test('textOnDark should contrast with dark backgrounds', () {
        // TextOnDark should be light (high luminance) to contrast with dark
        expect(LynewedColors.textOnDark.computeLuminance(), greaterThan(0.5));
      });
    });
  });

  group('LynewedColorUtils', () {
    test('getTextOnBackground returns textPrimary for light backgrounds', () {
      final textColor = LynewedColorUtils.getTextOnBackground(Colors.white);
      expect(textColor, LynewedColors.textPrimary);
    });

    test('getTextOnBackground returns textOnDark for dark backgrounds', () {
      final textColor = LynewedColorUtils.getTextOnBackground(Colors.black);
      expect(textColor, LynewedColors.textOnDark);
    });

    test('withOpacity creates color with specified opacity', () {
      final colorWithOpacity = LynewedColorUtils.withOpacity(LynewedColors.primary, 0.5);
      expect(colorWithOpacity.a, closeTo(0.5, 0.01));
    });
  });
}
