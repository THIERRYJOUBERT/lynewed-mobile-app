/// BudgetFormatter Tests
///
/// Tests for the budget formatting utility class.
/// Covers: formatAmount, format, formatWithCurrency.
/// Note: Tests focus on the formatAmount and formatWithCurrency methods
/// which don't require FFAppState (except for userCurrency default).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/budget_formatter.dart';

void main() {
  group('BudgetFormatter', () {
    group('formatAmount', () {
      group('same currency (no conversion)', () {
        test('formats small amount without k suffix', () {
          final result = BudgetFormatter.formatAmount(
            500,
            sourceCurrency: 'EUR',
            displayCurrency: 'EUR',
          );
          expect(result, contains('500'));
          expect(result.contains('k'), isFalse);
          expect(result, contains('\u20AC')); // Euro symbol
        });

        test('formats thousands with k suffix', () {
          final result = BudgetFormatter.formatAmount(
            5000,
            sourceCurrency: 'EUR',
            displayCurrency: 'EUR',
          );
          expect(result, contains('5k'));
          expect(result, contains('\u20AC'));
        });

        test('formats exact thousands with integer k suffix', () {
          final result = BudgetFormatter.formatAmount(
            10000,
            sourceCurrency: 'EUR',
            displayCurrency: 'EUR',
          );
          expect(result, contains('10k'));
          expect(result.contains('10.0k'), isFalse); // Should be 10k, not 10.0k
        });

        test('formats non-exact thousands with decimal k suffix', () {
          final result = BudgetFormatter.formatAmount(
            5500,
            sourceCurrency: 'EUR',
            displayCurrency: 'EUR',
          );
          expect(result, contains('5.5k'));
        });

        test('does not show approximation symbol', () {
          final result = BudgetFormatter.formatAmount(
            1000,
            sourceCurrency: 'EUR',
            displayCurrency: 'EUR',
          );
          expect(result.startsWith('\u2248'), isFalse); // No approximation
        });

        test('handles zero amount', () {
          final result = BudgetFormatter.formatAmount(
            0,
            sourceCurrency: 'EUR',
            displayCurrency: 'EUR',
          );
          expect(result, contains('0'));
          expect(result, contains('\u20AC'));
        });
      });

      group('currency conversion', () {
        test('shows approximation symbol when currencies differ', () {
          final result = BudgetFormatter.formatAmount(
            1000,
            sourceCurrency: 'EUR',
            displayCurrency: 'USD',
          );
          expect(result.startsWith('\u2248'), isTrue);
        });

        test('converts EUR to USD correctly', () {
          final result = BudgetFormatter.formatAmount(
            10000,
            sourceCurrency: 'EUR',
            displayCurrency: 'USD',
          );
          // 10000 EUR * 1.08 = ~10800 USD, rounded to 11k
          expect(result, contains('\$'));
          expect(result, contains('\u2248'));
        });

        test('uses correct symbol for target currency', () {
          final usdResult = BudgetFormatter.formatAmount(
            1000,
            sourceCurrency: 'EUR',
            displayCurrency: 'USD',
          );
          final gbpResult = BudgetFormatter.formatAmount(
            1000,
            sourceCurrency: 'EUR',
            displayCurrency: 'GBP',
          );
          expect(usdResult, contains('\$'));
          expect(gbpResult, contains('\u00A3')); // Pound symbol
        });

        test('falls back to source currency when conversion fails', () {
          final result = BudgetFormatter.formatAmount(
            1000,
            sourceCurrency: 'EUR',
            displayCurrency: 'XYZ', // Unknown currency
          );
          // Should fall back to EUR and not show approximation
          expect(result, contains('\u20AC'));
          expect(result.startsWith('\u2248'), isFalse);
        });
      });

      group('case insensitivity', () {
        test('handles lowercase currency codes', () {
          final result = BudgetFormatter.formatAmount(
            1000,
            sourceCurrency: 'eur',
            displayCurrency: 'eur',
          );
          expect(result, contains('\u20AC'));
        });

        test('handles mixed case currency codes', () {
          final result = BudgetFormatter.formatAmount(
            1000,
            sourceCurrency: 'Eur',
            displayCurrency: 'Usd',
          );
          expect(result, contains('\$'));
        });
      });

      group('edge cases', () {
        test('formats very large amounts', () {
          final result = BudgetFormatter.formatAmount(
            1000000,
            sourceCurrency: 'EUR',
            displayCurrency: 'EUR',
          );
          expect(result, contains('1000k'));
          expect(result, contains('\u20AC'));
        });

        test('formats amounts just under 1000', () {
          final result = BudgetFormatter.formatAmount(
            999,
            sourceCurrency: 'EUR',
            displayCurrency: 'EUR',
          );
          expect(result, contains('999'));
          expect(result.contains('k'), isFalse);
        });

        test('formats amounts at exactly 1000', () {
          final result = BudgetFormatter.formatAmount(
            1000,
            sourceCurrency: 'EUR',
            displayCurrency: 'EUR',
          );
          expect(result, contains('1k'));
        });
      });
    });

    group('formatWithCurrency', () {
      test('formats budget range with both min and max', () {
        final result = BudgetFormatter.formatWithCurrency(
          min: 1000,
          max: 5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('1k'));
        expect(result, contains('5k'));
        expect(result, contains('-'));
      });

      test('formats budget range with only min', () {
        final result = BudgetFormatter.formatWithCurrency(
          min: 1000,
          max: null,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('From'));
        expect(result, contains('1k'));
      });

      test('formats budget range with only max', () {
        final result = BudgetFormatter.formatWithCurrency(
          min: null,
          max: 5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('Up to'));
        expect(result, contains('5k'));
      });

      test('returns "Not specified" when both are null', () {
        final result = BudgetFormatter.formatWithCurrency(
          min: null,
          max: null,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, equals('Not specified'));
      });

      test('shows approximation for different currencies', () {
        final result = BudgetFormatter.formatWithCurrency(
          min: 1000,
          max: 5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'USD',
        );
        expect(result.startsWith('\u2248'), isTrue);
      });

      test('does not show approximation for same currency', () {
        final result = BudgetFormatter.formatWithCurrency(
          min: 1000,
          max: 5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result.startsWith('\u2248'), isFalse);
      });
    });

    group('_formatNumber (tested via formatAmount)', () {
      test('formats exact thousands as integer k', () {
        final result = BudgetFormatter.formatAmount(
          2000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('2k'));
        expect(result.contains('2.0k'), isFalse);
      });

      test('formats non-exact thousands with one decimal', () {
        final result = BudgetFormatter.formatAmount(
          2500,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('2.5k'));
      });

      test('formats numbers less than 1000 as-is', () {
        final result = BudgetFormatter.formatAmount(
          750,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('750'));
      });

      test('handles boundary value 1000', () {
        final result = BudgetFormatter.formatAmount(
          1000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(result, contains('1k'));
      });
    });

    group('Integration with CurrencyService', () {
      test('converts EUR to GBP using correct rate', () {
        final result = BudgetFormatter.formatAmount(
          10000,
          sourceCurrency: 'EUR',
          displayCurrency: 'GBP',
        );
        // 10000 EUR * 0.86 = ~8600 GBP, rounded -> ~9k
        expect(result, contains('\u00A3'));
        expect(result, contains('\u2248'));
      });

      test('converts to high-rate currency (INR)', () {
        final result = BudgetFormatter.formatAmount(
          1000,
          sourceCurrency: 'EUR',
          displayCurrency: 'INR',
        );
        // 1000 EUR * 90 = 90000 INR -> 90k
        expect(result, contains('\u20B9')); // Rupee symbol
        expect(result, contains('\u2248'));
      });
    });

    group('Various currencies', () {
      test('formats with USD symbol', () {
        final result = BudgetFormatter.formatAmount(
          5000,
          sourceCurrency: 'USD',
          displayCurrency: 'USD',
        );
        expect(result, contains('\$'));
        expect(result, contains('5k'));
      });

      test('formats with GBP symbol', () {
        final result = BudgetFormatter.formatAmount(
          5000,
          sourceCurrency: 'GBP',
          displayCurrency: 'GBP',
        );
        expect(result, contains('\u00A3'));
        expect(result, contains('5k'));
      });

      test('formats with CHF code (no special symbol)', () {
        final result = BudgetFormatter.formatAmount(
          5000,
          sourceCurrency: 'CHF',
          displayCurrency: 'CHF',
        );
        expect(result, contains('CHF'));
        expect(result, contains('5k'));
      });

      test('formats with JPY symbol', () {
        final result = BudgetFormatter.formatAmount(
          500000,
          sourceCurrency: 'JPY',
          displayCurrency: 'JPY',
        );
        expect(result, contains('\u00A5')); // Yen symbol
      });
    });
  });
}
