import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'feed_detail_viewer_widget.dart' show FeedDetailViewerWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FeedDetailViewerModel extends FlutterFlowModel<FeedDetailViewerWidget> {
  ///  Local state fields for this page.

  bool fav = false;

  bool isLoadingFav = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - toggleWishlistAction] action in ToggleIcon widget.
  bool? newFavStatus;
  // Stores action output result for [Custom Action - getProItemDetailsAction] action in Button widget.
  ProDetailsStruct? getProDetails;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
