import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'home_brides_widget.dart' show HomeBridesWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeBridesModel extends FlutterFlowModel<HomeBridesWidget> {
  ///  Local state fields for this page.

  List<PublicChatRoomItemStruct> psPublicRooms = [];
  void addToPsPublicRooms(PublicChatRoomItemStruct item) =>
      psPublicRooms.add(item);
  void removeFromPsPublicRooms(PublicChatRoomItemStruct item) =>
      psPublicRooms.remove(item);
  void removeAtIndexFromPsPublicRooms(int index) =>
      psPublicRooms.removeAt(index);
  void insertAtIndexInPsPublicRooms(int index, PublicChatRoomItemStruct item) =>
      psPublicRooms.insert(index, item);
  void updatePsPublicRoomsAtIndex(
          int index, Function(PublicChatRoomItemStruct) updateFn) =>
      psPublicRooms[index] = updateFn(psPublicRooms[index]);

  int unreadNotificationsCount = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getPublicChatRoomsForBridesAction] action in HomeBrides widget.
  PublicRoomsResultStruct? publicRoomsResult;
  // Stores action output result for [Custom Action - getUnreadNotificationsCount] action in HomeBrides widget.
  int? getUnreadNotifBrides;
  // Stores action output result for [Custom Action - getPublicChatRoomsForBridesAction] action in ListView widget.
  PublicRoomsResultStruct? refreshedPublicRooms;
  // Stores action output result for [Custom Action - joinPublicRoomIfNeededAction] action in Container widget.
  bool? joinSuccess;
  // Model for NavBarBrides component.
  late NavBarBridesModel navBarBridesModel;

  @override
  void initState(BuildContext context) {
    navBarBridesModel = createModel(context, () => NavBarBridesModel());
  }

  @override
  void dispose() {
    navBarBridesModel.dispose();
  }
}
