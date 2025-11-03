// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LayerTogglesStruct extends BaseStruct {
  LayerTogglesStruct({
    bool? showPros,
    bool? showProRecent,
    bool? showFixedLocations,
    bool? showBridePrivatePoi,
    bool? showWeddingPins,
    bool? showProAlerts,
    bool? showSearchTarget,
    bool? showOnlyMyProfessionPins,
  })  : _showPros = showPros,
        _showProRecent = showProRecent,
        _showFixedLocations = showFixedLocations,
        _showBridePrivatePoi = showBridePrivatePoi,
        _showWeddingPins = showWeddingPins,
        _showProAlerts = showProAlerts,
        _showSearchTarget = showSearchTarget,
        _showOnlyMyProfessionPins = showOnlyMyProfessionPins;

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

  // "showSearchTarget" field.
  bool? _showSearchTarget;
  bool get showSearchTarget => _showSearchTarget ?? false;
  set showSearchTarget(bool? val) => _showSearchTarget = val;

  bool hasShowSearchTarget() => _showSearchTarget != null;

  // "showOnlyMyProfessionPins" field.
  bool? _showOnlyMyProfessionPins;
  bool get showOnlyMyProfessionPins => _showOnlyMyProfessionPins ?? false;
  set showOnlyMyProfessionPins(bool? val) => _showOnlyMyProfessionPins = val;

  bool hasShowOnlyMyProfessionPins() => _showOnlyMyProfessionPins != null;

  static LayerTogglesStruct fromMap(Map<String, dynamic> data) =>
      LayerTogglesStruct(
        showPros: data['showPros'] as bool?,
        showProRecent: data['showProRecent'] as bool?,
        showFixedLocations: data['showFixedLocations'] as bool?,
        showBridePrivatePoi: data['showBridePrivatePoi'] as bool?,
        showWeddingPins: data['showWeddingPins'] as bool?,
        showProAlerts: data['showProAlerts'] as bool?,
        showSearchTarget: data['showSearchTarget'] as bool?,
        showOnlyMyProfessionPins: data['showOnlyMyProfessionPins'] as bool?,
      );

  static LayerTogglesStruct? maybeFromMap(dynamic data) => data is Map
      ? LayerTogglesStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'showPros': _showPros,
        'showProRecent': _showProRecent,
        'showFixedLocations': _showFixedLocations,
        'showBridePrivatePoi': _showBridePrivatePoi,
        'showWeddingPins': _showWeddingPins,
        'showProAlerts': _showProAlerts,
        'showSearchTarget': _showSearchTarget,
        'showOnlyMyProfessionPins': _showOnlyMyProfessionPins,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
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
        'showSearchTarget': serializeParam(
          _showSearchTarget,
          ParamType.bool,
        ),
        'showOnlyMyProfessionPins': serializeParam(
          _showOnlyMyProfessionPins,
          ParamType.bool,
        ),
      }.withoutNulls;

  static LayerTogglesStruct fromSerializableMap(Map<String, dynamic> data) =>
      LayerTogglesStruct(
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
        showSearchTarget: deserializeParam(
          data['showSearchTarget'],
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
  String toString() => 'LayerTogglesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is LayerTogglesStruct &&
        showPros == other.showPros &&
        showProRecent == other.showProRecent &&
        showFixedLocations == other.showFixedLocations &&
        showBridePrivatePoi == other.showBridePrivatePoi &&
        showWeddingPins == other.showWeddingPins &&
        showProAlerts == other.showProAlerts &&
        showSearchTarget == other.showSearchTarget &&
        showOnlyMyProfessionPins == other.showOnlyMyProfessionPins;
  }

  @override
  int get hashCode => const ListEquality().hash([
        showPros,
        showProRecent,
        showFixedLocations,
        showBridePrivatePoi,
        showWeddingPins,
        showProAlerts,
        showSearchTarget,
        showOnlyMyProfessionPins
      ]);
}

LayerTogglesStruct createLayerTogglesStruct({
  bool? showPros,
  bool? showProRecent,
  bool? showFixedLocations,
  bool? showBridePrivatePoi,
  bool? showWeddingPins,
  bool? showProAlerts,
  bool? showSearchTarget,
  bool? showOnlyMyProfessionPins,
}) =>
    LayerTogglesStruct(
      showPros: showPros,
      showProRecent: showProRecent,
      showFixedLocations: showFixedLocations,
      showBridePrivatePoi: showBridePrivatePoi,
      showWeddingPins: showWeddingPins,
      showProAlerts: showProAlerts,
      showSearchTarget: showSearchTarget,
      showOnlyMyProfessionPins: showOnlyMyProfessionPins,
    );
