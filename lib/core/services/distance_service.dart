/// Distance conversion and formatting service
/// 
/// Provides distance conversion between km and miles,
/// and formatting based on user preferences.
library;

import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/enums/enums.dart';

/// Distance conversion service
/// 
/// Usage:
/// ```dart
/// final service = DistanceService.instance;
/// final miles = service.kmToMiles(10.0); // 6.21
/// final formatted = service.formatDistance(10.0); // "6.2 mi" or "10 km"
/// ```
class DistanceService {
  DistanceService._();
  static final DistanceService instance = DistanceService._();
  factory DistanceService() => instance;

  /// Conversion factor: 1 km = 0.621371 miles
  static const double kmToMilesFactor = 0.621371;
  static const double milesToKmFactor = 1.60934;

  /// Get user's preferred distance unit
  DistanceUnit get userUnit {
    try {
      return FFAppState().currentUserPreferences.distanceUnit;
    } catch (_) {
      return DistanceUnit.km;
    }
  }

  /// Check if user prefers miles
  bool get usesMiles => userUnit == DistanceUnit.miles;

  /// Convert km to miles
  double kmToMiles(double km) => km * kmToMilesFactor;

  /// Convert miles to km
  double milesToKm(double miles) => miles * milesToKmFactor;

  /// Convert km to user's preferred unit
  double convertFromKm(double km) {
    if (usesMiles) {
      return kmToMiles(km);
    }
    return km;
  }

  /// Convert from user's preferred unit to km
  double convertToKm(double value) {
    if (usesMiles) {
      return milesToKm(value);
    }
    return value;
  }

  /// Get unit abbreviation
  String get unitAbbreviation => usesMiles ? 'mi' : 'km';

  /// Get unit name
  String get unitName => usesMiles ? 'miles' : 'kilometers';

  /// Format a distance value (in km) to user's preferred unit
  /// 
  /// [distanceKm] - Distance in kilometers
  /// [showUnit] - Whether to append unit abbreviation
  /// 
  /// Returns formatted string like "10 km" or "6.2 mi"
  String formatDistance(double distanceKm, {bool showUnit = true}) {
    final converted = convertFromKm(distanceKm);
    final unit = showUnit ? ' $unitAbbreviation' : '';
    
    // For very small distances, show meters/feet
    if (distanceKm < 1) {
      if (usesMiles) {
        // Show feet for < 0.1 miles
        if (converted < 0.1) {
          final feet = (converted * 5280).round();
          return showUnit ? '$feet ft' : feet.toString();
        }
      } else {
        // Show meters for < 1 km
        final meters = (distanceKm * 1000).round();
        return showUnit ? '$meters m' : meters.toString();
      }
    }
    
    // Format with appropriate precision
    if (converted >= 100) {
      return '${converted.round()}$unit';
    } else if (converted >= 10) {
      return '${converted.toStringAsFixed(0)}$unit';
    } else {
      return '${converted.toStringAsFixed(1)}$unit';
    }
  }

  /// Format a distance range
  /// 
  /// Returns formatted string like "0-50 km" or "0-31 mi"
  String formatDistanceRange(double minKm, double maxKm, {bool showUnit = true}) {
    final minConverted = convertFromKm(minKm);
    final maxConverted = convertFromKm(maxKm);
    final unit = showUnit ? ' $unitAbbreviation' : '';
    
    return '${minConverted.round()}-${maxConverted.round()}$unit';
  }

  // ============================================================
  // DISTANCE SLIDER RANGE CONFIGURATION
  // ============================================================

  /// Base max distance in km
  static const double _baseMaxDistanceKm = 500.0;

  /// Get the maximum distance value for slider in user's unit
  double get maxSliderValue {
    if (usesMiles) {
      return kmToMiles(_baseMaxDistanceKm).roundToDouble(); // ~310 miles
    }
    return _baseMaxDistanceKm;
  }

  /// Get step value for distance slider
  double get sliderStep {
    if (usesMiles) {
      return 5.0; // 5 mile steps
    }
    return 10.0; // 10 km steps
  }

  /// Get number of divisions for slider
  int get sliderDivisions => (maxSliderValue / sliderStep).round();

  /// Common distance presets in user's unit
  List<double> get distancePresets {
    if (usesMiles) {
      return [5, 10, 25, 50, 100, 200, 300];
    }
    return [10, 25, 50, 100, 200, 300, 500];
  }

  /// Format slider value for display
  String formatSliderValue(double value) {
    if (value >= 100) {
      return '${value.round()} $unitAbbreviation';
    }
    return '${value.round()} $unitAbbreviation';
  }
}

/// Extension for easy access to distance formatting
extension DistanceFormatting on double {
  /// Format this value (assumed to be in km) to user's preferred unit
  String toFormattedDistance({bool showUnit = true}) {
    return DistanceService.instance.formatDistance(this, showUnit: showUnit);
  }
}
