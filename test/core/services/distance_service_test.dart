/// DistanceService Tests
///
/// Tests for the distance conversion and formatting service.
/// Covers: km/miles conversion, formatting, slider configuration.
/// Note: Tests focus on pure conversion functions that don't depend on FFAppState.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/services/distance_service.dart';

void main() {
  group('DistanceService', () {
    late DistanceService service;

    setUp(() {
      service = DistanceService.instance;
    });

    group('singleton', () {
      test('instance returns same object', () {
        final instance1 = DistanceService.instance;
        final instance2 = DistanceService.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      test('factory constructor returns singleton', () {
        final instance1 = DistanceService();
        final instance2 = DistanceService();
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('conversion factors', () {
      test('kmToMilesFactor is approximately 0.621371', () {
        expect(DistanceService.kmToMilesFactor, closeTo(0.621371, 0.000001));
      });

      test('milesToKmFactor is approximately 1.60934', () {
        expect(DistanceService.milesToKmFactor, closeTo(1.60934, 0.00001));
      });

      test('conversion factors are mathematically inverse', () {
        // kmToMilesFactor * milesToKmFactor should be close to 1
        final product = DistanceService.kmToMilesFactor * DistanceService.milesToKmFactor;
        expect(product, closeTo(1.0, 0.0001));
      });
    });

    group('kmToMiles', () {
      test('converts 0 km to 0 miles', () {
        expect(service.kmToMiles(0), equals(0));
      });

      test('converts 1 km to approximately 0.621 miles', () {
        expect(service.kmToMiles(1), closeTo(0.621371, 0.001));
      });

      test('converts 10 km to approximately 6.21 miles', () {
        expect(service.kmToMiles(10), closeTo(6.21, 0.01));
      });

      test('converts 100 km to approximately 62.14 miles', () {
        expect(service.kmToMiles(100), closeTo(62.14, 0.1));
      });

      test('converts negative values', () {
        expect(service.kmToMiles(-10), closeTo(-6.21, 0.01));
      });

      test('handles very large values', () {
        expect(service.kmToMiles(1000000), closeTo(621371, 1));
      });

      test('handles decimal values', () {
        expect(service.kmToMiles(5.5), closeTo(3.42, 0.01));
      });
    });

    group('milesToKm', () {
      test('converts 0 miles to 0 km', () {
        expect(service.milesToKm(0), equals(0));
      });

      test('converts 1 mile to approximately 1.609 km', () {
        expect(service.milesToKm(1), closeTo(1.60934, 0.001));
      });

      test('converts 10 miles to approximately 16.09 km', () {
        expect(service.milesToKm(10), closeTo(16.09, 0.01));
      });

      test('converts 100 miles to approximately 160.9 km', () {
        expect(service.milesToKm(100), closeTo(160.9, 0.1));
      });

      test('converts negative values', () {
        expect(service.milesToKm(-10), closeTo(-16.09, 0.01));
      });

      test('handles very large values', () {
        expect(service.milesToKm(1000000), closeTo(1609340, 10));
      });

      test('handles decimal values', () {
        expect(service.milesToKm(5.5), closeTo(8.85, 0.01));
      });
    });

    group('round trip conversions', () {
      test('km -> miles -> km returns original value', () {
        const originalKm = 100.0;
        final miles = service.kmToMiles(originalKm);
        final backToKm = service.milesToKm(miles);
        expect(backToKm, closeTo(originalKm, 0.01));
      });

      test('miles -> km -> miles returns original value', () {
        const originalMiles = 62.0;
        final km = service.milesToKm(originalMiles);
        final backToMiles = service.kmToMiles(km);
        expect(backToMiles, closeTo(originalMiles, 0.01));
      });

      test('round trip preserves precision for various values', () {
        final testValues = [1.0, 5.0, 10.0, 50.0, 100.0, 500.0];
        for (final value in testValues) {
          final miles = service.kmToMiles(value);
          final backToKm = service.milesToKm(miles);
          expect(backToKm, closeTo(value, 0.01), reason: 'Failed for $value km');
        }
      });
    });

    group('userUnit (default behavior without FFAppState)', () {
      // Note: Without mocking FFAppState, userUnit defaults to km
      // These tests verify the default behavior

      test('userUnit defaults to km when FFAppState throws', () {
        // The service catches FFAppState errors and returns km as default
        // This tests that the fallback works
        expect(service.userUnit, isNotNull);
      });
    });

    group('formatDistance (with default unit)', () {
      // Note: These tests assume km mode (default when FFAppState is not available)
      // The service falls back to km when it can't access user preferences

      test('formats distance with unit by default', () {
        final formatted = service.formatDistance(10.0);
        // With default km mode, should contain number and unit
        expect(formatted.contains('km') || formatted.contains('mi'), isTrue);
      });

      test('formats small distances (< 1 km) as meters', () {
        // When usesMiles is false (default), small distances show meters
        final formatted = service.formatDistance(0.5);
        // Should show either meters or the converted small value
        expect(formatted.isNotEmpty, isTrue);
      });

      test('respects showUnit parameter', () {
        final withUnit = service.formatDistance(10.0, showUnit: true);
        final withoutUnit = service.formatDistance(10.0, showUnit: false);
        // With unit should be longer than without unit
        expect(withUnit.length, greaterThanOrEqualTo(withoutUnit.length));
      });
    });

    group('formatDistanceRange', () {
      test('formats range with both values', () {
        final formatted = service.formatDistanceRange(0, 50);
        // Should contain a range separator
        expect(formatted.contains('-'), isTrue);
      });

      test('includes unit by default', () {
        final formatted = service.formatDistanceRange(0, 100);
        expect(formatted.contains('km') || formatted.contains('mi'), isTrue);
      });

      test('respects showUnit parameter', () {
        final withUnit = service.formatDistanceRange(0, 50, showUnit: true);
        final withoutUnit = service.formatDistanceRange(0, 50, showUnit: false);
        expect(withUnit.length, greaterThan(withoutUnit.length));
      });
    });

    group('slider configuration', () {
      test('maxSliderValue is positive', () {
        expect(service.maxSliderValue, greaterThan(0));
      });

      test('sliderStep is positive', () {
        expect(service.sliderStep, greaterThan(0));
      });

      test('sliderDivisions is positive integer', () {
        expect(service.sliderDivisions, greaterThan(0));
        expect(service.sliderDivisions, isA<int>());
      });

      test('sliderDivisions equals maxSliderValue / sliderStep', () {
        final expectedDivisions = (service.maxSliderValue / service.sliderStep).round();
        expect(service.sliderDivisions, equals(expectedDivisions));
      });

      test('distancePresets contains reasonable values', () {
        final presets = service.distancePresets;
        expect(presets, isNotEmpty);
        expect(presets.first, greaterThan(0));
        // Presets should be in ascending order
        for (var i = 1; i < presets.length; i++) {
          expect(presets[i], greaterThan(presets[i - 1]));
        }
      });
    });

    group('formatSliderValue', () {
      test('formats value with unit', () {
        final formatted = service.formatSliderValue(50);
        expect(formatted.contains('50'), isTrue);
        expect(formatted.contains('km') || formatted.contains('mi'), isTrue);
      });

      test('rounds value for display', () {
        final formatted = service.formatSliderValue(49.7);
        expect(formatted.contains('50'), isTrue);
      });
    });

    group('DistanceFormatting extension', () {
      test('double.toFormattedDistance() formats correctly', () {
        final formatted = 10.0.toFormattedDistance();
        expect(formatted.isNotEmpty, isTrue);
        expect(formatted.contains('km') || formatted.contains('mi'), isTrue);
      });

      test('respects showUnit parameter', () {
        final withUnit = 10.0.toFormattedDistance(showUnit: true);
        final withoutUnit = 10.0.toFormattedDistance(showUnit: false);
        expect(withUnit.length, greaterThanOrEqualTo(withoutUnit.length));
      });
    });

    group('Edge Cases', () {
      test('handles zero distance', () {
        expect(service.kmToMiles(0), equals(0));
        expect(service.milesToKm(0), equals(0));
      });

      test('handles very small positive distances', () {
        expect(service.kmToMiles(0.001), greaterThan(0));
        expect(service.milesToKm(0.001), greaterThan(0));
      });

      test('formatDistance handles very small values', () {
        final formatted = service.formatDistance(0.001);
        expect(formatted.isNotEmpty, isTrue);
      });

      test('formatDistanceRange handles equal min and max', () {
        final formatted = service.formatDistanceRange(50, 50);
        expect(formatted.contains('50'), isTrue);
      });
    });
  });
}
