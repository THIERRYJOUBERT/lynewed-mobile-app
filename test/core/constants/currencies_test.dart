/// CurrencyData Tests
///
/// Tests for the centralized currency definitions.
/// Covers: symbol lookup, code lookup, search functionality.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/constants/currencies.dart';

void main() {
  group('CurrencyData', () {
    group('all', () {
      test('contains at least major currencies', () {
        final codes = CurrencyData.all.map((c) => c.code).toList();
        expect(codes, contains('EUR'));
        expect(codes, contains('USD'));
        expect(codes, contains('GBP'));
        expect(codes, contains('CHF'));
      });

      test('has no duplicate currency codes', () {
        final codes = CurrencyData.all.map((c) => c.code).toList();
        final uniqueCodes = codes.toSet().toList();
        expect(codes.length, equals(uniqueCodes.length));
      });

      test('all entries have non-empty code, symbol, and name', () {
        for (final currency in CurrencyData.all) {
          expect(currency.code, isNotEmpty, reason: 'Code should not be empty for ${currency.name}');
          expect(currency.symbol, isNotEmpty, reason: 'Symbol should not be empty for ${currency.code}');
          expect(currency.name, isNotEmpty, reason: 'Name should not be empty for ${currency.code}');
        }
      });
    });

    group('getSymbol', () {
      test('returns correct symbol for EUR', () {
        expect(CurrencyData.getSymbol('EUR'), equals('\u20AC')); // Euro sign
      });

      test('returns correct symbol for USD', () {
        expect(CurrencyData.getSymbol('USD'), equals('\$'));
      });

      test('returns correct symbol for GBP', () {
        expect(CurrencyData.getSymbol('GBP'), equals('\u00A3')); // Pound sign
      });

      test('handles lowercase currency codes', () {
        expect(CurrencyData.getSymbol('eur'), equals('\u20AC'));
        expect(CurrencyData.getSymbol('usd'), equals('\$'));
      });

      test('handles mixed case currency codes', () {
        expect(CurrencyData.getSymbol('Eur'), equals('\u20AC'));
        expect(CurrencyData.getSymbol('uSd'), equals('\$'));
      });

      test('returns code as fallback for unknown currency', () {
        expect(CurrencyData.getSymbol('XYZ'), equals('XYZ'));
        expect(CurrencyData.getSymbol('UNKNOWN'), equals('UNKNOWN'));
      });

      test('returns correct symbols for various currencies', () {
        expect(CurrencyData.getSymbol('INR'), equals('\u20B9')); // Rupee sign
        expect(CurrencyData.getSymbol('JPY'), equals('\u00A5')); // Yen sign
        expect(CurrencyData.getSymbol('CNY'), equals('\u00A5')); // Yuan also uses yen sign
      });
    });

    group('getByCode', () {
      test('returns CurrencyData for known currency', () {
        final eur = CurrencyData.getByCode('EUR');
        expect(eur, isNotNull);
        expect(eur!.code, equals('EUR'));
        expect(eur.symbol, equals('\u20AC'));
        expect(eur.name, equals('Euro'));
      });

      test('returns null for unknown currency', () {
        expect(CurrencyData.getByCode('XYZ'), isNull);
        expect(CurrencyData.getByCode(''), isNull);
      });

      test('handles lowercase codes', () {
        final usd = CurrencyData.getByCode('usd');
        expect(usd, isNotNull);
        expect(usd!.code, equals('USD'));
      });
    });

    group('getSymbolPrefix', () {
      test('returns symbol with trailing space', () {
        expect(CurrencyData.getSymbolPrefix('EUR'), equals('\u20AC '));
        expect(CurrencyData.getSymbolPrefix('USD'), equals('\$ '));
      });

      test('returns code with space for unknown currency', () {
        expect(CurrencyData.getSymbolPrefix('XYZ'), equals('XYZ '));
      });
    });

    group('allCodes', () {
      test('returns list of all currency codes', () {
        final codes = CurrencyData.allCodes;
        expect(codes, isA<List<String>>());
        expect(codes, contains('EUR'));
        expect(codes, contains('USD'));
        expect(codes.length, equals(CurrencyData.all.length));
      });
    });

    group('search', () {
      test('returns all currencies for empty query', () {
        final results = CurrencyData.search('');
        expect(results.length, equals(CurrencyData.all.length));
      });

      test('finds currency by code', () {
        final results = CurrencyData.search('EUR');
        expect(results.any((c) => c.code == 'EUR'), isTrue);
      });

      test('finds currency by partial code', () {
        final results = CurrencyData.search('EU');
        expect(results.any((c) => c.code == 'EUR'), isTrue);
      });

      test('finds currency by name', () {
        final results = CurrencyData.search('Dollar');
        expect(results.any((c) => c.code == 'USD'), isTrue);
        expect(results.any((c) => c.code == 'CAD'), isTrue);
        expect(results.any((c) => c.code == 'AUD'), isTrue);
      });

      test('search is case-insensitive', () {
        final resultsLower = CurrencyData.search('euro');
        final resultsUpper = CurrencyData.search('EURO');
        expect(resultsLower.any((c) => c.code == 'EUR'), isTrue);
        expect(resultsUpper.any((c) => c.code == 'EUR'), isTrue);
      });

      test('returns empty list when no match', () {
        final results = CurrencyData.search('xyz123');
        expect(results, isEmpty);
      });
    });

    group('toString', () {
      test('returns formatted string with code and name', () {
        final eur = CurrencyData.getByCode('EUR')!;
        expect(eur.toString(), equals('EUR - Euro'));
      });
    });

    group('Coverage of regional currencies', () {
      test('includes Asian currencies', () {
        final codes = CurrencyData.allCodes;
        expect(codes, contains('INR'));
        expect(codes, contains('JPY'));
        expect(codes, contains('CNY'));
        expect(codes, contains('KRW'));
        expect(codes, contains('SGD'));
      });

      test('includes Middle Eastern currencies', () {
        final codes = CurrencyData.allCodes;
        expect(codes, contains('AED'));
        expect(codes, contains('SAR'));
        expect(codes, contains('ILS'));
      });

      test('includes American currencies', () {
        final codes = CurrencyData.allCodes;
        expect(codes, contains('CAD'));
        expect(codes, contains('MXN'));
        expect(codes, contains('BRL'));
      });

      test('includes European non-Euro currencies', () {
        final codes = CurrencyData.allCodes;
        expect(codes, contains('SEK'));
        expect(codes, contains('NOK'));
        expect(codes, contains('PLN'));
        expect(codes, contains('CHF'));
      });

      test('includes African currencies', () {
        final codes = CurrencyData.allCodes;
        expect(codes, contains('ZAR'));
        expect(codes, contains('EGP'));
        expect(codes, contains('NGN'));
      });

      test('includes Oceanian currencies', () {
        final codes = CurrencyData.allCodes;
        expect(codes, contains('AUD'));
        expect(codes, contains('NZD'));
      });
    });
  });
}
