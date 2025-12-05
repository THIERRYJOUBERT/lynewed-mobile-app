/// Distance formatting utilities
/// 
/// Centralized distance formatting with unit conversion support.
/// Uses user's preferred unit from FFAppState.
library;

import '/core/services/distance_service.dart';

/// Distance formatter with automatic unit conversion
/// 
/// Usage:
/// ```dart
/// // Format with user's preferred unit
/// final formatted = DistanceFormatter.format(10.5); // "10.5 km" or "6.5 mi"
/// 
/// // Format for slider display
/// final label = DistanceFormatter.formatForSlider(50); // "50 km" or "31 mi"
/// ```
class DistanceFormatter {
  DistanceFormatter._();

  static final _service = DistanceService.instance;

  /// Get user's preferred unit abbreviation
  static String get unitAbbreviation => _service.unitAbbreviation;

  /// Check if user prefers miles
  static bool get usesMiles => _service.usesMiles;

  /// Format distance from km to user's preferred unit
  /// 
  /// [distanceKm] - Distance in kilometers
  static String format(double distanceKm, {bool showUnit = true}) {
    return _service.formatDistance(distanceKm, showUnit: showUnit);
  }

  /// Format distance with null safety
  static String? formatOrNull(double? distanceKm, {bool showUnit = true}) {
    if (distanceKm == null) return null;
    return format(distanceKm, showUnit: showUnit);
  }

  /// Format a distance range
  static String formatRange(double minKm, double maxKm, {bool showUnit = true}) {
    return _service.formatDistanceRange(minKm, maxKm, showUnit: showUnit);
  }

  /// Convert km to user's unit (for slider values)
  static double convertFromKm(double km) {
    return _service.convertFromKm(km);
  }

  /// Convert from user's unit to km (for backend)
  static double convertToKm(double value) {
    return _service.convertToKm(value);
  }

  /// Get max slider value in user's unit
  static double get maxSliderValue => _service.maxSliderValue;

  /// Get slider step in user's unit
  static double get sliderStep => _service.sliderStep;

  /// Get slider divisions
  static int get sliderDivisions => _service.sliderDivisions;

  /// Format value for slider label
  static String formatForSlider(double value) {
    return _service.formatSliderValue(value);
  }
}
