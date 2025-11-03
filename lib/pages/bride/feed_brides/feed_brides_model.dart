import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'feed_brides_widget.dart' show FeedBridesWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FeedBridesModel extends FlutterFlowModel<FeedBridesWidget> {
  ///  Local state fields for this page.

  bool filterVisibility = false;

  QueryFiltersStruct? psQueryFilters;
  void updatePsQueryFiltersStruct(Function(QueryFiltersStruct) updateFn) {
    updateFn(psQueryFilters ??= QueryFiltersStruct());
  }

  String? psSearchText;

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

  String? psPlacesSessionToken;

  PlaceDetailsDataStruct? placeSelected;
  void updatePlaceSelectedStruct(Function(PlaceDetailsDataStruct) updateFn) {
    updateFn(placeSelected ??= PlaceDetailsDataStruct());
  }

  QueryFiltersStruct? psFiltersDraft;
  void updatePsFiltersDraftStruct(Function(QueryFiltersStruct) updateFn) {
    updateFn(psFiltersDraft ??= QueryFiltersStruct());
  }

  double budgetMin = 0.0;

  double budgetMax = 40000.0;

  ///  State fields for stateful widgets in this page.

  // Model for NavBarBrides component.
  late NavBarBridesModel navBarBridesModel;
  // Stores action output result for [Custom Action - getPlacePredictions] action in InstantSearchTextField widget.
  PlacePredictionsResultStruct? predictionsResult;
  // Stores action output result for [Custom Action - getPlaceDetailsRich] action in Column widget.
  PlaceDetailsDataStruct? placeCoordinates;
  // State field(s) for Slider widget.
  double? sliderValue;
  // State field(s) for Checkbox_PHOTOGRAPHER widget.
  bool? checkboxPHOTOGRAPHERValue;
  // State field(s) for Checkbox_FILMMAKER widget.
  bool? checkboxFILMMAKERValue;
  // State field(s) for Checkbox_HAIRDRESSER widget.
  bool? checkboxHAIRDRESSERValue;
  // State field(s) for Checkbox_MAKEUP widget.
  bool? checkboxMAKEUPValue;
  // State field(s) for Checkbox_FLORIST widget.
  bool? checkboxFLORISTValue;
  // State field(s) for Checkbox_PLANNER widget.
  bool? checkboxPLANNERValue;
  // State field(s) for Checkbox_DESIGNER widget.
  bool? checkboxDESIGNERValue;
  // State field(s) for Checkbox_VENUES widget.
  bool? checkboxVENUESValue;
  // State field(s) for Checkbox_BRIDAL widget.
  bool? checkboxBRIDALValue;

  @override
  void initState(BuildContext context) {
    navBarBridesModel = createModel(context, () => NavBarBridesModel());
  }

  @override
  void dispose() {
    navBarBridesModel.dispose();
  }
}
