/// Currency conversion service
/// 
/// Provides currency conversion with approximate exchange rates.
/// Rates are relative to EUR (base currency).
/// 
/// NOTE: For production, consider integrating a real-time exchange rate API.
/// Current rates are approximate and updated manually.
library;

import '/core/constants/currencies.dart';

/// Currency conversion service with static exchange rates
/// 
/// Usage:
/// ```dart
/// final service = CurrencyService();
/// final converted = service.convert(1000, from: 'EUR', to: 'USD');
/// final formatted = service.formatBudget(1000, 2000, 'EUR', displayCurrency: 'USD');
/// ```
class CurrencyService {
  CurrencyService._();
  static final CurrencyService instance = CurrencyService._();
  factory CurrencyService() => instance;

  /// Exchange rates relative to EUR (1 EUR = X currency)
  /// Updated: December 2024 (approximate rates)
  static const Map<String, double> _ratesFromEur = {
    'EUR': 1.0,
    'USD': 1.08,
    'GBP': 0.86,
    'CHF': 0.94,
    'INR': 90.0,
    'AED': 3.97,
    'SAR': 4.05,
    'JPY': 162.0,
    'CNY': 7.80,
    'KRW': 1420.0,
    'SGD': 1.45,
    'HKD': 8.45,
    'THB': 38.0,
    'MYR': 5.10,
    'IDR': 17000.0,
    'PHP': 60.0,
    'VND': 26500.0,
    'PKR': 302.0,
    'BDT': 119.0,
    'LKR': 350.0,
    'ILS': 4.0,
    'TRY': 35.0,
    'QAR': 3.93,
    'KWD': 0.33,
    'BHD': 0.41,
    'OMR': 0.42,
    'CAD': 1.47,
    'MXN': 18.5,
    'BRL': 5.30,
    'ARS': 980.0,
    'CLP': 960.0,
    'COP': 4300.0,
    'PEN': 4.05,
    'SEK': 11.3,
    'NOK': 11.6,
    'DKK': 7.46,
    'PLN': 4.32,
    'CZK': 25.3,
    'HUF': 395.0,
    'RON': 4.97,
    'BGN': 1.96,
    'HRK': 7.53,
    'RUB': 98.0,
    'UAH': 40.0,
    'AUD': 1.65,
    'NZD': 1.78,
    'ZAR': 19.5,
    'EGP': 33.5,
    'NGN': 870.0,
    'KES': 165.0,
    'MAD': 10.8,
    'TND': 3.35,
  };

  /// Convert amount from one currency to another
  /// 
  /// Returns null if conversion is not possible (unknown currency)
  double? convert(double amount, {required String from, required String to}) {
    final fromCode = from.toUpperCase();
    final toCode = to.toUpperCase();
    
    if (fromCode == toCode) return amount;
    
    final fromRate = _ratesFromEur[fromCode];
    final toRate = _ratesFromEur[toCode];
    
    if (fromRate == null || toRate == null) return null;
    
    // Convert: amount in FROM -> EUR -> TO
    final inEur = amount / fromRate;
    return inEur * toRate;
  }

  /// Convert and round to nearest integer (for budget display)
  int? convertRounded(int amount, {required String from, required String to}) {
    final converted = convert(amount.toDouble(), from: from, to: to);
    if (converted == null) return null;
    
    // Round to nice numbers based on magnitude
    if (converted >= 10000) {
      return (converted / 1000).round() * 1000; // Round to nearest 1000
    } else if (converted >= 1000) {
      return (converted / 100).round() * 100; // Round to nearest 100
    } else if (converted >= 100) {
      return (converted / 10).round() * 10; // Round to nearest 10
    }
    return converted.round();
  }

  /// Format a budget range with optional currency conversion
  /// 
  /// [budgetMin] - Minimum budget (can be null)
  /// [budgetMax] - Maximum budget (can be null)
  /// [sourceCurrency] - Original currency of the budget
  /// [displayCurrency] - Currency to display (user's preferred currency)
  /// 
  /// Returns formatted string like "1,000 - 2,000 €" or "~1,100 - 2,200 $" if converted
  String formatBudgetRange({
    int? budgetMin,
    int? budgetMax,
    required String sourceCurrency,
    required String displayCurrency,
  }) {
    if (budgetMin == null && budgetMax == null) return 'Not specified';
    
    final sourceCode = sourceCurrency.toUpperCase();
    final displayCode = displayCurrency.toUpperCase();
    final symbol = CurrencyData.getSymbol(displayCode);
    final needsConversion = sourceCode != displayCode;
    
    // Convert if needed
    int? displayMin = budgetMin;
    int? displayMax = budgetMax;
    
    if (needsConversion) {
      if (budgetMin != null) {
        displayMin = convertRounded(budgetMin, from: sourceCode, to: displayCode);
      }
      if (budgetMax != null) {
        displayMax = convertRounded(budgetMax, from: sourceCode, to: displayCode);
      }
    }
    
    // Format with thousand separators
    String formatNumber(int n) {
      if (n >= 1000) {
        return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
      }
      return n.toString();
    }
    
    // Build the string
    final prefix = needsConversion ? '≈ ' : '';
    
    if (displayMin == null && displayMax != null) {
      return '${prefix}Up to ${formatNumber(displayMax)} $symbol';
    }
    if (displayMin != null && displayMax == null) {
      return '${prefix}From ${formatNumber(displayMin)} $symbol';
    }
    if (displayMin != null && displayMax != null) {
      return '$prefix${formatNumber(displayMin)} - ${formatNumber(displayMax)} $symbol';
    }
    
    return 'Not specified';
  }

  /// Check if a currency is supported
  bool isSupported(String currencyCode) {
    return _ratesFromEur.containsKey(currencyCode.toUpperCase());
  }

  /// Get exchange rate from EUR
  double? getRateFromEur(String currencyCode) {
    return _ratesFromEur[currencyCode.toUpperCase()];
  }

  // ============================================================
  // BUDGET SLIDER RANGE CONFIGURATION
  // ============================================================
  
  /// Base max budget in EUR (reference currency)
  static const double _baseMaxBudgetEur = 50000.0;
  
  /// Get the maximum budget value for a currency's slider
  /// 
  /// Converts the base EUR max to the target currency and rounds to a nice number.
  /// Example: EUR 50,000 → INR 4,500,000 → rounded to 5,000,000
  double getMaxBudgetForCurrency(String currencyCode) {
    final code = currencyCode.toUpperCase();
    final rate = _ratesFromEur[code];
    
    if (rate == null || code == 'EUR') {
      return _baseMaxBudgetEur;
    }
    
    final converted = _baseMaxBudgetEur * rate;
    return _roundToNiceNumber(converted);
  }
  
  /// Get the step value for budget slider based on currency
  /// 
  /// Returns appropriate step for the currency's magnitude.
  double getStepForCurrency(String currencyCode) {
    final maxBudget = getMaxBudgetForCurrency(currencyCode);
    
    if (maxBudget >= 10000000) return 100000; // 100K steps for very large currencies
    if (maxBudget >= 1000000) return 50000;   // 50K steps
    if (maxBudget >= 100000) return 5000;     // 5K steps
    if (maxBudget >= 50000) return 1000;      // 1K steps
    return 500;                                // 500 steps for small currencies
  }
  
  /// Get number of divisions for the slider
  int getDivisionsForCurrency(String currencyCode) {
    final max = getMaxBudgetForCurrency(currencyCode);
    final step = getStepForCurrency(currencyCode);
    return (max / step).round();
  }
  
  /// Round to a "nice" number for display (e.g., 4,500,000 → 5,000,000)
  double _roundToNiceNumber(double value) {
    if (value >= 10000000) {
      return (value / 1000000).ceil() * 1000000.0; // Round to nearest million
    } else if (value >= 1000000) {
      return (value / 500000).ceil() * 500000.0; // Round to nearest 500K
    } else if (value >= 100000) {
      return (value / 50000).ceil() * 50000.0; // Round to nearest 50K
    } else if (value >= 10000) {
      return (value / 10000).ceil() * 10000.0; // Round to nearest 10K
    }
    return (value / 1000).ceil() * 1000.0; // Round to nearest 1K
  }
  
  /// Format a budget value for display in slider labels
  /// 
  /// Uses K/M suffixes for readability.
  String formatBudgetValue(double value, String currencyCode) {
    final symbol = CurrencyData.getSymbol(currencyCode);
    
    if (value >= 1000000) {
      final millions = value / 1000000;
      if (millions == millions.roundToDouble()) {
        return '${millions.round()}M $symbol';
      }
      return '${millions.toStringAsFixed(1)}M $symbol';
    }
    
    if (value >= 1000) {
      final thousands = value / 1000;
      if (thousands == thousands.roundToDouble()) {
        return '${thousands.round()}K $symbol';
      }
      return '${thousands.toStringAsFixed(1)}K $symbol';
    }
    
    return '${value.round()} $symbol';
  }
  
  /// Convert a budget value from one currency to another for filtering
  /// 
  /// Used when sending filter to backend (convert user's currency to EUR for RPC)
  double? convertBudgetForFilter(double value, {required String from, required String to}) {
    return convert(value, from: from, to: to);
  }
}
