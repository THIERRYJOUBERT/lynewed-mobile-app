// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<List<WishlistedByBrideItemStruct>> getWishlistedByBridesAction() async {
  try {
    final response = await SupaFlow.client.rpc('get_wishlisted_by_brides');

    if (response == null ||
        response is! Map<String, dynamic> ||
        response['items'] == null ||
        response['items'] is! List) {
      print('getWishlistedByBridesAction: Invalid RPC response format.');
      return [];
    }

    final List<dynamic> itemList = response['items'];
    return itemList
        .map<WishlistedByBrideItemStruct>((itemData) {
          if (itemData is Map<String, dynamic>) {
            final addedAtStr = itemData['addedAt']?.toString();
            return WishlistedByBrideItemStruct(
              brideProfileId: itemData['brideProfileId']?.toString() ?? '',
              fullName: itemData['fullName']?.toString() ?? '',
              avatarUrl: itemData['avatarUrl']?.toString() ?? '',
              addedAt:
                  addedAtStr != null ? DateTime.tryParse(addedAtStr) : null,
            );
          }
          // Retourne une valeur par défaut vide si le format est incorrect
          return WishlistedByBrideItemStruct();
        })
        .where((item) => item.brideProfileId.isNotEmpty)
        .toList();
  } catch (e) {
    print('getWishlistedByBridesAction error: $e');
    return [];
  }
}
