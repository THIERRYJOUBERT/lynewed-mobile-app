import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'map_brides_large_widget.dart' show MapBridesLargeWidget;
import 'package:flutter/material.dart';

class MapBridesLargeModel extends FlutterFlowModel<MapBridesLargeWidget> {
  ///  Local state fields for this page.

  QueryFiltersStruct? psQueryFilters;
  void updatePsQueryFiltersStruct(Function(QueryFiltersStruct) updateFn) {
    updateFn(psQueryFilters ??= QueryFiltersStruct());
  }

  MapCommandStruct? psMapCommand;
  void updatePsMapCommandStruct(Function(MapCommandStruct) updateFn) {
    updateFn(psMapCommand ??= MapCommandStruct());
  }

  MapdatabundleStruct? psMapData;
  void updatePsMapDataStruct(Function(MapdatabundleStruct) updateFn) {
    updateFn(psMapData ??= MapdatabundleStruct());
  }

  MapMarkerStruct? psSearchTargetMarker;
  void updatePsSearchTargetMarkerStruct(Function(MapMarkerStruct) updateFn) {
    updateFn(psSearchTargetMarker ??= MapMarkerStruct());
  }

  String? searchText;

  MapStyleType? mapStyle = MapStyleType.normal;

  bool viewMapStyle = false;
  
  /// Whether address suggestions are currently visible (for container height adjustment)
  bool suggestionsVisible = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getProItemDetailsAction] action in LynewedInteractiveMap widget.
  ProDetailsStruct? proDetailsFromAction;
  // Stores action output result for [Custom Action - getPoiItemDetails] action in LynewedInteractiveMap widget.
  PoiItemDataStruct? poiDetailsData;
  // Stores action output result for [Custom Action - getWeddingPinItemDetailsRpc] action in LynewedInteractiveMap widget.
  WeddingPinItemDataStruct? weddingPinDetailsData;
  // Stores action output result for [Custom Action - getAlertItemDetailsRpc] action in LynewedInteractiveMap widget.
  AlertItemDataStruct? alertDetails;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
