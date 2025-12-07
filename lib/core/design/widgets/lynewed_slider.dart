import 'package:flutter/material.dart';
import '../design.dart';

/// Single value slider widget styled like the filter sheet's budget range slider.
/// Displays value indicator above the thumb and min/max labels below.
class LynewedSlider extends StatefulWidget {
  const LynewedSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.steps,
    this.formatValue,
    this.suffix = '',
  });

  final int value;
  final ValueChanged<int> onChanged;
  /// Step values for the slider (e.g., [5, 10, 20, 50, 100] for km)
  final List<int> steps;
  /// Custom value formatter
  final String Function(int)? formatValue;
  /// Suffix for display (e.g., 'km')
  final String suffix;

  @override
  State<LynewedSlider> createState() => _LynewedSliderState();
}

class _LynewedSliderState extends State<LynewedSlider> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(LynewedSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  int _getStepIndex(int value) {
    final idx = widget.steps.indexOf(value);
    return idx >= 0 ? idx : 0;
  }

  String _formatValue(int value) {
    if (widget.formatValue != null) {
      return widget.formatValue!(value);
    }
    return '$value${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.black,
              inactiveTrackColor: const Color(0xFFE0E0E0),
              thumbColor: Colors.black,
              overlayColor: Colors.black.withValues(alpha: 0.1),
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
              valueIndicatorColor: const Color(0xFF4B4B4B),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: Slider(
              value: _getStepIndex(_currentValue).toDouble(),
              min: 0,
              max: (widget.steps.length - 1).toDouble(),
              divisions: widget.steps.length - 1,
              label: _formatValue(_currentValue),
              onChanged: (v) {
                final newValue = widget.steps[v.round()];
                setState(() => _currentValue = newValue);
                widget.onChanged(newValue);
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
                  _formatValue(widget.steps.first),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  _formatValue(widget.steps.last),
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
