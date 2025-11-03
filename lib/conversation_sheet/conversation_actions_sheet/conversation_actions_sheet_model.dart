import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'conversation_actions_sheet_widget.dart'
    show ConversationActionsSheetWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ConversationActionsSheetModel
    extends FlutterFlowModel<ConversationActionsSheetWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Update Row(s)] action in Archive widget.
  List<ChatRoomParticipantsRow>? updateStatus;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
