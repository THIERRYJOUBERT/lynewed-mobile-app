/// Geographic coordinate type for latitude and longitude.
///
/// This is a Clean Architecture replacement for FlutterFlow's LatLng.
/// Provides immutable coordinates with serialization support.
///
/// Example:
/// ```dart
/// const paris = LatLng(48.8566, 2.3522);
/// print(paris.serialize()); // "48.8566,2.3522"
///
/// final newYork = LatLng.deserialize('40.7128,-74.0060');
/// ```
class LatLng {
  /// The latitude coordinate.
  final double latitude;

  /// The longitude coordinate.
  final double longitude;

  /// Creates a geographic coordinate.
  const LatLng(this.latitude, this.longitude);

  /// Deserializes from a comma-separated string.
  ///
  /// Format: "latitude,longitude"
  ///
  /// Throws [FormatException] if the string is malformed.
  factory LatLng.deserialize(String value) {
    final parts = value.split(',');
    if (parts.length < 2) {
      throw FormatException('Invalid LatLng format: expected "lat,lng", got "$value"');
    }
    try {
      return LatLng(
        double.parse(parts[0].trim()),
        double.parse(parts[1].trim()),
      );
    } on FormatException {
      throw FormatException('Invalid LatLng format: could not parse coordinates from "$value"');
    }
  }

  /// Serializes to a comma-separated string.
  String serialize() => '$latitude,$longitude';

  @override
  String toString() => 'LatLng(lat: $latitude, lng: $longitude)';

  @override
  int get hashCode => latitude.hashCode + longitude.hashCode;

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      latitude == other.latitude &&
      longitude == other.longitude;
}
