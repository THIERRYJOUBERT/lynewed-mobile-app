// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class SimpleDistanceSlider extends StatefulWidget {
  const SimpleDistanceSlider({
    super.key,
    this.width,
    this.height,
    this.minValue,
    this.maxValue,
    this.initialValue,
    this.step = 1.0,
    this.unitLabel = ' km',
    this.onChanged,
  });

  final double? width;
  final double? height;
  final double? minValue;
  final double? maxValue;
  final double? initialValue;
  final double step;
  final String unitLabel;
  final Function(double)? onChanged;

  @override
  _SimpleDistanceSliderState createState() => _SimpleDistanceSliderState();
}

class _SimpleDistanceSliderState extends State<SimpleDistanceSlider> {
  late double _currentValue;
  late double _minValue;
  late double _maxValue;

  @override
  void initState() {
    super.initState();
    _minValue = widget.minValue ?? 0.0;
    _maxValue = widget.maxValue ?? 100.0;
    _currentValue = widget.initialValue ?? 20.0;

    if (_currentValue < _minValue) _currentValue = _minValue;
    if (_currentValue > _maxValue) _currentValue = _maxValue;
  }

  String _formatValue(double value) {
    return '${value.toStringAsFixed(0)}${widget.unitLabel}';
  }

  @override
  Widget build(BuildContext context) {
    final int divisions = ((_maxValue - _minValue) / widget.step).round();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _formatValue(_currentValue),
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ),

          // Le Slider est déjà responsive par nature
          Slider(
            value: _currentValue,
            min: _minValue,
            max: _maxValue,
            divisions: divisions > 0 ? divisions : null,
            activeColor: FlutterFlowTheme.of(context).primaryText,
            inactiveColor: FlutterFlowTheme.of(context).alternate,
            label: _formatValue(_currentValue),
            onChanged: (double newValue) {
              setState(() {
                _currentValue = (newValue / widget.step).round() * widget.step;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(_currentValue);
              }
            },
          ),

          // **LA CORRECTION EST ICI**
          // On utilise Expanded pour que les labels se partagent l'espace
          // de manière flexible au lieu de déborder.
          Padding(
            // Le padding doit être un peu moins grand que celui du track du slider
            // pour un alignement parfait visuellement.
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Ce widget prend la moitié gauche de l'espace...
                Expanded(
                  child: Align(
                    // ... et aligne son texte à gauche.
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatValue(_minValue),
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Neue Haas Grotesk Text',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
                // Ce widget prend la moitié droite de l'espace...
                Expanded(
                  child: Align(
                    // ... et aligne son texte à droite.
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatValue(_maxValue),
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Neue Haas Grotesk Text',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 12,
                          ),
                    ),
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
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
