import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/compo_finaux/create_edit_point_of_interest_sheet/create_edit_point_of_interest_sheet_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/random_data_util.dart' as random_data;
import 'points_of_interest_sheet_widget.dart' show PointsOfInterestSheetWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
