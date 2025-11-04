// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
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
    debugPrint('getPublicChatRoomsForBridesAction error: $e');
    return PublicRoomsResultStruct(items: []);
  }
}
