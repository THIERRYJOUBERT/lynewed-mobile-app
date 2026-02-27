import '/backend/schema/structs/index.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'messages_brides_widget.dart' show MessagesBridesWidget;
import 'package:flutter/material.dart';

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
