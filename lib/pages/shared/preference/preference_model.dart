import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/country_filter.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'preference_widget.dart' show PreferenceWidget;
import 'package:flutter/material.dart';

class PreferenceModel extends FlutterFlowModel<PreferenceWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for DropDown_currency widget.
  String? dropDownCurrencyValue;
  FormFieldController<String>? dropDownCurrencyValueController;
  // Stores action output result for [Custom Action - saveUserPreferences] action in DropDown_currency widget.
  UserPreferencesStruct? saveUserPreferencesCurrency;
  // State field(s) for DropDown_Distance widget.
  String? dropDownDistanceValue;
  FormFieldController<String>? dropDownDistanceValueController;
  // Stores action output result for [Custom Action - saveUserPreferences] action in DropDown_Distance widget.
  UserPreferencesStruct? saveUserPreferencesUnit;
  // State field(s) for Country selection
  CountryFilter? selectedCountry;
  // Stores action output result for [Custom Action - saveUserPreferences] action in Country widget.
  UserPreferencesStruct? saveUserPreferencesCountry;
  // Model for HeaderBar component.
  late HeaderBarModel headerBarModel;

  @override
  void initState(BuildContext context) {
    headerBarModel = createModel(context, () => HeaderBarModel());
  }

  @override
  void dispose() {
    headerBarModel.dispose();
  }
}
