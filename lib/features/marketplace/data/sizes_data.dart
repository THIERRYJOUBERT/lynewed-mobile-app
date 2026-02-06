/// Size guide data for the marketplace listing form.
///
/// Contains size options for dresses and shoes with international equivalents.
library;

/// Represents a size option with a value for storage and a label for display.
class SizeOption {
  /// Creates a size option.
  const SizeOption({required this.value, required this.label});

  /// The value stored in the database (e.g., 'XS', '36').
  final String value;

  /// The display label with international equivalents (e.g., 'XS (EU 32-34 / US 0-2)').
  final String label;
}

/// Available dress sizes with international equivalents.
const List<SizeOption> dressSizes = [
  SizeOption(value: 'XS', label: 'XS (EU 32-34 / US 0-2)'),
  SizeOption(value: 'S', label: 'S (EU 36-38 / US 4-6)'),
  SizeOption(value: 'M', label: 'M (EU 40-42 / US 8-10)'),
  SizeOption(value: 'L', label: 'L (EU 44-46 / US 12-14)'),
  SizeOption(value: 'XL', label: 'XL (EU 48-50 / US 16-18)'),
];

/// Available shoe sizes with international equivalents.
const List<SizeOption> shoeSizes = [
  SizeOption(value: '35', label: '35 (US 4 / UK 2.5)'),
  SizeOption(value: '36', label: '36 (US 5 / UK 3.5)'),
  SizeOption(value: '37', label: '37 (US 6 / UK 4.5)'),
  SizeOption(value: '38', label: '38 (US 7 / UK 5.5)'),
  SizeOption(value: '39', label: '39 (US 8 / UK 6.5)'),
  SizeOption(value: '40', label: '40 (US 9 / UK 7.5)'),
  SizeOption(value: '41', label: '41 (US 10 / UK 8.5)'),
  SizeOption(value: '42', label: '42 (US 11 / UK 9.5)'),
];

/// Returns the appropriate size list for the given category.
List<SizeOption> getSizesForCategory(String category) {
  switch (category) {
    case 'dress':
      return dressSizes;
    case 'shoes':
      return shoeSizes;
    default:
      return dressSizes;
  }
}

/// Valid sleeve length options for dresses.
const List<String> sleeveLengthOptions = [
  'long',
  '3-4',
  'short',
  'cap',
  'sleeveless',
  'strapless',
];

/// Display labels for sleeve length options.
const Map<String, String> sleeveLengthLabels = {
  'long': 'Long',
  '3-4': '3/4 Length',
  'short': 'Short',
  'cap': 'Cap',
  'sleeveless': 'Sleeveless',
  'strapless': 'Strapless',
};

/// Valid condition options for listings.
const List<String> conditionOptions = [
  'new',
  'excellent',
  'good',
  'fair',
];

/// Display labels for condition options.
const Map<String, String> conditionLabels = {
  'new': 'New',
  'excellent': 'Excellent',
  'good': 'Good',
  'fair': 'Fair',
};

/// Valid listing categories.
const List<String> categoryOptions = ['dress', 'shoes'];

/// Display labels for categories.
const Map<String, String> categoryLabels = {
  'dress': 'Dress',
  'shoes': 'Shoes',
};

/// Represents a country with its ISO 3166-1 alpha-2 code and display name.
class CountryOption {
  /// Creates a country option.
  const CountryOption({required this.code, required this.name});

  /// ISO 3166-1 alpha-2 country code (e.g., 'US', 'FR').
  final String code;

  /// Full display name (e.g., 'United States', 'France').
  final String name;
}

/// Available countries for the marketplace with ISO codes.
const List<CountryOption> marketplaceCountries = [
  CountryOption(code: 'US', name: 'United States'),
  CountryOption(code: 'GB', name: 'United Kingdom'),
  CountryOption(code: 'FR', name: 'France'),
  CountryOption(code: 'DE', name: 'Germany'),
  CountryOption(code: 'IT', name: 'Italy'),
  CountryOption(code: 'ES', name: 'Spain'),
  CountryOption(code: 'CA', name: 'Canada'),
  CountryOption(code: 'AU', name: 'Australia'),
  CountryOption(code: 'NL', name: 'Netherlands'),
  CountryOption(code: 'BE', name: 'Belgium'),
  CountryOption(code: 'CH', name: 'Switzerland'),
  CountryOption(code: 'AT', name: 'Austria'),
  CountryOption(code: 'PT', name: 'Portugal'),
  CountryOption(code: 'IE', name: 'Ireland'),
  CountryOption(code: 'SE', name: 'Sweden'),
];

/// Available countries for listing location (backward-compatible string list).
List<String> get countryOptions =>
    marketplaceCountries.map((c) => c.name).toList();

/// Returns the country code for a given country name, or null if not found.
String? countryCodeFromName(String? name) {
  if (name == null) return null;
  final match = marketplaceCountries
      .where((c) => c.name.toLowerCase() == name.toLowerCase());
  return match.isNotEmpty ? match.first.code : null;
}

/// Returns the country name for a given country code, or null if not found.
String? countryNameFromCode(String? code) {
  if (code == null) return null;
  final match = marketplaceCountries
      .where((c) => c.code.toLowerCase() == code.toLowerCase());
  return match.isNotEmpty ? match.first.name : null;
}

/// European country codes for region-based shipping calculation.
const Set<String> _europeanCountries = {
  'GB', 'FR', 'DE', 'IT', 'ES', 'NL', 'BE', 'CH', 'AT', 'PT', 'IE', 'SE',
};

/// North American country codes for region-based shipping calculation.
const Set<String> _northAmericanCountries = {'US', 'CA'};

/// Flat-rate shipping costs for the marketplace.
///
/// Rates are based on origin and destination country pair:
/// - Same country: $15 (1500 cents), 3-5 business days
/// - Same region (Europe↔Europe, NorthAmerica↔NorthAmerica): $25 (2500 cents), 5-7 days
/// - International (cross-region): $35 (3500 cents), 7-14 days
class MarketplaceShippingCosts {
  MarketplaceShippingCosts._();

  /// Shipping cost in cents for same country.
  static const int sameCountryCents = 1500;

  /// Shipping cost in cents for same region.
  static const int sameRegionCents = 2500;

  /// Shipping cost in cents for international.
  static const int internationalCents = 3500;

  /// Calculates the shipping cost in cents between two country codes.
  static int calculateCents(String fromCode, String toCode) {
    final from = fromCode.toUpperCase();
    final to = toCode.toUpperCase();

    if (from == to) return sameCountryCents;
    if (_sameRegion(from, to)) return sameRegionCents;
    return internationalCents;
  }

  /// Returns the estimated delivery days as a display string.
  static String estimatedDays(String fromCode, String toCode) {
    final from = fromCode.toUpperCase();
    final to = toCode.toUpperCase();

    if (from == to) return '3-5 business days';
    if (_sameRegion(from, to)) return '5-7 business days';
    return '7-14 business days';
  }

  /// Returns a human-readable label for the shipping tier.
  static String tierLabel(String fromCode, String toCode) {
    final from = fromCode.toUpperCase();
    final to = toCode.toUpperCase();

    if (from == to) return 'Domestic Shipping';
    if (_sameRegion(from, to)) return 'Regional Shipping';
    return 'International Shipping';
  }

  static bool _sameRegion(String from, String to) {
    if (_europeanCountries.contains(from) &&
        _europeanCountries.contains(to)) {
      return true;
    }
    if (_northAmericanCountries.contains(from) &&
        _northAmericanCountries.contains(to)) {
      return true;
    }
    return false;
  }
}
