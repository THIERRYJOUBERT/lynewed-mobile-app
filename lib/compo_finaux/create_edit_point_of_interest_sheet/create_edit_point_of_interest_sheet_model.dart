import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'create_edit_point_of_interest_sheet_widget.dart'
    show CreateEditPointOfInterestSheetWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CreateEditPointOfInterestSheetModel
    extends FlutterFlowModel<CreateEditPointOfInterestSheetWidget> {
  ///  Local state fields for this component.

  bool isPublic = false;

  double? budgetMin;

  double? budgetMax;

  List<Profession> professions = [];
  void addToProfessions(Profession item) => professions.add(item);
  void removeFromProfessions(Profession item) => professions.remove(item);
  void removeAtIndexFromProfessions(int index) => professions.removeAt(index);
  void insertAtIndexInProfessions(int index, Profession item) =>
      professions.insert(index, item);
  void updateProfessionsAtIndex(int index, Function(Profession) updateFn) =>
      professions[index] = updateFn(professions[index]);

  PlaceDetailsDataStruct? selectedPlace;
  void updateSelectedPlaceStruct(Function(PlaceDetailsDataStruct) updateFn) {
    updateFn(selectedPlace ??= PlaceDetailsDataStruct());
  }

  DateTime? eventStartDate;

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

  // Stores action output result for [Custom Action - getPlacePredictions] action in InstantSearchTextField widget.
  PlacePredictionsResultStruct? predictionsResult;
  // Stores action output result for [Custom Action - getPlaceDetailsRich] action in Column widget.
  PlaceDetailsDataStruct? placeCoordinates;
  // State field(s) for Checkbox_nearby widget.
  bool? checkboxNearbyValue;
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
  // State field(s) for TextField_Date widget.
  FocusNode? textFieldDateFocusNode;
  TextEditingController? textFieldDateTextController;
  late MaskTextInputFormatter textFieldDateMask;
  String? Function(BuildContext, String?)? textFieldDateTextControllerValidator;
  // Stores action output result for [Custom Action - upsertWeddingPin] action in Button widget.
  String? newPinId;
  // Stores action output result for [Custom Action - upsertUserPoi] action in Button widget.
  String? newPoiId;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldDateFocusNode?.dispose();
    textFieldDateTextController?.dispose();
  }
}
