// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Gets the list of favorited professionals for the current user.
///
/// TODO: Migrate to Feed/Wishlist module in Clean Architecture.
/// This function handles FlutterFlow [ProDetailsStruct] and should be
/// migrated to the wishlist feature module.
///
/// Target migration: lib/features/wishlist/data/repositories/

Profession _professionFromString(String? s) {
  if (s == null) return Profession.PHOTOGRAPHER; // Fallback
  try {
    return Profession.values
        .firstWhere((e) => e.name.toUpperCase() == s.toUpperCase());
  } catch (e) {
    return Profession.PHOTOGRAPHER; // Fallback
  }
}

SubscriptionTierType _tierFromString(String? s) {
  switch (s) {
    case 'trial':
      return SubscriptionTierType.trial;
    case 'earlyAccess':
      return SubscriptionTierType.earlyAccess;
    case 'premiumVisibility':
      return SubscriptionTierType.premiumVisibility;
    case 'ultimateAccess':
      return SubscriptionTierType.ultimateAccess;
    case 'inactive':
    default:
      return SubscriptionTierType.inactive;
  }
}

List<LatLng> _fixedLocationsFromJson(dynamic json) {
  if (json is! List) return [];
  return json
      .map<LatLng>((loc) {
        if (loc is Map<String, dynamic> &&
            loc.containsKey('lat') &&
            loc.containsKey('lng')) {
          final lat = (loc['lat'] as num?)?.toDouble();
          final lng = (loc['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            return LatLng(lat, lng);
          }
        }
        return const LatLng(0, 0); // Fallback
      })
      .where((ll) => ll.latitude != 0 && ll.longitude != 0)
      .toList();
}

// --- Fin des Helpers ---

Future<List<ProDetailsStruct>> getFavoritedProfessionalsAction() async {
  try {
    final response = await SupaFlow.client.rpc('get_favorited_professionals');

    if (response == null ||
        response is! Map<String, dynamic> ||
        response['items'] == null ||
        response['items'] is! List) {
      return [];
    }

    final List<dynamic> itemList = response['items'];
    final List<ProDetailsStruct> proDetailsList = [];

    for (var itemData in itemList) {
      if (itemData is Map<String, dynamic>) {
        proDetailsList.add(
          ProDetailsStruct(
            proProfileId: itemData['proProfileId']?.toString() ?? '',
            fullName: itemData['fullName']?.toString() ?? '',
            avatarUrl: itemData['avatarUrl']?.toString() ?? '',
            businessName: itemData['businessName']?.toString() ?? '',
            profession:
                _professionFromString(itemData['profession']?.toString()),
            budgetMin: (itemData['budgetMin'] as num?)?.toInt(),
            budgetMax: (itemData['budgetMax'] as num?)?.toInt(),
            currency: itemData['currency']?.toString(),
            subscriptionTier:
                _tierFromString(itemData['subscriptionTier']?.toString()),
            locationLabel: itemData['locationLabel']?.toString() ?? '',
            coverImageUrl: itemData['coverImageUrl']?.toString() ?? '',
            isFavorited: itemData['isFavorited'] as bool? ?? true,
            isLive: itemData['isLive'] as bool? ?? false,
            description: itemData['description']?.toString() ?? '',
            portfolioImages: List<String>.from(
                (itemData['portfolioImages'] as List?)
                        ?.map((e) => e.toString()) ??
                    []),
            slideshowImages: List<String>.from(
                (itemData['slideshowImages'] as List?)
                        ?.map((e) => e.toString()) ??
                    []),
            profileVideoUrl: itemData['profileVideoUrl']?.toString(),
            fixedLocations: _fixedLocationsFromJson(itemData['fixedLocations']),
            instagramUrl: itemData['instagramUrl']?.toString(),
            websiteUrl: itemData['websiteUrl']?.toString(),
            canBeContactedByBride:
                itemData['canBeContactedByBride'] as bool? ?? false,
            canContactBride: itemData['canContactBride'] as bool? ?? false,
          ),
        );
      }
    }

    return proDetailsList;
  } catch (e) {
    return []; // Retourne une liste vide en cas d'erreur
  }
}
