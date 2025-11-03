// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class QueryFiltersStruct extends BaseStruct {
  QueryFiltersStruct({
    List<Profession>? professions,
    double? budgetMin,
    double? budgetMax,
    String? currency,
    LatLng? center,
    double? radiusKm,
    bool? nearby,
    bool? showPros,
    bool? showProRecent,
    bool? showFixedLocations,
    bool? showBridePrivatePoi,
    bool? showWeddingPins,
    bool? showProAlerts,
    bool? showOnlyMyProfessionPins,
  })  : _professions = professions,
        _budgetMin = budgetMin,
        _budgetMax = budgetMax,
        _currency = currency,
        _center = center,
        _radiusKm = radiusKm,
        _nearby = nearby,
        _showPros = showPros,
        _showProRecent = showProRecent,
        _showFixedLocations = showFixedLocations,
        _showBridePrivatePoi = showBridePrivatePoi,
        _showWeddingPins = showWeddingPins,
        _showProAlerts = showProAlerts,
        _showOnlyMyProfessionPins = showOnlyMyProfessionPins;

  // "professions" field.
  List<Profession>? _professions;
  List<Profession> get professions => _professions ?? const [];
  set professions(List<Profession>? val) => _professions = val;

  void updateProfessions(Function(List<Profession>) updateFn) {
    updateFn(_professions ??= []);
  }

  bool hasProfessions() => _professions != null;

  // "budgetMin" field.
  double? _budgetMin;
  double get budgetMin => _budgetMin ?? 0.0;
  set budgetMin(double? val) => _budgetMin = val;

  void incrementBudgetMin(double amount) => budgetMin = budgetMin + amount;

  bool hasBudgetMin() => _budgetMin != null;

  // "budgetMax" field.
  double? _budgetMax;
  double get budgetMax => _budgetMax ?? 0.0;
  set budgetMax(double? val) => _budgetMax = val;

  void incrementBudgetMax(double amount) => budgetMax = budgetMax + amount;

  bool hasBudgetMax() => _budgetMax != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  set currency(String? val) => _currency = val;

  bool hasCurrency() => _currency != null;

  // "center" field.
  LatLng? _center;
  LatLng? get center => _center;
  set center(LatLng? val) => _center = val;

  bool hasCenter() => _center != null;

  // "radiusKm" field.
  double? _radiusKm;
  double get radiusKm => _radiusKm ?? 0.0;
  set radiusKm(double? val) => _radiusKm = val;

  void incrementRadiusKm(double amount) => radiusKm = radiusKm + amount;

  bool hasRadiusKm() => _radiusKm != null;

  // "nearby" field.
  bool? _nearby;
  bool get nearby => _nearby ?? false;
  set nearby(bool? val) => _nearby = val;

  bool hasNearby() => _nearby != null;

  // "showPros" field.
  bool? _showPros;
  bool get showPros => _showPros ?? false;
  set showPros(bool? val) => _showPros = val;

  bool hasShowPros() => _showPros != null;

  // "showProRecent" field.
  bool? _showProRecent;
  bool get showProRecent => _showProRecent ?? false;
  set showProRecent(bool? val) => _showProRecent = val;

  bool hasShowProRecent() => _showProRecent != null;

  // "showFixedLocations" field.
  bool? _showFixedLocations;
  bool get showFixedLocations => _showFixedLocations ?? false;
  set showFixedLocations(bool? val) => _showFixedLocations = val;

  bool hasShowFixedLocations() => _showFixedLocations != null;

  // "showBridePrivatePoi" field.
  bool? _showBridePrivatePoi;
  bool get showBridePrivatePoi => _showBridePrivatePoi ?? false;
  set showBridePrivatePoi(bool? val) => _showBridePrivatePoi = val;

  bool hasShowBridePrivatePoi() => _showBridePrivatePoi != null;

  // "showWeddingPins" field.
  bool? _showWeddingPins;
  bool get showWeddingPins => _showWeddingPins ?? false;
  set showWeddingPins(bool? val) => _showWeddingPins = val;

  bool hasShowWeddingPins() => _showWeddingPins != null;

  // "showProAlerts" field.
  bool? _showProAlerts;
  bool get showProAlerts => _showProAlerts ?? false;
  set showProAlerts(bool? val) => _showProAlerts = val;

  bool hasShowProAlerts() => _showProAlerts != null;

  // "showOnlyMyProfessionPins" field.
  bool? _showOnlyMyProfessionPins;
  bool get showOnlyMyProfessionPins => _showOnlyMyProfessionPins ?? false;
  set showOnlyMyProfessionPins(bool? val) => _showOnlyMyProfessionPins = val;

  bool hasShowOnlyMyProfessionPins() => _showOnlyMyProfessionPins != null;

  static QueryFiltersStruct fromMap(Map<String, dynamic> data) =>
      QueryFiltersStruct(
        professions: getEnumList<Profession>(data['professions']),
        budgetMin: castToType<double>(data['budgetMin']),
        budgetMax: castToType<double>(data['budgetMax']),
        currency: data['currency'] as String?,
        center: data['center'] as LatLng?,
        radiusKm: castToType<double>(data['radiusKm']),
        nearby: data['nearby'] as bool?,
        showPros: data['showPros'] as bool?,
        showProRecent: data['showProRecent'] as bool?,
        showFixedLocations: data['showFixedLocations'] as bool?,
        showBridePrivatePoi: data['showBridePrivatePoi'] as bool?,
        showWeddingPins: data['showWeddingPins'] as bool?,
        showProAlerts: data['showProAlerts'] as bool?,
        showOnlyMyProfessionPins: data['showOnlyMyProfessionPins'] as bool?,
      );

  static QueryFiltersStruct? maybeFromMap(dynamic data) => data is Map
      ? QueryFiltersStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'professions': _professions?.map((e) => e.serialize()).toList(),
        'budgetMin': _budgetMin,
        'budgetMax': _budgetMax,
        'currency': _currency,
        'center': _center,
        'radiusKm': _radiusKm,
        'nearby': _nearby,
        'showPros': _showPros,
        'showProRecent': _showProRecent,
        'showFixedLocations': _showFixedLocations,
        'showBridePrivatePoi': _showBridePrivatePoi,
        'showWeddingPins': _showWeddingPins,
        'showProAlerts': _showProAlerts,
        'showOnlyMyProfessionPins': _showOnlyMyProfessionPins,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'professions': serializeParam(
          _professions,
          ParamType.Enum,
          isList: true,
        ),
        'budgetMin': serializeParam(
          _budgetMin,
          ParamType.double,
        ),
        'budgetMax': serializeParam(
          _budgetMax,
          ParamType.double,
        ),
        'currency': serializeParam(
          _currency,
          ParamType.String,
        ),
        'center': serializeParam(
          _center,
          ParamType.LatLng,
        ),
        'radiusKm': serializeParam(
          _radiusKm,
          ParamType.double,
        ),
        'nearby': serializeParam(
          _nearby,
          ParamType.bool,
        ),
        'showPros': serializeParam(
          _showPros,
          ParamType.bool,
        ),
        'showProRecent': serializeParam(
          _showProRecent,
          ParamType.bool,
        ),
        'showFixedLocations': serializeParam(
          _showFixedLocations,
          ParamType.bool,
        ),
        'showBridePrivatePoi': serializeParam(
          _showBridePrivatePoi,
          ParamType.bool,
        ),
        'showWeddingPins': serializeParam(
          _showWeddingPins,
          ParamType.bool,
        ),
        'showProAlerts': serializeParam(
          _showProAlerts,
          ParamType.bool,
        ),
        'showOnlyMyProfessionPins': serializeParam(
          _showOnlyMyProfessionPins,
          ParamType.bool,
        ),
      }.withoutNulls;

  static QueryFiltersStruct fromSerializableMap(Map<String, dynamic> data) =>
      QueryFiltersStruct(
        professions: deserializeParam<Profession>(
          data['professions'],
          ParamType.Enum,
          true,
        ),
        budgetMin: deserializeParam(
          data['budgetMin'],
          ParamType.double,
          false,
        ),
        budgetMax: deserializeParam(
          data['budgetMax'],
          ParamType.double,
          false,
        ),
        currency: deserializeParam(
          data['currency'],
          ParamType.String,
          false,
        ),
        center: deserializeParam(
          data['center'],
          ParamType.LatLng,
          false,
        ),
        radiusKm: deserializeParam(
          data['radiusKm'],
          ParamType.double,
          false,
        ),
        nearby: deserializeParam(
          data['nearby'],
          ParamType.bool,
          false,
        ),
        showPros: deserializeParam(
          data['showPros'],
          ParamType.bool,
          false,
        ),
        showProRecent: deserializeParam(
          data['showProRecent'],
          ParamType.bool,
          false,
        ),
        showFixedLocations: deserializeParam(
          data['showFixedLocations'],
          ParamType.bool,
          false,
        ),
        showBridePrivatePoi: deserializeParam(
          data['showBridePrivatePoi'],
          ParamType.bool,
          false,
        ),
        showWeddingPins: deserializeParam(
          data['showWeddingPins'],
          ParamType.bool,
          false,
        ),
        showProAlerts: deserializeParam(
          data['showProAlerts'],
          ParamType.bool,
          false,
        ),
        showOnlyMyProfessionPins: deserializeParam(
          data['showOnlyMyProfessionPins'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'QueryFiltersStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is QueryFiltersStruct &&
        listEquality.equals(professions, other.professions) &&
        budgetMin == other.budgetMin &&
        budgetMax == other.budgetMax &&
        currency == other.currency &&
        center == other.center &&
        radiusKm == other.radiusKm &&
        nearby == other.nearby &&
        showPros == other.showPros &&
        showProRecent == other.showProRecent &&
        showFixedLocations == other.showFixedLocations &&
        showBridePrivatePoi == other.showBridePrivatePoi &&
        showWeddingPins == other.showWeddingPins &&
        showProAlerts == other.showProAlerts &&
        showOnlyMyProfessionPins == other.showOnlyMyProfessionPins;
  }

  @override
  int get hashCode => const ListEquality().hash([
        professions,
        budgetMin,
        budgetMax,
        currency,
        center,
        radiusKm,
        nearby,
        showPros,
        showProRecent,
        showFixedLocations,
        showBridePrivatePoi,
        showWeddingPins,
        showProAlerts,
        showOnlyMyProfessionPins
      ]);
}

QueryFiltersStruct createQueryFiltersStruct({
  double? budgetMin,
  double? budgetMax,
  String? currency,
  LatLng? center,
  double? radiusKm,
  bool? nearby,
  bool? showPros,
  bool? showProRecent,
  bool? showFixedLocations,
  bool? showBridePrivatePoi,
  bool? showWeddingPins,
  bool? showProAlerts,
  bool? showOnlyMyProfessionPins,
}) =>
    QueryFiltersStruct(
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      currency: currency,
      center: center,
      radiusKm: radiusKm,
      nearby: nearby,
      showPros: showPros,
      showProRecent: showProRecent,
      showFixedLocations: showFixedLocations,
      showBridePrivatePoi: showBridePrivatePoi,
      showWeddingPins: showWeddingPins,
      showProAlerts: showProAlerts,
      showOnlyMyProfessionPins: showOnlyMyProfessionPins,
    );
