import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'incoming_call_sheet_widget.dart' show IncomingCallSheetWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IncomingCallSheetModel extends FlutterFlowModel<IncomingCallSheetWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - updateVideoSessionStatusAction] action in Button_On widget.
  bool? updateVideoSessionResult;
  // Stores action output result for [Custom Action - getAgoraTokenAction] action in Button_On widget.
  String? agoraToken;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
