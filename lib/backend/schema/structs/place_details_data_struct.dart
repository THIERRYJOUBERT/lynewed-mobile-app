// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PlaceDetailsDataStruct extends BaseStruct {
  PlaceDetailsDataStruct({
    LatLng? coords,
    String? formattedAddress,
    String? city,
    String? country,
    String? countryCode,
    String? postalCode,
    String? stateCode,
    String? streetNumber,
    String? route,
  })  : _coords = coords,
        _formattedAddress = formattedAddress,
        _city = city,
        _country = country,
        _countryCode = countryCode,
        _postalCode = postalCode,
        _stateCode = stateCode,
        _streetNumber = streetNumber,
        _route = route;

  // "coords" field.
  LatLng? _coords;
  LatLng? get coords => _coords;
  set coords(LatLng? val) => _coords = val;

  bool hasCoords() => _coords != null;

  // "formattedAddress" field.
  String? _formattedAddress;
  String get formattedAddress => _formattedAddress ?? '';
  set formattedAddress(String? val) => _formattedAddress = val;

  bool hasFormattedAddress() => _formattedAddress != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  set city(String? val) => _city = val;

  bool hasCity() => _city != null;

  // "country" field.
  String? _country;
  String get country => _country ?? '';
  set country(String? val) => _country = val;

  bool hasCountry() => _country != null;

  // "countryCode" field.
  String? _countryCode;
  String get countryCode => _countryCode ?? '';
  set countryCode(String? val) => _countryCode = val;

  bool hasCountryCode() => _countryCode != null;

  // "postalCode" field.
  String? _postalCode;
  String get postalCode => _postalCode ?? '';
  set postalCode(String? val) => _postalCode = val;

  bool hasPostalCode() => _postalCode != null;

  // "stateCode" field.
  String? _stateCode;
  String get stateCode => _stateCode ?? '';
  set stateCode(String? val) => _stateCode = val;

  bool hasStateCode() => _stateCode != null;

  // "streetNumber" field.
  String? _streetNumber;
  String get streetNumber => _streetNumber ?? '';
  set streetNumber(String? val) => _streetNumber = val;

  bool hasStreetNumber() => _streetNumber != null;

  // "route" field (street name).
  String? _route;
  String get route => _route ?? '';
  set route(String? val) => _route = val;

  bool hasRoute() => _route != null;

  static PlaceDetailsDataStruct fromMap(Map<String, dynamic> data) =>
      PlaceDetailsDataStruct(
        coords: data['coords'] as LatLng?,
        formattedAddress: data['formattedAddress'] as String?,
        city: data['city'] as String?,
        country: data['country'] as String?,
        countryCode: data['countryCode'] as String?,
        postalCode: data['postalCode'] as String?,
        stateCode: data['stateCode'] as String?,
        streetNumber: data['streetNumber'] as String?,
        route: data['route'] as String?,
      );

  static PlaceDetailsDataStruct? maybeFromMap(dynamic data) => data is Map
      ? PlaceDetailsDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'coords': _coords,
        'formattedAddress': _formattedAddress,
        'city': _city,
        'country': _country,
        'countryCode': _countryCode,
        'postalCode': _postalCode,
        'stateCode': _stateCode,
        'streetNumber': _streetNumber,
        'route': _route,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'coords': serializeParam(
          _coords,
          ParamType.LatLng,
        ),
        'formattedAddress': serializeParam(
          _formattedAddress,
          ParamType.String,
        ),
        'city': serializeParam(
          _city,
          ParamType.String,
        ),
        'country': serializeParam(
          _country,
          ParamType.String,
        ),
        'countryCode': serializeParam(
          _countryCode,
          ParamType.String,
        ),
        'postalCode': serializeParam(
          _postalCode,
          ParamType.String,
        ),
        'stateCode': serializeParam(
          _stateCode,
          ParamType.String,
        ),
        'streetNumber': serializeParam(
          _streetNumber,
          ParamType.String,
        ),
        'route': serializeParam(
          _route,
          ParamType.String,
        ),
      }.withoutNulls;

  static PlaceDetailsDataStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      PlaceDetailsDataStruct(
        coords: deserializeParam(
          data['coords'],
          ParamType.LatLng,
          false,
        ),
        formattedAddress: deserializeParam(
          data['formattedAddress'],
          ParamType.String,
          false,
        ),
        city: deserializeParam(
          data['city'],
          ParamType.String,
          false,
        ),
        country: deserializeParam(
          data['country'],
          ParamType.String,
          false,
        ),
        countryCode: deserializeParam(
          data['countryCode'],
          ParamType.String,
          false,
        ),
        postalCode: deserializeParam(
          data['postalCode'],
          ParamType.String,
          false,
        ),
        stateCode: deserializeParam(
          data['stateCode'],
          ParamType.String,
          false,
        ),
        streetNumber: deserializeParam(
          data['streetNumber'],
          ParamType.String,
          false,
        ),
        route: deserializeParam(
          data['route'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'PlaceDetailsDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PlaceDetailsDataStruct &&
        coords == other.coords &&
        formattedAddress == other.formattedAddress &&
        city == other.city &&
        country == other.country &&
        countryCode == other.countryCode &&
        postalCode == other.postalCode &&
        stateCode == other.stateCode &&
        streetNumber == other.streetNumber &&
        route == other.route;
  }

  @override
  int get hashCode => const ListEquality().hash([
        coords,
        formattedAddress,
        city,
        country,
        countryCode,
        postalCode,
        stateCode,
        streetNumber,
        route,
      ]);
}

PlaceDetailsDataStruct createPlaceDetailsDataStruct({
  LatLng? coords,
  String? formattedAddress,
  String? city,
  String? country,
  String? countryCode,
  String? postalCode,
  String? stateCode,
  String? streetNumber,
  String? route,
}) =>
    PlaceDetailsDataStruct(
      coords: coords,
      formattedAddress: formattedAddress,
      city: city,
      country: country,
      countryCode: countryCode,
      postalCode: postalCode,
      stateCode: stateCode,
      streetNumber: streetNumber,
      route: route,
    );
