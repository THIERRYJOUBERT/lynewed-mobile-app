import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'points_of_interest_sheet_widget.dart' show PointsOfInterestSheetWidget;
import 'package:flutter/material.dart';

class PointsOfInterestSheetModel
    extends FlutterFlowModel<PointsOfInterestSheetWidget> {
  ///  Local state fields for this component.

  List<WeddingPinItemDataStruct> items = [];
  void addToItems(WeddingPinItemDataStruct item) => items.add(item);
  void removeFromItems(WeddingPinItemDataStruct item) => items.remove(item);
  void removeAtIndexFromItems(int index) => items.removeAt(index);
  void insertAtIndexInItems(int index, WeddingPinItemDataStruct item) =>
      items.insert(index, item);
  void updateItemsAtIndex(
          int index, Function(WeddingPinItemDataStruct) updateFn) =>
      items[index] = updateFn(items[index]);

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getBrideInterestItemsAction] action in PointsOfInterestSheet widget.
  List<WeddingPinItemDataStruct>? fetchedItems;
  // Stores action output result for [Custom Action - deleteUserPoi] action in Icon widget.
  bool? deleteUserPoiConfirm;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
