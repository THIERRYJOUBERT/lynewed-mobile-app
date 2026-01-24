/// Centralized currency definitions for the entire app
///
/// Use [CurrencyData.all] for dropdown lists
/// Use [CurrencyData.getSymbol] for display
class CurrencyData {
  final String code;
  final String symbol;
  final String name;

  const CurrencyData({
    required this.code,
    required this.symbol,
    required this.name,
  });

  /// All supported currencies, sorted by most common first
  static const List<CurrencyData> all = [
    // Major currencies (most common)
    CurrencyData(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyData(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyData(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyData(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc'),
    
    // Asia & Middle East
    CurrencyData(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    CurrencyData(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    CurrencyData(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
    CurrencyData(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    CurrencyData(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    CurrencyData(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
    CurrencyData(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
    CurrencyData(code: 'HKD', symbol: 'HK\$', name: 'Hong Kong Dollar'),
    CurrencyData(code: 'THB', symbol: '฿', name: 'Thai Baht'),
    CurrencyData(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit'),
    CurrencyData(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah'),
    CurrencyData(code: 'PHP', symbol: '₱', name: 'Philippine Peso'),
    CurrencyData(code: 'VND', symbol: '₫', name: 'Vietnamese Dong'),
    CurrencyData(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee'),
    CurrencyData(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka'),
    CurrencyData(code: 'LKR', symbol: 'Rs', name: 'Sri Lankan Rupee'),
    CurrencyData(code: 'ILS', symbol: '₪', name: 'Israeli Shekel'),
    CurrencyData(code: 'TRY', symbol: '₺', name: 'Turkish Lira'),
    CurrencyData(code: 'QAR', symbol: '﷼', name: 'Qatari Riyal'),
    CurrencyData(code: 'KWD', symbol: 'د.ك', name: 'Kuwaiti Dinar'),
    CurrencyData(code: 'BHD', symbol: 'ب.د', name: 'Bahraini Dinar'),
    CurrencyData(code: 'OMR', symbol: 'ر.ع', name: 'Omani Rial'),
    
    // Americas
    CurrencyData(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
    CurrencyData(code: 'MXN', symbol: 'Mex\$', name: 'Mexican Peso'),
    CurrencyData(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real'),
    CurrencyData(code: 'ARS', symbol: 'AR\$', name: 'Argentine Peso'),
    CurrencyData(code: 'CLP', symbol: 'CLP', name: 'Chilean Peso'),
    CurrencyData(code: 'COP', symbol: 'COL\$', name: 'Colombian Peso'),
    CurrencyData(code: 'PEN', symbol: 'S/', name: 'Peruvian Sol'),
    
    // Europe (non-Euro)
    CurrencyData(code: 'SEK', symbol: 'kr', name: 'Swedish Krona'),
    CurrencyData(code: 'NOK', symbol: 'kr', name: 'Norwegian Krone'),
    CurrencyData(code: 'DKK', symbol: 'kr', name: 'Danish Krone'),
    CurrencyData(code: 'PLN', symbol: 'zł', name: 'Polish Zloty'),
    CurrencyData(code: 'CZK', symbol: 'Kč', name: 'Czech Koruna'),
    CurrencyData(code: 'HUF', symbol: 'Ft', name: 'Hungarian Forint'),
    CurrencyData(code: 'RON', symbol: 'lei', name: 'Romanian Leu'),
    CurrencyData(code: 'BGN', symbol: 'лв', name: 'Bulgarian Lev'),
    CurrencyData(code: 'HRK', symbol: 'kn', name: 'Croatian Kuna'),
    CurrencyData(code: 'RUB', symbol: '₽', name: 'Russian Ruble'),
    CurrencyData(code: 'UAH', symbol: '₴', name: 'Ukrainian Hryvnia'),
    
    // Oceania
    CurrencyData(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    CurrencyData(code: 'NZD', symbol: 'NZ\$', name: 'New Zealand Dollar'),
    
    // Africa
    CurrencyData(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
    CurrencyData(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound'),
    CurrencyData(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
    CurrencyData(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling'),
    CurrencyData(code: 'MAD', symbol: 'د.م', name: 'Moroccan Dirham'),
    CurrencyData(code: 'TND', symbol: 'د.ت', name: 'Tunisian Dinar'),
  ];

  /// Get currency by code
  static CurrencyData? getByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  /// Get symbol for a currency code
  static String getSymbol(String code) {
    return getByCode(code)?.symbol ?? code;
  }

  /// Get display string with symbol prefix
  static String getSymbolPrefix(String code) {
    final symbol = getSymbol(code);
    return '$symbol ';
  }

  /// Get all currency codes
  static List<String> get allCodes => all.map((c) => c.code).toList();

  /// Search currencies by code or name
  static List<CurrencyData> search(String query) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((c) => 
      c.code.toLowerCase().contains(q) || 
      c.name.toLowerCase().contains(q)
    ).toList();
  }

  @override
  String toString() => '$code - $name';
}
