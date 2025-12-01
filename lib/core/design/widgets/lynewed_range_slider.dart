import 'package:flutter/material.dart';
import '../design.dart';

/// Range slider widget styled like the filter sheet's budget range slider.
/// Displays value indicators above thumbs and dots on the track.
class LynewedRangeSlider extends StatefulWidget {
  const LynewedRangeSlider({
    super.key,
    required this.lowerValue,
    required this.upperValue,
    required this.onChanged,
    this.minValue = 0.0,
    this.maxValue = 40000.0,
    this.step = 100.0,
    this.formatValue,
  });

  final double lowerValue;
  final double upperValue;
  final Function(double lower, double upper) onChanged;
  final double minValue;
  final double maxValue;
  final double step;
  /// Custom value formatter (e.g., for currency display)
  final String Function(double)? formatValue;

  @override
  State<LynewedRangeSlider> createState() => _LynewedRangeSliderState();
}

class _LynewedRangeSliderState extends State<LynewedRangeSlider> {
  late double _lowerValue;
  late double _upperValue;

  @override
  void initState() {
    super.initState();
    _lowerValue = widget.lowerValue;
    _upperValue = widget.upperValue;
  }

  @override
  void didUpdateWidget(LynewedRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lowerValue != widget.lowerValue) {
      _lowerValue = widget.lowerValue;
    }
    if (oldWidget.upperValue != widget.upperValue) {
      _upperValue = widget.upperValue;
    }
  }

  String _formatValue(double value) {
    if (widget.formatValue != null) {
      return widget.formatValue!(value);
    }
    // Default: K format for thousands
    if (value >= 1000) {
      double thousands = value / 1000;
      if (thousands.truncate() == thousands) {
        return '${thousands.truncate()}K';
      }
      return '${thousands.toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final int divisions = ((widget.maxValue - widget.minValue) / widget.step).round();

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Range Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.black,
              inactiveTrackColor: const Color(0xFFE0E0E0),
              thumbColor: Colors.black,
              overlayColor: Colors.black.withOpacity(0.1),
              trackHeight: 4.0,
              rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10, elevation: 2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              rangeValueIndicatorShape: const RectangularRangeSliderValueIndicatorShape(),
              valueIndicatorColor: const Color(0xFF4B4B4B),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: RangeSlider(
              values: RangeValues(_lowerValue, _upperValue),
              min: widget.minValue,
              max: widget.maxValue,
              divisions: divisions > 0 ? divisions : 1,
              labels: RangeLabels(
                _formatValue(_lowerValue),
                _formatValue(_upperValue),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _lowerValue = (values.start / widget.step).round() * widget.step;
                  _upperValue = (values.end / widget.step).round() * widget.step;
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
                  _formatValue(widget.minValue),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  _formatValue(widget.maxValue),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
