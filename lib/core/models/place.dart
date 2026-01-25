import 'package:lynewed_beta/core/models/lat_lng.dart';

/// Represents a place with geographic coordinates and address components.
///
/// This is a Clean Architecture replacement for FlutterFlow's FFPlace.
/// Provides an immutable representation of a location with address details.
///
/// Example:
/// ```dart
/// const place = Place(
///   latLng: LatLng(48.8566, 2.3522),
///   name: 'Eiffel Tower',
///   city: 'Paris',
///   country: 'France',
/// );
/// ```
class Place {
  /// The geographic coordinates.
  final LatLng latLng;

  /// The name of the place.
  final String name;

  /// The street address.
  final String address;

  /// The city name.
  final String city;

  /// The state or region.
  final String state;

  /// The country name.
  final String country;

  /// The postal/zip code.
  final String zipCode;

  /// Creates a place with the given details.
  ///
  /// All string fields default to empty strings.
  /// [latLng] defaults to (0.0, 0.0).
  const Place({
    this.latLng = const LatLng(0.0, 0.0),
    this.name = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.zipCode = '',
  });

  /// Creates a copy of this place with the given fields replaced.
  Place copyWith({
    LatLng? latLng,
    String? name,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
  }) {
    return Place(
      latLng: latLng ?? this.latLng,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
    );
  }

  @override
  String toString() => '''Place(
        latLng: $latLng,
        name: $name,
        address: $address,
        city: $city,
        state: $state,
        country: $country,
        zipCode: $zipCode,
      )''';

  @override
  int get hashCode => Object.hash(
        latLng,
        name,
        address,
        city,
        state,
        country,
        zipCode,
      );

  @override
  bool operator ==(Object other) =>
      other is Place &&
      latLng == other.latLng &&
      name == other.name &&
      address == other.address &&
      city == other.city &&
      state == other.state &&
      country == other.country &&
      zipCode == other.zipCode;
}
