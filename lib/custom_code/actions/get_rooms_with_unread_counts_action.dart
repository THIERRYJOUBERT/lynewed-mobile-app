// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<InboxResultStruct?> getRoomsWithUnreadCountsAction(int? limit) async {
  // --- Helpers de parsing Enum ---
  MessageType messageTypeFromString(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'text':
      default:
        return MessageType.text;
    }
  }

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

  // CORRIGÉ: Helper pour l'Enum ConversationStatus
  ConversationStatus conversationStatusFromString(String? s) {
    switch (s) {
      case 'archived':
        return ConversationStatus.archived;
      case 'active':
      default:
        return ConversationStatus.active;
    }
  }
  // --- Fin des Helpers ---

  try {
    final client = SupaFlow.client;
    final params = <String, dynamic>{};
    if (limit != null && limit > 0) {
      params['p_limit'] = limit;
    }
    final res =
        await client.rpc('get_rooms_with_unread_counts', params: params);
    final items = <ConversationListItemStruct>[];

    final list = (res is Map && res['items'] is List)
        ? (res['items'] as List)
        : const [];
    
    for (final row in list) {
      if (row is! Map) continue;

      final lastAtStr = row['lastMessageAt']?.toString();
      final lastAt = lastAtStr != null ? DateTime.tryParse(lastAtStr) : null;

      final otherAvatar =
          stringToImagePath(row['otherAvatarUrl']?.toString() ?? '');
      final publicCover =
          stringToImagePath(row['publicCoverUrl']?.toString() ?? '');

      items.add(
        ConversationListItemStruct(
          roomId: row['roomId']?.toString() ?? '',
          roomType: roomTypeFromString(row['roomType']?.toString()), // CORRIGÉ
          conversationStatus: conversationStatusFromString(
              row['conversationStatus']?.toString()), // CORRIGÉ
          unreadCount: (row['unreadCount'] is num)
              ? (row['unreadCount'] as num).toInt()
              : 0,
          lastMessageType:
              messageTypeFromString(row['lastMessageType']?.toString()),
          lastMessageText: row['lastMessageText']?.toString() ?? '',
          lastMessageAt: lastAt,
          otherProfileId: row['otherProfileId']?.toString(),
          otherFullName: row['otherFullName']?.toString(),
          otherAvatarUrl: otherAvatar,
          otherRole: userRoleFromString(row['otherRole']?.toString()),
          publicTitle: row['publicTitle']?.toString(),
          publicCoverUrl: publicCover,
          audienceRole: userRoleFromString(row['audienceRole']?.toString()),
        ),
      );
    }

    return InboxResultStruct(items: items);
  } catch (e) {
    return InboxResultStruct(items: []);
  }
}
