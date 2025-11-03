import '/backend/schema/structs/index.dart';
import '/components/select_date_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'create_edit_alert_sheet_widget.dart' show CreateEditAlertSheetWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateEditAlertSheetModel
    extends FlutterFlowModel<CreateEditAlertSheetWidget> {
  ///  Local state fields for this component.

  List<AlertMotifStruct> motifsList = [];
  void addToMotifsList(AlertMotifStruct item) => motifsList.add(item);
  void removeFromMotifsList(AlertMotifStruct item) => motifsList.remove(item);
  void removeAtIndexFromMotifsList(int index) => motifsList.removeAt(index);
  void insertAtIndexInMotifsList(int index, AlertMotifStruct item) =>
      motifsList.insert(index, item);
  void updateMotifsListAtIndex(
          int index, Function(AlertMotifStruct) updateFn) =>
      motifsList[index] = updateFn(motifsList[index]);

  String? selectedMotifCode;

  PlaceDetailsDataStruct? selectedPlace;
  void updateSelectedPlaceStruct(Function(PlaceDetailsDataStruct) updateFn) {
    updateFn(selectedPlace ??= PlaceDetailsDataStruct());
  }

  DateTime? endDate;

  String? psPlacesSessionToken;

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

  LatLng? placeLatLng;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - fetchAlertMotifsAction] action in CreateEditAlertSheet widget.
  List<AlertMotifStruct>? fetchedMotifs;
  // State field(s) for DropDownMotif widget.
  String? dropDownMotifValue;
  FormFieldController<String>? dropDownMotifValueController;
  // Stores action output result for [Custom Action - getPlacePredictions] action in InstantSearchTextField widget.
  PlacePredictionsResultStruct? predictionsResult;
  // Stores action output result for [Custom Action - getPlaceDetailsRich] action in Column widget.
  PlaceDetailsDataStruct? placeCoordinates;
  // State field(s) for TextField_Details widget.
  FocusNode? textFieldDetailsFocusNode;
  TextEditingController? textFieldDetailsTextController;
  String? Function(BuildContext, String?)?
      textFieldDetailsTextControllerValidator;
  // Stores action output result for [Custom Action - createProfessionalAlertAction] action in Button widget.
  String? newAlertId;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldDetailsFocusNode?.dispose();
    textFieldDetailsTextController?.dispose();
  }
}
