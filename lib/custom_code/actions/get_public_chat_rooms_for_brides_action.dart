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
Future<PublicRoomsResultStruct?> getPublicChatRoomsForBridesAction() async {
  try {
    final client = SupaFlow.client;
    final res = await client.rpc('get_public_chat_rooms_for_brides');
    final list = (res is Map && res['items'] is List)
        ? (res['items'] as List)
        : const [];
    final items = <PublicChatRoomItemStruct>[];

    for (final row in list) {
      if (row is! Map) continue;
      items.add(
        PublicChatRoomItemStruct(
          roomId: row['roomId']?.toString() ?? '',
          title: row['title']?.toString() ?? '',
          coverImageUrl:
              stringToImagePath(row['coverImageUrl']?.toString() ?? ''),
          activeUsersCount: (row['activeUsersCount'] is num)
              ? (row['activeUsersCount'] as num).toInt()
              : 0,
        ),
      );
    }

    return PublicRoomsResultStruct(items: items);
  } catch (e) {
    print('getPublicChatRoomsForBridesAction error: $e');
    return PublicRoomsResultStruct(items: []);
  }
}
