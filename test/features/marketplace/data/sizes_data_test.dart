import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/data/sizes_data.dart';

void main() {
  group('CountryOption', () {
    test('stores code and name', () {
      const country = CountryOption(code: 'FR', name: 'France');
      expect(country.code, 'FR');
      expect(country.name, 'France');
    });
  });

  group('marketplaceCountries', () {
    test('contains 15 countries', () {
      expect(marketplaceCountries.length, 15);
    });

    test('all codes are 2-letter uppercase', () {
      for (final c in marketplaceCountries) {
        expect(c.code.length, 2);
        expect(c.code, c.code.toUpperCase());
      }
    });

    test('all names are non-empty', () {
      for (final c in marketplaceCountries) {
        expect(c.name.isNotEmpty, true);
      }
    });

    test('includes US, GB, FR', () {
      final codes = marketplaceCountries.map((c) => c.code).toSet();
      expect(codes, containsAll(['US', 'GB', 'FR']));
    });
  });

  group('countryOptions (backward-compat)', () {
    test('returns list of country names', () {
      final options = countryOptions;
      expect(options, contains('United States'));
      expect(options, contains('France'));
      expect(options.length, 15);
    });
  });

  group('countryCodeFromName', () {
    test('returns code for valid name', () {
      expect(countryCodeFromName('France'), 'FR');
      expect(countryCodeFromName('United States'), 'US');
      expect(countryCodeFromName('United Kingdom'), 'GB');
    });

    test('is case-insensitive', () {
      expect(countryCodeFromName('france'), 'FR');
      expect(countryCodeFromName('FRANCE'), 'FR');
    });

    test('returns null for unknown name', () {
      expect(countryCodeFromName('Narnia'), null);
    });

    test('returns null for null input', () {
      expect(countryCodeFromName(null), null);
    });
  });

  group('countryNameFromCode', () {
    test('returns name for valid code', () {
      expect(countryNameFromCode('FR'), 'France');
      expect(countryNameFromCode('US'), 'United States');
    });

    test('is case-insensitive', () {
      expect(countryNameFromCode('fr'), 'France');
    });

    test('returns null for unknown code', () {
      expect(countryNameFromCode('ZZ'), null);
    });

    test('returns null for null input', () {
      expect(countryNameFromCode(null), null);
    });
  });

  group('MarketplaceShippingCosts', () {
    group('calculateCents', () {
      test('same country returns 1500', () {
        expect(MarketplaceShippingCosts.calculateCents('FR', 'FR'), 1500);
        expect(MarketplaceShippingCosts.calculateCents('US', 'US'), 1500);
      });

      test('same region Europe returns 2500', () {
        expect(MarketplaceShippingCosts.calculateCents('FR', 'DE'), 2500);
        expect(MarketplaceShippingCosts.calculateCents('GB', 'IT'), 2500);
        expect(MarketplaceShippingCosts.calculateCents('ES', 'SE'), 2500);
      });

      test('same region North America returns 2500', () {
        expect(MarketplaceShippingCosts.calculateCents('US', 'CA'), 2500);
        expect(MarketplaceShippingCosts.calculateCents('CA', 'US'), 2500);
      });

      test('cross-region returns 3500', () {
        expect(MarketplaceShippingCosts.calculateCents('US', 'FR'), 3500);
        expect(MarketplaceShippingCosts.calculateCents('FR', 'AU'), 3500);
        expect(MarketplaceShippingCosts.calculateCents('AU', 'US'), 3500);
      });

      test('is case-insensitive', () {
        expect(MarketplaceShippingCosts.calculateCents('fr', 'fr'), 1500);
        expect(MarketplaceShippingCosts.calculateCents('us', 'ca'), 2500);
      });
    });

    group('estimatedDays', () {
      test('same country returns 3-5 business days', () {
        expect(
          MarketplaceShippingCosts.estimatedDays('FR', 'FR'),
          '3-5 business days',
        );
      });

      test('same region returns 5-7 business days', () {
        expect(
          MarketplaceShippingCosts.estimatedDays('FR', 'DE'),
          '5-7 business days',
        );
      });

      test('international returns 7-14 business days', () {
        expect(
          MarketplaceShippingCosts.estimatedDays('US', 'FR'),
          '7-14 business days',
        );
      });
    });

    group('tierLabel', () {
      test('same country returns Domestic Shipping', () {
        expect(
          MarketplaceShippingCosts.tierLabel('US', 'US'),
          'Domestic Shipping',
        );
      });

      test('same region returns Regional Shipping', () {
        expect(
          MarketplaceShippingCosts.tierLabel('FR', 'DE'),
          'Regional Shipping',
        );
      });

      test('international returns International Shipping', () {
        expect(
          MarketplaceShippingCosts.tierLabel('US', 'FR'),
          'International Shipping',
        );
      });
    });

    test('Australia is international to both Europe and North America', () {
      expect(MarketplaceShippingCosts.calculateCents('AU', 'FR'), 3500);
      expect(MarketplaceShippingCosts.calculateCents('AU', 'US'), 3500);
      expect(MarketplaceShippingCosts.calculateCents('AU', 'AU'), 1500);
    });
  });
}
