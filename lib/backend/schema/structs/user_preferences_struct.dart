// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserPreferencesStruct extends BaseStruct {
  UserPreferencesStruct({
    DistanceUnit? distanceUnit,
    String? currency,
    int? defaultRadiusKm,
    String? defaultCity,
    String? defaultCountry,
    String? defaultLocale,
    String? defaultTimezone,
    LayerTogglesStruct? mapToggles,
    String? lastFiltersJson,
  })  : _distanceUnit = distanceUnit,
        _currency = currency,
        _defaultRadiusKm = defaultRadiusKm,
        _defaultCity = defaultCity,
        _defaultCountry = defaultCountry,
        _defaultLocale = defaultLocale,
        _defaultTimezone = defaultTimezone,
        _mapToggles = mapToggles,
        _lastFiltersJson = lastFiltersJson;

  // "distanceUnit" field.
  DistanceUnit? _distanceUnit;
  DistanceUnit get distanceUnit => _distanceUnit ?? DistanceUnit.km;
  set distanceUnit(DistanceUnit? val) => _distanceUnit = val;

  bool hasDistanceUnit() => _distanceUnit != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  set currency(String? val) => _currency = val;

  bool hasCurrency() => _currency != null;

  // "defaultRadiusKm" field.
  int? _defaultRadiusKm;
  int get defaultRadiusKm => _defaultRadiusKm ?? 0;
  set defaultRadiusKm(int? val) => _defaultRadiusKm = val;

  void incrementDefaultRadiusKm(int amount) =>
      defaultRadiusKm = defaultRadiusKm + amount;

  bool hasDefaultRadiusKm() => _defaultRadiusKm != null;

  // "defaultCity" field.
  String? _defaultCity;
  String get defaultCity => _defaultCity ?? '';
  set defaultCity(String? val) => _defaultCity = val;

  bool hasDefaultCity() => _defaultCity != null;

  // "defaultCountry" field.
  String? _defaultCountry;
  String get defaultCountry => _defaultCountry ?? '';
  set defaultCountry(String? val) => _defaultCountry = val;

  bool hasDefaultCountry() => _defaultCountry != null;

  // "defaultLocale" field.
  String? _defaultLocale;
  String get defaultLocale => _defaultLocale ?? '';
  set defaultLocale(String? val) => _defaultLocale = val;

  bool hasDefaultLocale() => _defaultLocale != null;

  // "defaultTimezone" field.
  String? _defaultTimezone;
  String get defaultTimezone => _defaultTimezone ?? '';
  set defaultTimezone(String? val) => _defaultTimezone = val;

  bool hasDefaultTimezone() => _defaultTimezone != null;

  // "mapToggles" field.
  LayerTogglesStruct? _mapToggles;
  LayerTogglesStruct get mapToggles => _mapToggles ?? LayerTogglesStruct();
  set mapToggles(LayerTogglesStruct? val) => _mapToggles = val;

  void updateMapToggles(Function(LayerTogglesStruct) updateFn) {
    updateFn(_mapToggles ??= LayerTogglesStruct());
  }

  bool hasMapToggles() => _mapToggles != null;

  // "lastFiltersJson" field.
  String? _lastFiltersJson;
  String get lastFiltersJson => _lastFiltersJson ?? '';
  set lastFiltersJson(String? val) => _lastFiltersJson = val;

  bool hasLastFiltersJson() => _lastFiltersJson != null;

  static UserPreferencesStruct fromMap(Map<String, dynamic> data) =>
      UserPreferencesStruct(
        distanceUnit: data['distanceUnit'] is DistanceUnit
            ? data['distanceUnit']
            : deserializeEnum<DistanceUnit>(data['distanceUnit']),
        currency: data['currency'] as String?,
        defaultRadiusKm: castToType<int>(data['defaultRadiusKm']),
        defaultCity: data['defaultCity'] as String?,
        defaultCountry: data['defaultCountry'] as String?,
        defaultLocale: data['defaultLocale'] as String?,
        defaultTimezone: data['defaultTimezone'] as String?,
        mapToggles: data['mapToggles'] is LayerTogglesStruct
            ? data['mapToggles']
            : LayerTogglesStruct.maybeFromMap(data['mapToggles']),
        lastFiltersJson: data['lastFiltersJson'] as String?,
      );

  static UserPreferencesStruct? maybeFromMap(dynamic data) => data is Map
      ? UserPreferencesStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'distanceUnit': _distanceUnit?.serialize(),
        'currency': _currency,
        'defaultRadiusKm': _defaultRadiusKm,
        'defaultCity': _defaultCity,
        'defaultCountry': _defaultCountry,
        'defaultLocale': _defaultLocale,
        'defaultTimezone': _defaultTimezone,
        'mapToggles': _mapToggles?.toMap(),
        'lastFiltersJson': _lastFiltersJson,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'distanceUnit': serializeParam(
          _distanceUnit,
          ParamType.Enum,
        ),
        'currency': serializeParam(
          _currency,
          ParamType.String,
        ),
        'defaultRadiusKm': serializeParam(
          _defaultRadiusKm,
          ParamType.int,
        ),
        'defaultCity': serializeParam(
          _defaultCity,
          ParamType.String,
        ),
        'defaultCountry': serializeParam(
          _defaultCountry,
          ParamType.String,
        ),
        'defaultLocale': serializeParam(
          _defaultLocale,
          ParamType.String,
        ),
        'defaultTimezone': serializeParam(
          _defaultTimezone,
          ParamType.String,
        ),
        'mapToggles': serializeParam(
          _mapToggles,
          ParamType.DataStruct,
        ),
        'lastFiltersJson': serializeParam(
          _lastFiltersJson,
          ParamType.String,
        ),
      }.withoutNulls;

  static UserPreferencesStruct fromSerializableMap(Map<String, dynamic> data) =>
      UserPreferencesStruct(
        distanceUnit: deserializeParam<DistanceUnit>(
          data['distanceUnit'],
          ParamType.Enum,
          false,
        ),
        currency: deserializeParam(
          data['currency'],
          ParamType.String,
          false,
        ),
        defaultRadiusKm: deserializeParam(
          data['defaultRadiusKm'],
          ParamType.int,
          false,
        ),
        defaultCity: deserializeParam(
          data['defaultCity'],
          ParamType.String,
          false,
        ),
        defaultCountry: deserializeParam(
          data['defaultCountry'],
          ParamType.String,
          false,
        ),
        defaultLocale: deserializeParam(
          data['defaultLocale'],
          ParamType.String,
          false,
        ),
        defaultTimezone: deserializeParam(
          data['defaultTimezone'],
          ParamType.String,
          false,
        ),
        mapToggles: deserializeStructParam(
          data['mapToggles'],
          ParamType.DataStruct,
          false,
          structBuilder: LayerTogglesStruct.fromSerializableMap,
        ),
        lastFiltersJson: deserializeParam(
          data['lastFiltersJson'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UserPreferencesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UserPreferencesStruct &&
        distanceUnit == other.distanceUnit &&
        currency == other.currency &&
        defaultRadiusKm == other.defaultRadiusKm &&
        defaultCity == other.defaultCity &&
        defaultCountry == other.defaultCountry &&
        defaultLocale == other.defaultLocale &&
        defaultTimezone == other.defaultTimezone &&
        mapToggles == other.mapToggles &&
        lastFiltersJson == other.lastFiltersJson;
  }

  @override
  int get hashCode => const ListEquality().hash([
        distanceUnit,
        currency,
        defaultRadiusKm,
        defaultCity,
        defaultCountry,
        defaultLocale,
        defaultTimezone,
        mapToggles,
        lastFiltersJson
      ]);
}

UserPreferencesStruct createUserPreferencesStruct({
  DistanceUnit? distanceUnit,
  String? currency,
  int? defaultRadiusKm,
  String? defaultCity,
  String? defaultCountry,
  String? defaultLocale,
  String? defaultTimezone,
  LayerTogglesStruct? mapToggles,
  String? lastFiltersJson,
}) =>
    UserPreferencesStruct(
      distanceUnit: distanceUnit,
      currency: currency,
      defaultRadiusKm: defaultRadiusKm,
      defaultCity: defaultCity,
      defaultCountry: defaultCountry,
      defaultLocale: defaultLocale,
      defaultTimezone: defaultTimezone,
      mapToggles: mapToggles ?? LayerTogglesStruct(),
      lastFiltersJson: lastFiltersJson,
    );
