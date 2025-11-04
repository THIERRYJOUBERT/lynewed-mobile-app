import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_filter_sheet_widget.dart' show AddFilterSheetWidget;
import 'package:flutter/material.dart';

class AddFilterSheetModel extends FlutterFlowModel<AddFilterSheetWidget> {
  ///  Local state fields for this component.

  bool professionVisible = false;

  bool budgetVisible = false;

  double? budgetMin;

  double? budgetMax;

  List<Profession> selectedProfessions = [];
  void addToSelectedProfessions(Profession item) =>
      selectedProfessions.add(item);
  void removeFromSelectedProfessions(Profession item) =>
      selectedProfessions.remove(item);
  void removeAtIndexFromSelectedProfessions(int index) =>
      selectedProfessions.removeAt(index);
  void insertAtIndexInSelectedProfessions(int index, Profession item) =>
      selectedProfessions.insert(index, item);
  void updateSelectedProfessionsAtIndex(
          int index, Function(Profession) updateFn) =>
      selectedProfessions[index] = updateFn(selectedProfessions[index]);

  bool showPros = false;

  bool showProRecent = false;

  bool showWeddingPins = false;

  bool showProAlerts = false;

  bool typeVisible = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - resetAndApplyDefaultFilters] action in Row widget.
  QueryFiltersStruct? newDefaultFilters;
  // State field(s) for CheckboxProfessional widget.
  bool? checkboxProfessionalValue;
  // State field(s) for CheckboxProRecent widget.
  bool? checkboxProRecentValue;
  // State field(s) for CheckboxAlert widget.
  bool? checkboxAlertValue;
  // State field(s) for CheckboxWeddingPin widget.
  bool? checkboxWeddingPinValue;
  // State field(s) for Checkbox_PHOTOGRAPHER widget.
  bool? checkboxPHOTOGRAPHERValue;
  // State field(s) for Checkbox_FILMMAKER widget.
  bool? checkboxFILMMAKERValue;
  // State field(s) for Checkbox_HAIRDRESSER widget.
  bool? checkboxHAIRDRESSERValue;
  // State field(s) for Checkbox_BRIDALDESIGNER widget.
  bool? checkboxBRIDALDESIGNERValue;
  // State field(s) for Checkbox_MAKEUP widget.
  bool? checkboxMAKEUPValue;
  // State field(s) for Checkbox_FLORIST widget.
  bool? checkboxFLORISTValue;
  // State field(s) for Checkbox_PLANNER widget.
  bool? checkboxPLANNERValue;
  // State field(s) for Checkbox_PHOTOMOVIE widget.
  bool? checkboxPHOTOMOVIEValue;
  // State field(s) for Checkbox_DESIGNER widget.
  bool? checkboxDESIGNERValue;
  // State field(s) for Checkbox_VENUES widget.
  bool? checkboxVENUESValue;
  // State field(s) for Checkbox_BRIDAL widget.
  bool? checkboxBRIDALValue;
  // State field(s) for Checkbox_MAKEUPARTIST widget.
  bool? checkboxMAKEUPARTISTValue;
  // State field(s) for Checkbox_EVENTDESIGNER widget.
  bool? checkboxEVENTDESIGNERValue;
  // Stores action output result for [Custom Action - filtersToJsonString] action in Button widget.
  String? newFiltersJson;
  // Stores action output result for [Custom Action - saveUserPreferences] action in Button widget.
  UserPreferencesStruct? saveUserPreferencesSuccess;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
