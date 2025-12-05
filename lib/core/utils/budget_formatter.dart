/// Budget formatting utilities
/// 
/// Centralized budget formatting with currency conversion support.
/// Uses user's preferred currency from FFAppState.
library;

import '/flutter_flow/flutter_flow_util.dart';
import '/core/services/currency_service.dart';
import '/core/constants/currencies.dart';

/// Budget formatter with automatic currency conversion
/// 
/// Usage:
/// ```dart
/// // Format with user's preferred currency
/// final formatted = BudgetFormatter.format(
///   min: 1000,
///   max: 2000,
///   sourceCurrency: 'EUR',
/// );
/// 
/// // Or with explicit display currency
/// final formatted = BudgetFormatter.formatWithCurrency(
///   min: 1000,
///   max: 2000,
///   sourceCurrency: 'EUR',
///   displayCurrency: 'USD',
/// );
/// ```
class BudgetFormatter {
  BudgetFormatter._();

  /// Get user's preferred currency from app state
  static String get userCurrency {
    final prefs = FFAppState().currentUserPreferences;
    final currency = prefs.currency;
    return currency.isNotEmpty ? currency : 'EUR';
  }

  /// Format budget range using user's preferred currency
  /// 
  /// Automatically converts from source currency to user's preferred currency.
  static String format({
    int? min,
    int? max,
    required String sourceCurrency,
  }) {
    return formatWithCurrency(
      min: min,
      max: max,
      sourceCurrency: sourceCurrency,
      displayCurrency: userCurrency,
    );
  }

  /// Format budget range with explicit display currency
  static String formatWithCurrency({
    int? min,
    int? max,
    required String sourceCurrency,
    required String displayCurrency,
  }) {
    return CurrencyService.instance.formatBudgetRange(
      budgetMin: min,
      budgetMax: max,
      sourceCurrency: sourceCurrency,
      displayCurrency: displayCurrency,
    );
  }

  /// Format a single amount with currency conversion
  static String formatAmount(
    int amount, {
    required String sourceCurrency,
    String? displayCurrency,
  }) {
    final targetCurrency = displayCurrency ?? userCurrency;
    final service = CurrencyService.instance;
    
    final sourceCode = sourceCurrency.toUpperCase();
    final targetCode = targetCurrency.toUpperCase();
    final symbol = CurrencyData.getSymbol(targetCode);
    
    if (sourceCode == targetCode) {
      return '${_formatNumber(amount)} $symbol';
    }
    
    final converted = service.convertRounded(amount, from: sourceCode, to: targetCode);
    if (converted == null) {
      // Fallback to original currency if conversion fails
      return '${_formatNumber(amount)} ${CurrencyData.getSymbol(sourceCode)}';
    }
    
    return '≈ ${_formatNumber(converted)} $symbol';
  }

  /// Format number with k suffix for thousands
  static String _formatNumber(int n) {
    if (n >= 1000) {
      final k = n / 1000;
      return k == k.roundToDouble() ? '${k.round()}k' : '${k.toStringAsFixed(1)}k';
    }
    return n.toString();
  }
}
