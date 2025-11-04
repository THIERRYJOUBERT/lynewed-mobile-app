// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class CustomRangeSliderWidget extends StatefulWidget {
  const CustomRangeSliderWidget({
    super.key,
    this.width,
    this.height,
    this.minValue,
    this.maxValue,
    this.lowerValue,
    this.upperValue,
    this.onChanged,
  });

  final double? width;
  final double? height;
  final double? minValue;
  final double? maxValue;
  final double? lowerValue;
  final double? upperValue;
  final Function(double, double)? onChanged;

  @override
  _CustomRangeSliderWidgetState createState() =>
      _CustomRangeSliderWidgetState();
}

class _CustomRangeSliderWidgetState extends State<CustomRangeSliderWidget> {
  late double _lowerValue;
  late double _upperValue;
  late double _minValue;
  late double _maxValue;

  final double step = 100.0;

  @override
  void initState() {
    super.initState();
    _minValue = widget.minValue ?? 0.0;
    _maxValue = widget.maxValue ?? 40000.0;
    _lowerValue = widget.lowerValue ?? _minValue;
    _upperValue = widget.upperValue ?? _maxValue;
  }

  String _formatValue(double value) {
    if (value >= 1000) {
      double thousands = value / 1000;
      if (thousands.truncate() == thousands) {
        return '${thousands.truncate()}K';
      }
      return '${thousands.toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  // Fonction pour créer les paliers avec des espaces proportionnels
  List<Widget> _buildPaliersWidgets() {
    final List<double> paliers = [0, 5000, 10000, 20000, 30000, 40000];
    final List<Widget> widgets = [];

    if (paliers.isEmpty) return widgets;

    // Ajoute le premier label (0) sans espace avant
    widgets.add(
      Text(
        _formatValue(paliers.first),
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: 'Neue Haas Grotesk Text',
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 12,
            ),
      ),
    );

    // Boucle pour ajouter un Spacer proportionnel et le label suivant
    for (int i = 1; i < paliers.length; i++) {
      final double previousValue = paliers[i - 1];
      final double currentValue = paliers[i];
      // Le 'flex' est la différence de valeur, ce qui rend l'espace proportionnel
      final int flex = (currentValue - previousValue).round();

      widgets.add(Spacer(flex: flex));
      widgets.add(
        Text(
          _formatValue(currentValue),
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Neue Haas Grotesk Text',
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 12,
              ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final int divisions = ((_maxValue - _minValue) / step).round();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Affiche les valeurs min et max sélectionnées
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatValue(_lowerValue),
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                Text(
                  _formatValue(_upperValue),
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ],
            ),
          ),

          // Le Slider
          RangeSlider(
            values: RangeValues(_lowerValue, _upperValue),
            min: _minValue,
            max: _maxValue,
            divisions: divisions > 0 ? divisions : 1,
            activeColor: FlutterFlowTheme.of(context).primaryText,
            inactiveColor: FlutterFlowTheme.of(context).alternate,
            labels: null,
            onChanged: (RangeValues values) {
              setState(() {
                _lowerValue = (values.start / step).round() * step;
                _upperValue = (values.end / step).round() * step;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(_lowerValue, _upperValue);
              }
            },
          ),

          const SizedBox(height: 4), // Petit espace

          // Les labels des paliers, maintenant parfaitement alignés
          Padding(
            // Le padding horizontal doit correspondre à celui du track du slider
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: _buildPaliersWidgets(),
            ),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
