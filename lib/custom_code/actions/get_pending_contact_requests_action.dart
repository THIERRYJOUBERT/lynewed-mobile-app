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
UserRole _userRoleFromString(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'professional':
      return UserRole.professional;
    case 'bride':
    default:
      return UserRole.bride;
  }
}

ConnectionRequestSource _sourceFromString(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'wishlist':
      return ConnectionRequestSource.wishlist;
    case 'weddingpin':
      return ConnectionRequestSource.weddingPin;
    case 'alert':
      return ConnectionRequestSource.alert;
    case 'protopro':
      return ConnectionRequestSource.proToPro;
    case 'map':
    default:
      return ConnectionRequestSource.map;
  }
}

Future<ContactRequestsResultStruct?> getPendingContactRequestsAction() async {
  try {
    final client = SupaFlow.client;
    final res = await client.rpc('get_pending_contact_requests');
    final list = (res is Map && res['items'] is List)
        ? (res['items'] as List)
        : const [];
    final items = <ContactRequestItemStruct>[];

    for (final row in list) {
      if (row is! Map) continue;
      final createdStr = row['createdAt']?.toString();
      final createdAt =
          createdStr != null ? DateTime.tryParse(createdStr) : null;
      items.add(
        ContactRequestItemStruct(
          requestId: row['requestId']?.toString() ?? '',
          initiatorId: row['initiatorId']?.toString(),
          otherProfileId: row['otherProfileId']?.toString() ?? '',
          otherRole: _userRoleFromString(row['otherRole']?.toString()),
          otherFullName: row['otherFullName']?.toString() ?? '',
          otherAvatarUrl:
              stringToImagePath(row['otherAvatarUrl']?.toString() ?? ''),
          source: _sourceFromString(row['source']?.toString()),
          initialMessage: row['initialMessage']?.toString(),
          createdAt: createdAt,
          // *** MODIFICATION ICI ***
          // On récupère le roomId renvoyé par la RPC
          roomId: row['roomId']?.toString() ?? '',
        ),
      );
    }
    return ContactRequestsResultStruct(items: items);
  } catch (e) {
    return ContactRequestsResultStruct(items: []);
  }
}
