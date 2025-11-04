import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'startup_gate_widget.dart' show StartupGateWidget;
import 'package:flutter/material.dart';

class StartupGateModel extends FlutterFlowModel<StartupGateWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getInitialDeepLink] action in StartupGate widget.
  String? initialLinkUrl;
  // Stores action output result for [Custom Action - loadInitialSessionData] action in StartupGate widget.
  SessionDataBundleStruct? sessionData;
  // Stores action output result for [Custom Action - checkTosAccepted] action in StartupGate widget.
  bool? tosAccepted;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
