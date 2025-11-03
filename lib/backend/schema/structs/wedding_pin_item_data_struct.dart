// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WeddingPinItemDataStruct extends BaseStruct {
  WeddingPinItemDataStruct({
    String? weddingPinId,
    String? brideProfileId,
    String? locationLabel,
    LatLng? center,
    int? radiusKm,
    List<Profession>? professionsNeeded,
    DateTime? eventStartDate,
    int? budgetMin,
    int? budgetMax,
    String? currency,
    bool? isContactable,
    String? poiId,
    MapMarkerType? source,
    DateTime? createdAt,
    String? brideAvatarUrl,
  })  : _weddingPinId = weddingPinId,
        _brideProfileId = brideProfileId,
        _locationLabel = locationLabel,
        _center = center,
        _radiusKm = radiusKm,
        _professionsNeeded = professionsNeeded,
        _eventStartDate = eventStartDate,
        _budgetMin = budgetMin,
        _budgetMax = budgetMax,
        _currency = currency,
        _isContactable = isContactable,
        _poiId = poiId,
        _source = source,
        _createdAt = createdAt,
        _brideAvatarUrl = brideAvatarUrl;

  // "weddingPinId" field.
  String? _weddingPinId;
  String get weddingPinId => _weddingPinId ?? '';
  set weddingPinId(String? val) => _weddingPinId = val;

  bool hasWeddingPinId() => _weddingPinId != null;

  // "brideProfileId" field.
  String? _brideProfileId;
  String get brideProfileId => _brideProfileId ?? '';
  set brideProfileId(String? val) => _brideProfileId = val;

  bool hasBrideProfileId() => _brideProfileId != null;

  // "locationLabel" field.
  String? _locationLabel;
  String get locationLabel => _locationLabel ?? '';
  set locationLabel(String? val) => _locationLabel = val;

  bool hasLocationLabel() => _locationLabel != null;

  // "center" field.
  LatLng? _center;
  LatLng? get center => _center;
  set center(LatLng? val) => _center = val;

  bool hasCenter() => _center != null;

  // "radiusKm" field.
  int? _radiusKm;
  int get radiusKm => _radiusKm ?? 0;
  set radiusKm(int? val) => _radiusKm = val;

  void incrementRadiusKm(int amount) => radiusKm = radiusKm + amount;

  bool hasRadiusKm() => _radiusKm != null;

  // "professionsNeeded" field.
  List<Profession>? _professionsNeeded;
  List<Profession> get professionsNeeded => _professionsNeeded ?? const [];
  set professionsNeeded(List<Profession>? val) => _professionsNeeded = val;

  void updateProfessionsNeeded(Function(List<Profession>) updateFn) {
    updateFn(_professionsNeeded ??= []);
  }

  bool hasProfessionsNeeded() => _professionsNeeded != null;

  // "eventStartDate" field.
  DateTime? _eventStartDate;
  DateTime? get eventStartDate => _eventStartDate;
  set eventStartDate(DateTime? val) => _eventStartDate = val;

  bool hasEventStartDate() => _eventStartDate != null;

  // "budgetMin" field.
  int? _budgetMin;
  int get budgetMin => _budgetMin ?? 0;
  set budgetMin(int? val) => _budgetMin = val;

  void incrementBudgetMin(int amount) => budgetMin = budgetMin + amount;

  bool hasBudgetMin() => _budgetMin != null;

  // "budgetMax" field.
  int? _budgetMax;
  int get budgetMax => _budgetMax ?? 0;
  set budgetMax(int? val) => _budgetMax = val;

  void incrementBudgetMax(int amount) => budgetMax = budgetMax + amount;

  bool hasBudgetMax() => _budgetMax != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  set currency(String? val) => _currency = val;

  bool hasCurrency() => _currency != null;

  // "isContactable" field.
  bool? _isContactable;
  bool get isContactable => _isContactable ?? false;
  set isContactable(bool? val) => _isContactable = val;

  bool hasIsContactable() => _isContactable != null;

  // "poiId" field.
  String? _poiId;
  String get poiId => _poiId ?? '';
  set poiId(String? val) => _poiId = val;

  bool hasPoiId() => _poiId != null;

  // "source" field.
  MapMarkerType? _source;
  MapMarkerType? get source => _source;
  set source(MapMarkerType? val) => _source = val;

  bool hasSource() => _source != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "brideAvatarUrl" field.
  String? _brideAvatarUrl;
  String get brideAvatarUrl => _brideAvatarUrl ?? '';
  set brideAvatarUrl(String? val) => _brideAvatarUrl = val;

  bool hasBrideAvatarUrl() => _brideAvatarUrl != null;

  static WeddingPinItemDataStruct fromMap(Map<String, dynamic> data) =>
      WeddingPinItemDataStruct(
        weddingPinId: data['weddingPinId'] as String?,
        brideProfileId: data['brideProfileId'] as String?,
        locationLabel: data['locationLabel'] as String?,
        center: data['center'] as LatLng?,
        radiusKm: castToType<int>(data['radiusKm']),
        professionsNeeded: getEnumList<Profession>(data['professionsNeeded']),
        eventStartDate: data['eventStartDate'] as DateTime?,
        budgetMin: castToType<int>(data['budgetMin']),
        budgetMax: castToType<int>(data['budgetMax']),
        currency: data['currency'] as String?,
        isContactable: data['isContactable'] as bool?,
        poiId: data['poiId'] as String?,
        source: data['source'] is MapMarkerType
            ? data['source']
            : deserializeEnum<MapMarkerType>(data['source']),
        createdAt: data['createdAt'] as DateTime?,
        brideAvatarUrl: data['brideAvatarUrl'] as String?,
      );

  static WeddingPinItemDataStruct? maybeFromMap(dynamic data) => data is Map
      ? WeddingPinItemDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'weddingPinId': _weddingPinId,
        'brideProfileId': _brideProfileId,
        'locationLabel': _locationLabel,
        'center': _center,
        'radiusKm': _radiusKm,
        'professionsNeeded':
            _professionsNeeded?.map((e) => e.serialize()).toList(),
        'eventStartDate': _eventStartDate,
        'budgetMin': _budgetMin,
        'budgetMax': _budgetMax,
        'currency': _currency,
        'isContactable': _isContactable,
        'poiId': _poiId,
        'source': _source?.serialize(),
        'createdAt': _createdAt,
        'brideAvatarUrl': _brideAvatarUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'weddingPinId': serializeParam(
          _weddingPinId,
          ParamType.String,
        ),
        'brideProfileId': serializeParam(
          _brideProfileId,
          ParamType.String,
        ),
        'locationLabel': serializeParam(
          _locationLabel,
          ParamType.String,
        ),
        'center': serializeParam(
          _center,
          ParamType.LatLng,
        ),
        'radiusKm': serializeParam(
          _radiusKm,
          ParamType.int,
        ),
        'professionsNeeded': serializeParam(
          _professionsNeeded,
          ParamType.Enum,
          isList: true,
        ),
        'eventStartDate': serializeParam(
          _eventStartDate,
          ParamType.DateTime,
        ),
        'budgetMin': serializeParam(
          _budgetMin,
          ParamType.int,
        ),
        'budgetMax': serializeParam(
          _budgetMax,
          ParamType.int,
        ),
        'currency': serializeParam(
          _currency,
          ParamType.String,
        ),
        'isContactable': serializeParam(
          _isContactable,
          ParamType.bool,
        ),
        'poiId': serializeParam(
          _poiId,
          ParamType.String,
        ),
        'source': serializeParam(
          _source,
          ParamType.Enum,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
        'brideAvatarUrl': serializeParam(
          _brideAvatarUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static WeddingPinItemDataStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      WeddingPinItemDataStruct(
        weddingPinId: deserializeParam(
          data['weddingPinId'],
          ParamType.String,
          false,
        ),
        brideProfileId: deserializeParam(
          data['brideProfileId'],
          ParamType.String,
          false,
        ),
        locationLabel: deserializeParam(
          data['locationLabel'],
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
          ParamType.int,
          false,
        ),
        professionsNeeded: deserializeParam<Profession>(
          data['professionsNeeded'],
          ParamType.Enum,
          true,
        ),
        eventStartDate: deserializeParam(
          data['eventStartDate'],
          ParamType.DateTime,
          false,
        ),
        budgetMin: deserializeParam(
          data['budgetMin'],
          ParamType.int,
          false,
        ),
        budgetMax: deserializeParam(
          data['budgetMax'],
          ParamType.int,
          false,
        ),
        currency: deserializeParam(
          data['currency'],
          ParamType.String,
          false,
        ),
        isContactable: deserializeParam(
          data['isContactable'],
          ParamType.bool,
          false,
        ),
        poiId: deserializeParam(
          data['poiId'],
          ParamType.String,
          false,
        ),
        source: deserializeParam<MapMarkerType>(
          data['source'],
          ParamType.Enum,
          false,
        ),
        createdAt: deserializeParam(
          data['createdAt'],
          ParamType.DateTime,
          false,
        ),
        brideAvatarUrl: deserializeParam(
          data['brideAvatarUrl'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'WeddingPinItemDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is WeddingPinItemDataStruct &&
        weddingPinId == other.weddingPinId &&
        brideProfileId == other.brideProfileId &&
        locationLabel == other.locationLabel &&
        center == other.center &&
        radiusKm == other.radiusKm &&
        listEquality.equals(professionsNeeded, other.professionsNeeded) &&
        eventStartDate == other.eventStartDate &&
        budgetMin == other.budgetMin &&
        budgetMax == other.budgetMax &&
        currency == other.currency &&
        isContactable == other.isContactable &&
        poiId == other.poiId &&
        source == other.source &&
        createdAt == other.createdAt &&
        brideAvatarUrl == other.brideAvatarUrl;
  }

  @override
  int get hashCode => const ListEquality().hash([
        weddingPinId,
        brideProfileId,
        locationLabel,
        center,
        radiusKm,
        professionsNeeded,
        eventStartDate,
        budgetMin,
        budgetMax,
        currency,
        isContactable,
        poiId,
        source,
        createdAt,
        brideAvatarUrl
      ]);
}

WeddingPinItemDataStruct createWeddingPinItemDataStruct({
  String? weddingPinId,
  String? brideProfileId,
  String? locationLabel,
  LatLng? center,
  int? radiusKm,
  DateTime? eventStartDate,
  int? budgetMin,
  int? budgetMax,
  String? currency,
  bool? isContactable,
  String? poiId,
  MapMarkerType? source,
  DateTime? createdAt,
  String? brideAvatarUrl,
}) =>
    WeddingPinItemDataStruct(
      weddingPinId: weddingPinId,
      brideProfileId: brideProfileId,
      locationLabel: locationLabel,
      center: center,
      radiusKm: radiusKm,
      eventStartDate: eventStartDate,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      currency: currency,
      isContactable: isContactable,
      poiId: poiId,
      source: source,
      createdAt: createdAt,
      brideAvatarUrl: brideAvatarUrl,
    );
