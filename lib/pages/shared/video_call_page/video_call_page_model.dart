import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'video_call_page_widget.dart' show VideoCallPageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VideoCallPageModel extends FlutterFlowModel<VideoCallPageWidget> {
  ///  Local state fields for this page.

  bool isMuted = false;

  bool isCameraOff = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - updateVideoSessionStatusAction] action in AgoraVideoView widget.
  bool? updateVideoSessionStatusActionEndCall;
  // Stores action output result for [Custom Action - updateVideoSessionStatusAction] action in Button_End widget.
  bool? updateVideoSessionStatusActionResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
