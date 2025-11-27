// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MapdatabundleStruct extends BaseStruct {
  MapdatabundleStruct({
    List<MapMarkerStruct>? markers,
    List<WeddingPinOverlayStruct>? weddingPins,
    String? debugStats,
  })  : _markers = markers,
        _weddingPins = weddingPins,
        _debugStats = debugStats;

  // "markers" field.
  List<MapMarkerStruct>? _markers;
  List<MapMarkerStruct> get markers => _markers ?? const [];
  set markers(List<MapMarkerStruct>? val) => _markers = val;

  void updateMarkers(Function(List<MapMarkerStruct>) updateFn) {
    updateFn(_markers ??= []);
  }

  bool hasMarkers() => _markers != null;

  // "weddingPins" field.
  List<WeddingPinOverlayStruct>? _weddingPins;
  List<WeddingPinOverlayStruct> get weddingPins => _weddingPins ?? const [];
  set weddingPins(List<WeddingPinOverlayStruct>? val) => _weddingPins = val;

  void updateWeddingPins(Function(List<WeddingPinOverlayStruct>) updateFn) {
    updateFn(_weddingPins ??= []);
  }

  bool hasWeddingPins() => _weddingPins != null;

  // "debugStats" field.
  String? _debugStats;
  String get debugStats => _debugStats ?? '';
  set debugStats(String? val) => _debugStats = val;

  bool hasDebugStats() => _debugStats != null;

  static MapdatabundleStruct fromMap(Map<String, dynamic> data) =>
      MapdatabundleStruct(
        markers: getStructList(
          data['markers'],
          MapMarkerStruct.fromMap,
        ),
        weddingPins: getStructList(
          data['weddingPins'],
          WeddingPinOverlayStruct.fromMap,
        ),
        debugStats: data['debugStats'] as String?,
      );

  static MapdatabundleStruct? maybeFromMap(dynamic data) => data is Map
      ? MapdatabundleStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'markers': _markers?.map((e) => e.toMap()).toList(),
        'weddingPins': _weddingPins?.map((e) => e.toMap()).toList(),
        'debugStats': _debugStats,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'markers': serializeParam(
          _markers,
          ParamType.DataStruct,
          isList: true,
        ),
        'weddingPins': serializeParam(
          _weddingPins,
          ParamType.DataStruct,
          isList: true,
        ),
        'debugStats': serializeParam(
          _debugStats,
          ParamType.String,
        ),
      }.withoutNulls;

  static MapdatabundleStruct fromSerializableMap(Map<String, dynamic> data) =>
      MapdatabundleStruct(
        markers: deserializeStructParam<MapMarkerStruct>(
          data['markers'],
          ParamType.DataStruct,
          true,
          structBuilder: MapMarkerStruct.fromSerializableMap,
        ),
        weddingPins: deserializeStructParam<WeddingPinOverlayStruct>(
          data['weddingPins'],
          ParamType.DataStruct,
          true,
          structBuilder: WeddingPinOverlayStruct.fromSerializableMap,
        ),
        debugStats: deserializeParam(
          data['debugStats'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'MapdatabundleStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is MapdatabundleStruct &&
        listEquality.equals(markers, other.markers) &&
        listEquality.equals(weddingPins, other.weddingPins) &&
        debugStats == other.debugStats;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([markers, weddingPins, debugStats]);
}

MapdatabundleStruct createMapdatabundleStruct({
  String? debugStats,
}) =>
    MapdatabundleStruct(
      debugStats: debugStats,
    );
