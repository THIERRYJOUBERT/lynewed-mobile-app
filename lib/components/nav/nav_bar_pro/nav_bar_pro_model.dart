import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'nav_bar_pro_widget.dart' show NavBarProWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NavBarProModel extends FlutterFlowModel<NavBarProWidget> {
  ///  Local state fields for this component.

  int number = 1;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getProItemDetailsAction] action in Column_Profil widget.
  ProDetailsStruct? proDetails;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
