import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/compo_finaux/add_filter_sheet/add_filter_sheet_widget.dart';
import '/compo_finaux/create_edit_alert_sheet/create_edit_alert_sheet_widget.dart';
import '/compo_finaux/info_alert_item_sheet/info_alert_item_sheet_widget.dart';
import '/compo_finaux/info_poi_sheet/info_poi_sheet_widget.dart';
import '/compo_finaux/info_pro_item_sheet/info_pro_item_sheet_widget.dart';
import '/compo_finaux/info_wedding_pin_sheet/info_wedding_pin_sheet_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import 'map_pro_large_widget.dart' show MapProLargeWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MapProLargeModel extends FlutterFlowModel<MapProLargeWidget> {
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
  AlertItemDataStruct? alertDetailsPro;
  // Stores action output result for [Custom Action - getPlacePredictions] action in InstantSearchTextField widget.
  PlacePredictionsResultStruct? predictionsResult;
  // Stores action output result for [Custom Action - getPlaceDetails] action in Column widget.
  LatLng? placeCoordinates;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
