import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'chat_details_widget.dart' show ChatDetailsWidget;
import 'package:flutter/material.dart';

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
