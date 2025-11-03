import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'preference_widget.dart' show PreferenceWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
