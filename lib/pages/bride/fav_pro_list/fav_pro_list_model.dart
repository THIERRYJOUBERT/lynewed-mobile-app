import '/backend/schema/structs/index.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'fav_pro_list_widget.dart' show FavProListWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FavProListModel extends FlutterFlowModel<FavProListWidget> {
  ///  Local state fields for this page.

  List<ProDetailsStruct> favoritedPros = [];
  void addToFavoritedPros(ProDetailsStruct item) => favoritedPros.add(item);
  void removeFromFavoritedPros(ProDetailsStruct item) =>
      favoritedPros.remove(item);
  void removeAtIndexFromFavoritedPros(int index) =>
      favoritedPros.removeAt(index);
  void insertAtIndexInFavoritedPros(int index, ProDetailsStruct item) =>
      favoritedPros.insert(index, item);
  void updateFavoritedProsAtIndex(
          int index, Function(ProDetailsStruct) updateFn) =>
      favoritedPros[index] = updateFn(favoritedPros[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getFavoritedProfessionalsAction] action in FavProList widget.
  List<ProDetailsStruct>? result;
  // Stores action output result for [Custom Action - toggleWishlistAction] action in IconFavOn widget.
  bool? toggleResultOn;
  // Stores action output result for [Custom Action - toggleWishlistAction] action in IconFavOff widget.
  bool? toggleResultOff;
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
