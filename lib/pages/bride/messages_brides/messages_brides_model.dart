import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/conversation_sheet/conversation_actions_sheet/conversation_actions_sheet_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import 'messages_brides_widget.dart' show MessagesBridesWidget;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MessagesBridesModel extends FlutterFlowModel<MessagesBridesWidget> {
  ///  Local state fields for this page.

  bool isLoadingInbox = false;

  bool isLoadingRequests = false;

  List<ConversationListItemStruct> psInboxItems = [];
  void addToPsInboxItems(ConversationListItemStruct item) =>
      psInboxItems.add(item);
  void removeFromPsInboxItems(ConversationListItemStruct item) =>
      psInboxItems.remove(item);
  void removeAtIndexFromPsInboxItems(int index) => psInboxItems.removeAt(index);
  void insertAtIndexInPsInboxItems(
          int index, ConversationListItemStruct item) =>
      psInboxItems.insert(index, item);
  void updatePsInboxItemsAtIndex(
          int index, Function(ConversationListItemStruct) updateFn) =>
      psInboxItems[index] = updateFn(psInboxItems[index]);

  List<ContactRequestItemStruct> psRequestItems = [];
  void addToPsRequestItems(ContactRequestItemStruct item) =>
      psRequestItems.add(item);
  void removeFromPsRequestItems(ContactRequestItemStruct item) =>
      psRequestItems.remove(item);
  void removeAtIndexFromPsRequestItems(int index) =>
      psRequestItems.removeAt(index);
  void insertAtIndexInPsRequestItems(
          int index, ContactRequestItemStruct item) =>
      psRequestItems.insert(index, item);
  void updatePsRequestItemsAtIndex(
          int index, Function(ContactRequestItemStruct) updateFn) =>
      psRequestItems[index] = updateFn(psRequestItems[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getRoomsWithUnreadCountsAction] action in MessagesBrides widget.
  InboxResultStruct? inboxResult;
  // Stores action output result for [Custom Action - getPendingContactRequestsAction] action in MessagesBrides widget.
  ContactRequestsResultStruct? requestsResult;
  // Stores action output result for [Custom Action - getRoomsWithUnreadCountsAction] action in ListView widget.
  InboxResultStruct? refreshedInbox;
  // Stores action output result for [Custom Action - getRoomsWithUnreadCountsAction] action in Conversation widget.
  InboxResultStruct? refreshedInboxAfterArchive;
  // Model for HeaderBar component.
  late HeaderBarModel headerBarModel;

  @override
  void initState(BuildContext context) {
    headerBarModel = createModel(context, () => HeaderBarModel());
  }

  @override
  void dispose() {
    headerBarModel.dispose();
  }
}
