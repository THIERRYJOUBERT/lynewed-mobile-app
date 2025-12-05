// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
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
              contactStatus: itemData['contactStatus']?.toString() ?? 'none',
            );
          }
          // Retourne une valeur par défaut vide si le format est incorrect
          return WishlistedByBrideItemStruct();
        })
        .where((item) => item.brideProfileId.isNotEmpty)
        .toList();
  } catch (e) {
    return [];
  }
}
