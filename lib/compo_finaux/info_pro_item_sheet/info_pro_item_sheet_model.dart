import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'info_pro_item_sheet_widget.dart' show InfoProItemSheetWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InfoProItemSheetModel extends FlutterFlowModel<InfoProItemSheetWidget> {
  ///  Local state fields for this component.

  bool fav = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - toggleWishlistAction] action in ToggleIcon widget.
  bool? toggleResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
