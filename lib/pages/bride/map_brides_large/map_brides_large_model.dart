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

  String? psPlacesSessionToken;

  MapMarkerStruct? psSearchTargetMarker;
  void updatePsSearchTargetMarkerStruct(Function(MapMarkerStruct) updateFn) {
    updateFn(psSearchTargetMarker ??= MapMarkerStruct());
  }

  List<PlaceSuggestionStruct> psPlaceSuggestions = [];
  void addToPsPlaceSuggestions(PlaceSuggestionStruct item) =>
      psPlaceSuggestions.add(item);
  void removeFromPsPlaceSuggestions(PlaceSuggestionStruct item) =>
      psPlaceSuggestions.remove(item);
  void removeAtIndexFromPsPlaceSuggestions(int index) =>
      psPlaceSuggestions.removeAt(index);
  void insertAtIndexInPsPlaceSuggestions(
          int index, PlaceSuggestionStruct item) =>
      psPlaceSuggestions.insert(index, item);
  void updatePsPlaceSuggestionsAtIndex(
          int index, Function(PlaceSuggestionStruct) updateFn) =>
      psPlaceSuggestions[index] = updateFn(psPlaceSuggestions[index]);

  String? searchText;

  MapStyleType? mapStyle = MapStyleType.normal;

  bool viewMapStyle = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getProItemDetailsAction] action in LynewedInteractiveMap widget.
  ProDetailsStruct? proDetailsFromAction;
  // Stores action output result for [Custom Action - getPoiItemDetails] action in LynewedInteractiveMap widget.
  PoiItemDataStruct? poiDetailsData;
  // Stores action output result for [Custom Action - getWeddingPinItemDetailsRpc] action in LynewedInteractiveMap widget.
  WeddingPinItemDataStruct? weddingPinDetailsData;
  // Stores action output result for [Custom Action - getAlertItemDetailsRpc] action in LynewedInteractiveMap widget.
  AlertItemDataStruct? alertDetails;
  // Stores action output result for [Custom Action - getPlacePredictions] action in InstantSearchTextField widget.
  PlacePredictionsResultStruct? predictionsResult;
  // Stores action output result for [Custom Action - getPlaceDetails] action in Column widget.
  LatLng? placeCoordinates;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
