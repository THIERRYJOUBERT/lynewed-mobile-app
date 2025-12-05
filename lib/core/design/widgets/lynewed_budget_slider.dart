/// Budget Range Slider with automatic currency adaptation
/// 
/// Unified budget slider that automatically adapts its range and step
/// based on the user's preferred currency.
/// 
/// Features:
/// - Automatic range calculation based on currency (EUR 50K → INR 5M)
/// - Smart step values for each currency magnitude
/// - Formatted labels with K/M suffixes
/// - Converts values to EUR for backend filtering
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '/core/services/currency_service.dart';
import '/core/utils/budget_formatter.dart';

/// Callback with budget values in user's currency
typedef OnBudgetChanged = void Function(double min, double max);

/// Unified budget range slider with currency awareness
/// 
/// Usage:
/// ```dart
/// LynewedBudgetSlider(
///   lowerValue: _budgetMin,
///   upperValue: _budgetMax,
///   onChanged: (min, max) {
///     setState(() {
///       _budgetMin = min;
///       _budgetMax = max;
///     });
///   },
/// )
/// ```
class LynewedBudgetSlider extends StatefulWidget {
  const LynewedBudgetSlider({
    super.key,
    required this.lowerValue,
    required this.upperValue,
    required this.onChanged,
    this.currency, // If null, uses user's preferred currency
  });

  /// Current lower value (in user's currency)
  final double lowerValue;
  
  /// Current upper value (in user's currency)
  final double upperValue;
  
  /// Callback when values change
  final OnBudgetChanged onChanged;
  
  /// Override currency (defaults to user's preferred currency)
  final String? currency;

  @override
  State<LynewedBudgetSlider> createState() => _LynewedBudgetSliderState();
}

class _LynewedBudgetSliderState extends State<LynewedBudgetSlider> {
  late double _lowerValue;
  late double _upperValue;
  
  final _currencyService = CurrencyService.instance;
  
  String get _currency => widget.currency ?? BudgetFormatter.userCurrency;
  double get _maxValue => _currencyService.getMaxBudgetForCurrency(_currency);
  double get _step => _currencyService.getStepForCurrency(_currency);
  int get _divisions => _currencyService.getDivisionsForCurrency(_currency);

  @override
  void initState() {
    super.initState();
    _lowerValue = widget.lowerValue.clamp(0, _maxValue);
    _upperValue = widget.upperValue.clamp(0, _maxValue);
  }

  @override
  void didUpdateWidget(LynewedBudgetSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if currency changed
    final oldCurrency = oldWidget.currency ?? BudgetFormatter.userCurrency;
    if (oldCurrency != _currency) {
      // Convert values to new currency
      final oldMax = _currencyService.getMaxBudgetForCurrency(oldCurrency);
      final newMax = _maxValue;
      
      // Scale proportionally
      _lowerValue = (_lowerValue / oldMax * newMax).clamp(0, newMax);
      _upperValue = (_upperValue / oldMax * newMax).clamp(0, newMax);
      
      // Snap to new step
      _lowerValue = (_lowerValue / _step).round() * _step;
      _upperValue = (_upperValue / _step).round() * _step;
    } else {
      // Just update values if they changed externally
      if (oldWidget.lowerValue != widget.lowerValue) {
        _lowerValue = widget.lowerValue.clamp(0, _maxValue);
      }
      if (oldWidget.upperValue != widget.upperValue) {
        _upperValue = widget.upperValue.clamp(0, _maxValue);
      }
    }
  }

  String _formatValue(double value) {
    return _currencyService.formatBudgetValue(value, _currency);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Range Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: LynewedColors.primary,
            inactiveTrackColor: LynewedColors.gray200,
            thumbColor: LynewedColors.primary,
            overlayColor: LynewedColors.primary.withValues(alpha: 0.1),
            trackHeight: 4.0,
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 2,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            rangeValueIndicatorShape: const RectangularRangeSliderValueIndicatorShape(),
            valueIndicatorColor: LynewedColors.primary,
            valueIndicatorTextStyle: LynewedTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: RangeSlider(
            values: RangeValues(_lowerValue, _upperValue),
            min: 0,
            max: _maxValue,
            divisions: _divisions,
            labels: RangeLabels(
              _formatValue(_lowerValue),
              _formatValue(_upperValue),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _lowerValue = (values.start / _step).round() * _step;
                _upperValue = (values.end / _step).round() * _step;
              });
              widget.onChanged(_lowerValue, _upperValue);
            },
          ),
        ),
        
        // Min/Max labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatValue(0),
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                _formatValue(_maxValue),
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Extension to get budget filter values in EUR for backend
extension BudgetSliderExtension on LynewedBudgetSlider {
  /// Convert current values to EUR for backend filtering
  /// 
  /// Returns (minEur, maxEur) tuple
  static (double, double) toEurForFilter(
    double min,
    double max,
    String fromCurrency,
  ) {
    final service = CurrencyService.instance;
    final minEur = service.convertBudgetForFilter(min, from: fromCurrency, to: 'EUR') ?? min;
    final maxEur = service.convertBudgetForFilter(max, from: fromCurrency, to: 'EUR') ?? max;
    return (minEur, maxEur);
  }
}
