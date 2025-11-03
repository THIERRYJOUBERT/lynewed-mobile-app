import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'startup_gate_widget.dart' show StartupGateWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
