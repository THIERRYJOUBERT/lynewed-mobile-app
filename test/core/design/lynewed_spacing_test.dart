import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/lynewed_spacing.dart';

void main() {
  group('LynewedSpacing', () {
    group('Base Spacing Scale', () {
      test('should have xxs spacing defined', () {
        expect(LynewedSpacing.xxs, isA<double>());
        expect(LynewedSpacing.xxs, 2.0);
      });

      test('should have xs spacing defined', () {
        expect(LynewedSpacing.xs, isA<double>());
        expect(LynewedSpacing.xs, 4.0);
      });

      test('should have sm spacing defined', () {
        expect(LynewedSpacing.sm, isA<double>());
        expect(LynewedSpacing.sm, 8.0);
      });

      test('should have md spacing defined', () {
        expect(LynewedSpacing.md, isA<double>());
        expect(LynewedSpacing.md, 12.0);
      });

      test('should have lg spacing defined', () {
        expect(LynewedSpacing.lg, isA<double>());
        expect(LynewedSpacing.lg, 16.0);
      });

      test('should have xl spacing defined', () {
        expect(LynewedSpacing.xl, isA<double>());
        expect(LynewedSpacing.xl, 20.0);
      });

      test('should have xxl spacing defined', () {
        expect(LynewedSpacing.xxl, isA<double>());
        expect(LynewedSpacing.xxl, 24.0);
      });

      test('should have xxxl spacing defined', () {
        expect(LynewedSpacing.xxxl, isA<double>());
        expect(LynewedSpacing.xxxl, 32.0);
      });

      test('spacing values should be in ascending order', () {
        expect(LynewedSpacing.xxs, lessThan(LynewedSpacing.xs));
        expect(LynewedSpacing.xs, lessThan(LynewedSpacing.sm));
        expect(LynewedSpacing.sm, lessThan(LynewedSpacing.md));
        expect(LynewedSpacing.md, lessThan(LynewedSpacing.lg));
        expect(LynewedSpacing.lg, lessThan(LynewedSpacing.xl));
        expect(LynewedSpacing.xl, lessThan(LynewedSpacing.xxl));
        expect(LynewedSpacing.xxl, lessThan(LynewedSpacing.xxxl));
      });
    });

    group('Component Heights', () {
      test('should have buttonHeight defined', () {
        expect(LynewedSpacing.buttonHeight, isA<double>());
        expect(LynewedSpacing.buttonHeight, 48.0);
      });

      test('should have inputHeight defined', () {
        expect(LynewedSpacing.inputHeight, isA<double>());
        expect(LynewedSpacing.inputHeight, 48.0);
      });

      test('should have iconSize defined', () {
        expect(LynewedSpacing.iconSize, isA<double>());
        expect(LynewedSpacing.iconSize, 18.0);
      });

      test('should have iconSizeLarge defined', () {
        expect(LynewedSpacing.iconSizeLarge, isA<double>());
        expect(LynewedSpacing.iconSizeLarge, 24.0);
      });
    });

    group('Sheet Layout', () {
      test('should have sheetHorizontalPadding defined', () {
        expect(LynewedSpacing.sheetHorizontalPadding, isA<double>());
        expect(LynewedSpacing.sheetHorizontalPadding, 20.0);
      });

      test('should have sheetVerticalPadding defined', () {
        expect(LynewedSpacing.sheetVerticalPadding, isA<double>());
        expect(LynewedSpacing.sheetVerticalPadding, 16.0);
      });

      test('should have formSectionGap defined', () {
        expect(LynewedSpacing.formSectionGap, isA<double>());
        expect(LynewedSpacing.formSectionGap, 30.0);
      });

      test('should have labelFieldGap defined', () {
        expect(LynewedSpacing.labelFieldGap, isA<double>());
        expect(LynewedSpacing.labelFieldGap, 10.0);
      });
    });

    group('EdgeInsets Helpers', () {
      test('allXs should be EdgeInsets with xs value', () {
        expect(LynewedSpacing.allXs, const EdgeInsets.all(4.0));
      });

      test('allSm should be EdgeInsets with sm value', () {
        expect(LynewedSpacing.allSm, const EdgeInsets.all(8.0));
      });

      test('allMd should be EdgeInsets with md value', () {
        expect(LynewedSpacing.allMd, const EdgeInsets.all(12.0));
      });

      test('allLg should be EdgeInsets with lg value', () {
        expect(LynewedSpacing.allLg, const EdgeInsets.all(16.0));
      });

      test('horizontalXl should be symmetric horizontal EdgeInsets', () {
        expect(
          LynewedSpacing.horizontalXl,
          const EdgeInsets.symmetric(horizontal: 20.0),
        );
      });

      test('verticalLg should be symmetric vertical EdgeInsets', () {
        expect(
          LynewedSpacing.verticalLg,
          const EdgeInsets.symmetric(vertical: 16.0),
        );
      });
    });

    group('Spacing Utilities', () {
      test('horizontal utility should create symmetric horizontal padding', () {
        final result = LynewedSpacing.horizontal(10.0);
        expect(result, const EdgeInsets.symmetric(horizontal: 10.0));
      });

      test('vertical utility should create symmetric vertical padding', () {
        final result = LynewedSpacing.vertical(10.0);
        expect(result, const EdgeInsets.symmetric(vertical: 10.0));
      });

      test('all utility should create uniform padding', () {
        final result = LynewedSpacing.all(10.0);
        expect(result, const EdgeInsets.all(10.0));
      });

      test('only utility should create directional padding', () {
        final result = LynewedSpacing.only(left: 5.0, top: 10.0);
        expect(result, const EdgeInsets.only(left: 5.0, top: 10.0));
      });
    });

    group('Sheet-specific EdgeInsets', () {
      test('sheetHeader should have correct padding', () {
        expect(
          LynewedSpacing.sheetHeader,
          const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 12.0,
          ),
        );
      });

      test('sheetContent should have correct padding', () {
        expect(
          LynewedSpacing.sheetContent,
          const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 16.0,
          ),
        );
      });
    });
  });

  group('LynewedGap', () {
    group('Standard Gaps', () {
      test('xxs gap should have xxs dimensions', () {
        expect(LynewedGap.xxs, isA<SizedBox>());
        expect(LynewedGap.xxs.width, 2.0);
        expect(LynewedGap.xxs.height, 2.0);
      });

      test('sm gap should have sm dimensions', () {
        expect(LynewedGap.sm, isA<SizedBox>());
        expect(LynewedGap.sm.width, 8.0);
        expect(LynewedGap.sm.height, 8.0);
      });

      test('lg gap should have lg dimensions', () {
        expect(LynewedGap.lg, isA<SizedBox>());
        expect(LynewedGap.lg.width, 16.0);
        expect(LynewedGap.lg.height, 16.0);
      });
    });

    group('Directional Gaps', () {
      test('horizontalSm should only have width', () {
        expect(LynewedGap.horizontalSm, isA<SizedBox>());
        expect(LynewedGap.horizontalSm.width, 8.0);
        expect(LynewedGap.horizontalSm.height, isNull);
      });

      test('verticalLg should only have height', () {
        expect(LynewedGap.verticalLg, isA<SizedBox>());
        expect(LynewedGap.verticalLg.width, isNull);
        expect(LynewedGap.verticalLg.height, 16.0);
      });
    });

    group('Custom Gaps', () {
      test('horizontal utility should create horizontal gap', () {
        final gap = LynewedGap.horizontal(25.0);
        expect(gap, isA<SizedBox>());
        expect(gap.width, 25.0);
      });

      test('vertical utility should create vertical gap', () {
        final gap = LynewedGap.vertical(30.0);
        expect(gap, isA<SizedBox>());
        expect(gap.height, 30.0);
      });

      test('square utility should create square gap', () {
        final gap = LynewedGap.square(15.0);
        expect(gap, isA<SizedBox>());
        expect(gap.width, 15.0);
        expect(gap.height, 15.0);
      });
    });
  });
}
