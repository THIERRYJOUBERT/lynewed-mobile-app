/// CurrencyService Tests
///
/// Tests for the currency conversion service.
/// Covers: conversion, rounding, budget formatting, slider configuration.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/services/currency_service.dart';

void main() {
  group('CurrencyService', () {
    late CurrencyService service;

    setUp(() {
      service = CurrencyService.instance;
    });

    group('singleton', () {
      test('instance returns same object', () {
        final instance1 = CurrencyService.instance;
        final instance2 = CurrencyService.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      test('factory constructor returns singleton', () {
        final instance1 = CurrencyService();
        final instance2 = CurrencyService();
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('convert', () {
      test('returns same amount when from and to are equal', () {
        expect(service.convert(1000, from: 'EUR', to: 'EUR'), equals(1000));
        expect(service.convert(500, from: 'USD', to: 'USD'), equals(500));
      });

      test('converts EUR to USD correctly', () {
        final result = service.convert(1000, from: 'EUR', to: 'USD');
        expect(result, isNotNull);
        // EUR rate is 1.0, USD rate is 1.08, so 1000 EUR = 1080 USD
        expect(result, closeTo(1080, 1));
      });

      test('converts USD to EUR correctly', () {
        final result = service.convert(1080, from: 'USD', to: 'EUR');
        expect(result, isNotNull);
        // 1080 USD / 1.08 = 1000 EUR
        expect(result, closeTo(1000, 1));
      });

      test('converts EUR to GBP correctly', () {
        final result = service.convert(1000, from: 'EUR', to: 'GBP');
        expect(result, isNotNull);
        // EUR rate is 1.0, GBP rate is 0.86, so 1000 EUR = 860 GBP
        expect(result, closeTo(860, 1));
      });

      test('handles case-insensitive currency codes', () {
        final upper = service.convert(1000, from: 'EUR', to: 'USD');
        final lower = service.convert(1000, from: 'eur', to: 'usd');
        final mixed = service.convert(1000, from: 'Eur', to: 'Usd');
        expect(upper, equals(lower));
        expect(upper, equals(mixed));
      });

      test('returns null for unknown source currency', () {
        expect(service.convert(1000, from: 'XYZ', to: 'EUR'), isNull);
      });

      test('returns null for unknown target currency', () {
        expect(service.convert(1000, from: 'EUR', to: 'XYZ'), isNull);
      });

      test('handles zero amount', () {
        expect(service.convert(0, from: 'EUR', to: 'USD'), equals(0));
      });

      test('handles negative amount', () {
        final result = service.convert(-1000, from: 'EUR', to: 'USD');
        expect(result, isNotNull);
        expect(result, lessThan(0));
      });

      test('handles high-value currencies (INR)', () {
        final result = service.convert(1000, from: 'EUR', to: 'INR');
        expect(result, isNotNull);
        // EUR rate is 1.0, INR rate is 90.0, so 1000 EUR = 90000 INR
        expect(result, closeTo(90000, 100));
      });

      test('handles fractional currencies (KWD)', () {
        final result = service.convert(1000, from: 'EUR', to: 'KWD');
        expect(result, isNotNull);
        // EUR rate is 1.0, KWD rate is 0.33, so 1000 EUR = 330 KWD
        expect(result, closeTo(330, 5));
      });
    });

    group('convertRounded', () {
      test('returns same amount when from and to are equal', () {
        expect(service.convertRounded(1000, from: 'EUR', to: 'EUR'), equals(1000));
      });

      test('returns null for unknown currency', () {
        expect(service.convertRounded(1000, from: 'XYZ', to: 'EUR'), isNull);
      });

      test('rounds large values to nearest 1000', () {
        // 10000 EUR = ~10800 USD, should round to nearest 1000
        final result = service.convertRounded(10000, from: 'EUR', to: 'USD');
        expect(result, isNotNull);
        expect(result! % 1000, equals(0));
      });

      test('rounds medium values to nearest 100', () {
        // 1000 EUR = ~1080 USD, should round to nearest 100
        final result = service.convertRounded(1000, from: 'EUR', to: 'USD');
        expect(result, isNotNull);
        expect(result! % 100, equals(0));
      });

      test('rounds small values to nearest 10', () {
        // 100 EUR = ~108 USD, should round to nearest 10
        final result = service.convertRounded(100, from: 'EUR', to: 'USD');
        expect(result, isNotNull);
        expect(result! % 10, equals(0));
      });

      test('rounds very small values to nearest integer', () {
        // 50 EUR = ~54 USD
        final result = service.convertRounded(50, from: 'EUR', to: 'USD');
        expect(result, isNotNull);
        expect(result, isA<int>());
      });
    });

    group('formatBudgetRange', () {
      test('returns "Not specified" when both min and max are null', () {
        final result = service.formatBudgetRange(
          budgetMin: null,
          budgetMax: null,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, equals('Not specified'));
      });

      test('formats "Up to X" when only max is provided', () {
        final result = service.formatBudgetRange(
          budgetMin: null,
          budgetMax: 5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('Up to'));
        expect(result, contains('5k'));
      });

      test('formats "From X" when only min is provided', () {
        final result = service.formatBudgetRange(
          budgetMin: 1000,
          budgetMax: null,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('From'));
        expect(result, contains('1k'));
      });

      test('formats "X - Y" when both min and max are provided', () {
        final result = service.formatBudgetRange(
          budgetMin: 1000,
          budgetMax: 5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('1k'));
        expect(result, contains('5k'));
        expect(result, contains('-'));
      });

      test('does not show approximation symbol for same currency', () {
        final result = service.formatBudgetRange(
          budgetMin: 1000,
          budgetMax: 5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result.startsWith('\u2248'), isFalse); // Unicode for approximately
      });

      test('shows approximation symbol for different currencies', () {
        final result = service.formatBudgetRange(
          budgetMin: 1000,
          budgetMax: 5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'USD',
        );
        expect(result.startsWith('\u2248'), isTrue);
      });

      test('includes currency symbol', () {
        final result = service.formatBudgetRange(
          budgetMin: 1000,
          budgetMax: 5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result.contains('\u20AC'), isTrue); // Euro symbol
      });

      test('formats numbers with k suffix for thousands', () {
        final result = service.formatBudgetRange(
          budgetMin: 10000,
          budgetMax: 50000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('10k'));
        expect(result, contains('50k'));
      });

      test('formats small numbers without k suffix', () {
        final result = service.formatBudgetRange(
          budgetMin: 500,
          budgetMax: 900,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('500'));
        expect(result, contains('900'));
        expect(result.contains('k'), isFalse);
      });
    });

    group('isSupported', () {
      test('returns true for major currencies', () {
        expect(service.isSupported('EUR'), isTrue);
        expect(service.isSupported('USD'), isTrue);
        expect(service.isSupported('GBP'), isTrue);
        expect(service.isSupported('JPY'), isTrue);
      });

      test('returns true for supported regional currencies', () {
        expect(service.isSupported('INR'), isTrue);
        expect(service.isSupported('AED'), isTrue);
        expect(service.isSupported('BRL'), isTrue);
      });

      test('returns false for unknown currency', () {
        expect(service.isSupported('XYZ'), isFalse);
        expect(service.isSupported('UNKNOWN'), isFalse);
      });

      test('handles case-insensitive codes', () {
        expect(service.isSupported('eur'), isTrue);
        expect(service.isSupported('Eur'), isTrue);
        expect(service.isSupported('EUR'), isTrue);
      });
    });

    group('getRateFromEur', () {
      test('returns 1.0 for EUR', () {
        expect(service.getRateFromEur('EUR'), equals(1.0));
      });

      test('returns rate for USD', () {
        final rate = service.getRateFromEur('USD');
        expect(rate, isNotNull);
        expect(rate, closeTo(1.08, 0.01));
      });

      test('returns rate for GBP', () {
        final rate = service.getRateFromEur('GBP');
        expect(rate, isNotNull);
        expect(rate, closeTo(0.86, 0.01));
      });

      test('returns null for unknown currency', () {
        expect(service.getRateFromEur('XYZ'), isNull);
      });

      test('handles case-insensitive codes', () {
        expect(service.getRateFromEur('eur'), equals(1.0));
        expect(service.getRateFromEur('Eur'), equals(1.0));
      });
    });

    group('slider configuration', () {
      group('getMaxBudgetForCurrency', () {
        test('returns base max for EUR', () {
          final max = service.getMaxBudgetForCurrency('EUR');
          expect(max, equals(50000.0));
        });

        test('returns converted and rounded max for other currencies', () {
          final usdMax = service.getMaxBudgetForCurrency('USD');
          // 50000 EUR * 1.08 = 54000, rounded to nice number
          expect(usdMax, greaterThan(50000));
        });

        test('returns base max for unknown currency', () {
          final max = service.getMaxBudgetForCurrency('XYZ');
          expect(max, equals(50000.0));
        });

        test('rounds to nice number for high-rate currencies', () {
          final inrMax = service.getMaxBudgetForCurrency('INR');
          // 50000 EUR * 90 = 4,500,000 INR, rounded to 5,000,000
          expect(inrMax, greaterThan(4000000));
          expect(inrMax % 100000, equals(0)); // Should be a nice round number
        });
      });

      group('getStepForCurrency', () {
        test('returns appropriate step based on max budget', () {
          final eurStep = service.getStepForCurrency('EUR');
          expect(eurStep, greaterThan(0));
        });

        test('returns larger step for high-rate currencies', () {
          final eurStep = service.getStepForCurrency('EUR');
          final inrStep = service.getStepForCurrency('INR');
          expect(inrStep, greaterThan(eurStep));
        });
      });

      group('getDivisionsForCurrency', () {
        test('returns positive number of divisions', () {
          final divisions = service.getDivisionsForCurrency('EUR');
          expect(divisions, greaterThan(0));
        });

        test('divisions equals max / step', () {
          final max = service.getMaxBudgetForCurrency('EUR');
          final step = service.getStepForCurrency('EUR');
          final divisions = service.getDivisionsForCurrency('EUR');
          expect(divisions, equals((max / step).round()));
        });
      });
    });

    group('formatBudgetValue', () {
      test('formats millions with M suffix', () {
        final formatted = service.formatBudgetValue(5000000, 'EUR');
        expect(formatted, contains('5M'));
        expect(formatted, contains('\u20AC'));
      });

      test('formats thousands with K suffix', () {
        final formatted = service.formatBudgetValue(50000, 'EUR');
        expect(formatted, contains('50K'));
        expect(formatted, contains('\u20AC'));
      });

      test('formats small values without suffix', () {
        final formatted = service.formatBudgetValue(500, 'EUR');
        expect(formatted, contains('500'));
        expect(formatted.contains('K'), isFalse);
        expect(formatted.contains('M'), isFalse);
      });

      test('includes correct currency symbol', () {
        final eurFormatted = service.formatBudgetValue(1000, 'EUR');
        final usdFormatted = service.formatBudgetValue(1000, 'USD');
        expect(eurFormatted, contains('\u20AC'));
        expect(usdFormatted, contains('\$'));
      });

      test('handles fractional millions correctly', () {
        final formatted = service.formatBudgetValue(1500000, 'EUR');
        expect(formatted, contains('1.5M'));
      });

      test('handles fractional thousands correctly', () {
        final formatted = service.formatBudgetValue(1500, 'EUR');
        expect(formatted, contains('1.5K'));
      });
    });

    group('convertBudgetForFilter', () {
      test('converts using the standard convert method', () {
        final result = service.convertBudgetForFilter(1000, from: 'EUR', to: 'USD');
        final directResult = service.convert(1000, from: 'EUR', to: 'USD');
        expect(result, equals(directResult));
      });

      test('returns null for unknown currency', () {
        expect(service.convertBudgetForFilter(1000, from: 'XYZ', to: 'EUR'), isNull);
      });
    });

    group('Edge Cases', () {
      test('handles zero budget', () {
        final result = service.formatBudgetRange(
          budgetMin: 0,
          budgetMax: 1000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result.isNotEmpty, isTrue);
      });

      test('handles very large budgets', () {
        final result = service.formatBudgetRange(
          budgetMin: 1000000,
          budgetMax: 10000000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result.isNotEmpty, isTrue);
      });

      test('conversion is consistent both ways', () {
        const originalEur = 1000.0;
        final toUsd = service.convert(originalEur, from: 'EUR', to: 'USD');
        final backToEur = service.convert(toUsd!, from: 'USD', to: 'EUR');
        expect(backToEur, closeTo(originalEur, 0.01));
      });
    });
  });
}
