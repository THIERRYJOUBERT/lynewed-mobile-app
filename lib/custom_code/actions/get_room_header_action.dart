// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<ChatRoomHeaderStruct?> getRoomHeaderAction(String roomId) async {
  // --- Helpers de parsing Enum ---
  UserRole? userRoleFromString(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'professional':
        return UserRole.professional;
      case 'bride':
        return UserRole.bride;
      default:
        return null;
    }
  }

  // CORRIGÉ: Helper pour l'Enum RoomType
  RoomType roomTypeFromString(String? s) {
    return (s ?? 'private') == 'public' ? RoomType.public : RoomType.private;
  }
  // --- Fin des Helpers ---

  try {
    final client = SupaFlow.client;
    final res = await client.rpc('get_room_header', params: {
      'p_room_id': roomId,
    });
    if (res is! Map) return null;

    final roomTypeStr = res['roomType']?.toString() ?? 'private';
    final roomTypeEnum = roomTypeFromString(roomTypeStr); // CORRIGÉ

    if (roomTypeEnum == RoomType.private) {
      return ChatRoomHeaderStruct(
        roomType: roomTypeEnum, // CORRIGÉ
        otherProfileId: res['otherProfileId']?.toString(),
        otherFullName: res['otherFullName']?.toString(),
        otherAvatarUrl:
            stringToImagePath(res['otherAvatarUrl']?.toString() ?? ''),
        otherRole: userRoleFromString(res['otherRole']?.toString()),
      );
    } else {
      return ChatRoomHeaderStruct(
        roomType: roomTypeEnum, // CORRIGÉ
        publicTitle: res['publicTitle']?.toString(),
        publicCoverUrl:
            stringToImagePath(res['publicCoverUrl']?.toString() ?? ''),
        audienceRole: userRoleFromString(res['audienceRole']?.toString()),
      );
    }
  } catch (e) {
    debugPrint('getRoomHeaderAction error: $e');
    return null;
  }
}
