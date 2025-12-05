/// Distance Range Slider with automatic unit adaptation
/// 
/// Unified distance slider that automatically adapts its range and labels
/// based on the user's preferred unit (km or miles).
/// 
/// Features:
/// - Automatic range calculation based on unit
/// - Smart step values
/// - Formatted labels with unit abbreviation
/// - Converts values to km for backend
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '/core/services/distance_service.dart';
import '/core/utils/distance_formatter.dart';

/// Callback with distance value in user's unit
typedef OnDistanceChanged = void Function(double value);

/// Unified distance slider with unit awareness
/// 
/// Usage:
/// ```dart
/// LynewedDistanceSlider(
///   value: _radiusKm,
///   onChanged: (value) {
///     setState(() => _radiusKm = value);
///   },
/// )
/// ```
class LynewedDistanceSlider extends StatefulWidget {
  const LynewedDistanceSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 0,
    this.maxValueKm,
    this.showPresets = false,
  });

  /// Current value in km (backend unit)
  final double value;
  
  /// Callback when value changes (returns value in km)
  final OnDistanceChanged onChanged;
  
  /// Minimum value (in user's unit)
  final double minValue;
  
  /// Maximum value in km (if null, uses service default)
  final double? maxValueKm;
  
  /// Show preset buttons
  final bool showPresets;

  @override
  State<LynewedDistanceSlider> createState() => _LynewedDistanceSliderState();
}

class _LynewedDistanceSliderState extends State<LynewedDistanceSlider> {
  late double _value;
  
  final _service = DistanceService.instance;
  
  double get _maxValue {
    if (widget.maxValueKm != null) {
      return DistanceFormatter.convertFromKm(widget.maxValueKm!);
    }
    return _service.maxSliderValue;
  }
  
  double get _step => _service.sliderStep;
  int get _divisions => (_maxValue / _step).round();
  String get _unit => _service.unitAbbreviation;

  @override
  void initState() {
    super.initState();
    // Convert km value to user's unit for display
    _value = DistanceFormatter.convertFromKm(widget.value).clamp(widget.minValue, _maxValue);
  }

  @override
  void didUpdateWidget(LynewedDistanceSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = DistanceFormatter.convertFromKm(widget.value).clamp(widget.minValue, _maxValue);
    }
  }

  String _formatValue(double value) {
    return '${value.round()} $_unit';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Presets (optional)
        if (widget.showPresets) ...[
          _buildPresets(),
          const SizedBox(height: 16),
        ],
        
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: LynewedColors.primary,
            inactiveTrackColor: LynewedColors.gray200,
            thumbColor: LynewedColors.primary,
            overlayColor: LynewedColors.primary.withValues(alpha: 0.1),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 2,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
            valueIndicatorColor: LynewedColors.primary,
            valueIndicatorTextStyle: LynewedTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: Slider(
            value: _value,
            min: widget.minValue,
            max: _maxValue,
            divisions: _divisions,
            label: _formatValue(_value),
            onChanged: (value) {
              setState(() {
                _value = (value / _step).round() * _step;
              });
              // Convert back to km for callback
              final kmValue = DistanceFormatter.convertToKm(_value);
              widget.onChanged(kmValue);
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
                _formatValue(widget.minValue),
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

  Widget _buildPresets() {
    final presets = _service.distancePresets;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) {
        final isSelected = (_value - preset).abs() < _step;
        return GestureDetector(
          onTap: () {
            setState(() => _value = preset);
            final kmValue = DistanceFormatter.convertToKm(preset);
            widget.onChanged(kmValue);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? LynewedColors.primary : LynewedColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? LynewedColors.primary : LynewedColors.border,
              ),
            ),
            child: Text(
              _formatValue(preset),
              style: LynewedTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : LynewedColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
