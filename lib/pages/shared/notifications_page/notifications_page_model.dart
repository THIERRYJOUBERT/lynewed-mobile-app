import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'notifications_page_widget.dart' show NotificationsPageWidget;
import 'package:flutter/material.dart';

class NotificationsPageModel extends FlutterFlowModel<NotificationsPageWidget> {
  ///  Local state fields for this page.

  List<AppNotificationStruct> listNotifications = [];
  void addToListNotifications(AppNotificationStruct item) =>
      listNotifications.add(item);
  void removeFromListNotifications(AppNotificationStruct item) =>
      listNotifications.remove(item);
  void removeAtIndexFromListNotifications(int index) =>
      listNotifications.removeAt(index);
  void insertAtIndexInListNotifications(
          int index, AppNotificationStruct item) =>
      listNotifications.insert(index, item);
  void updateListNotificationsAtIndex(
          int index, Function(AppNotificationStruct) updateFn) =>
      listNotifications[index] = updateFn(listNotifications[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getNotificationsAction] action in NotificationsPage widget.
  List<AppNotificationStruct>? allNotifications;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
