import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/conversation_sheet/my_message_actions_sheet/my_message_actions_sheet_widget.dart';
import '/conversation_sheet/other_message_actions_sheet/other_message_actions_sheet_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'chat_details_widget.dart' show ChatDetailsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatDetailsModel extends FlutterFlowModel<ChatDetailsWidget> {
  ///  Local state fields for this page.

  String? psRoomId = '';

  bool psIsPublic = false;

  String? psRequestId;

  bool psReviewMode = false;

  String? psOtherProfileId;

  ChatRoomHeaderStruct? psRoomHeader;
  void updatePsRoomHeaderStruct(Function(ChatRoomHeaderStruct) updateFn) {
    updateFn(psRoomHeader ??= ChatRoomHeaderStruct());
  }

  bool psShowScrollToBottom = false;

  bool psIsRoomEmpty = false;

  bool psFirstMessageTextOnly = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - validateChatDetailsParams] action in ChatDetails widget.
  bool? validateParameters;
  // Stores action output result for [Custom Action - joinPublicRoomIfNeededAction] action in ChatDetails widget.
  bool? joinSuccess;
  // Stores action output result for [Custom Action - getRoomHeaderAction] action in ChatDetails widget.
  ChatRoomHeaderStruct? publicRoomHeader;
  // Stores action output result for [Backend Call - Update Row(s)] action in ChatDetails widget.
  List<ChatRoomParticipantsRow>? updateLastReadMessagePublic;
  // Stores action output result for [Custom Action - getRoomHeaderAction] action in ChatDetails widget.
  ChatRoomHeaderStruct? roomHeaderResult;
  // Stores action output result for [Backend Call - Update Row(s)] action in ChatDetails widget.
  List<ChatRoomParticipantsRow>? updateLastReadMessage;
  // Stores action output result for [Custom Action - checkAndRequestPermission] action in IconVisio widget.
  String? cameraPermissionResult;
  // Stores action output result for [Custom Action - checkAndRequestPermission] action in IconVisio widget.
  String? micPermissionResult;
  // Stores action output result for [Custom Action - startVideoSessionAction] action in IconVisio widget.
  VideoSessionsRow? createdVideoSession;
  // Stores action output result for [Custom Action - getAgoraTokenAction] action in IconVisio widget.
  String? agoraToken;
  // Stores action output result for [Backend Call - Update Row(s)] action in ChatMessageList widget.
  List<ChatRoomParticipantsRow>? updateLastRead;
  // Stores action output result for [Custom Action - getRoomHeaderAction] action in ChatMessageList widget.
  ChatRoomHeaderStruct? acceptedRoomHeader;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
