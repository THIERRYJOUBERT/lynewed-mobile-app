import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'item_all_alert_widget.dart' show ItemAllAlertWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemAllAlertModel extends FlutterFlowModel<ItemAllAlertWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - cancelProfessionalAlertAction] action in Delete widget.
  bool? deleteAlert;
  // Stores action output result for [Custom Action - getProItemDetailsAction] action in Button widget.
  ProDetailsStruct? getProDetails;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
