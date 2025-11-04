import '/flutter_flow/flutter_flow_util.dart';
import 'video_call_page_widget.dart' show VideoCallPageWidget;
import 'package:flutter/material.dart';

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
