// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
// --- Custom Action a besoin de quelques helpers pour le parsing ---
// Il est recommandé de les mettre en haut du fichier pour la clarté.

Profession _professionFromString(String? s) {
  // Recherche insensible à la casse et retourne une valeur par défaut si non trouvée
  return Profession.values.firstWhere(
    (e) => e.name.toUpperCase() == (s ?? '').toUpperCase(),
    orElse: () => Profession.PHOTOGRAPHER, // Valeur de fallback sûre
  );
}

SubscriptionTierType _tierFromString(String? s) {
  return SubscriptionTierType.values.firstWhere(
    (e) => e.name.toLowerCase() == (s ?? '').toLowerCase(),
    orElse: () => SubscriptionTierType.inactive,
  );
}
// --- Fin des Helpers ---

Future<WedArticleStruct?> getLatestWedArticle(String? lang) async {
  try {
    final client = SupaFlow.client;
    final locale =
        lang ?? 'en'; // Assurer une valeur par défaut si la langue est nulle

    final response = await client.rpc(
      'get_latest_wed_article',
      params: {'p_lang': locale},
    );

    if (response == null || response is! Map<String, dynamic>) {
      debugPrint(
          'get_latest_wed_article: La réponse de la RPC est nulle ou invalide.');
      return null;
    }

    final Map<String, dynamic> data = response;

    // --- Parsing des blocs de contenu ---
    final List<WedContentBlockStruct> contentBlocks = [];
    if (data['contentBlocks'] is List) {
      for (final blockJson in data['contentBlocks']) {
        if (blockJson is Map<String, dynamic>) {
          final List<String> imageUrls = (blockJson['imageUrls'] as List?)
                  ?.map((url) => url.toString())
                  .toList() ??
              [];

          contentBlocks.add(WedContentBlockStruct(
            type: blockJson['type']?.toString() ?? 'unknown',
            text: blockJson['text']?.toString(),
            imageUrls: imageUrls,
            layout: blockJson['layout']?.toString(),
            columns: (blockJson['columns'] as num?)
                ?.toInt(), // <-- AJOUTE CETTE LIGNE
          ));
        }
      }
    }

    // --- Parsing du professionnel ---
    ProDetailsStruct? professional;
    if (data['professional'] is Map<String, dynamic>) {
      final proData = data['professional'] as Map<String, dynamic>;

      final List<String> portfolioImages = (proData['portfolioImages'] as List?)
              ?.map((url) => url.toString())
              .toList() ??
          [];

      final List<LatLng> fixedLocations = [];
      if (proData['fixedLocations'] is List) {
        for (final loc in proData['fixedLocations']) {
          if (loc is Map<String, dynamic> &&
              loc['coordinates'] is List &&
              (loc['coordinates'] as List).length >= 2) {
            final coords = loc['coordinates'] as List;
            fixedLocations
                .add(LatLng(coords[1] as double, coords[0] as double));
          }
        }
      }

      professional = ProDetailsStruct(
        proProfileId: proData['profileId']?.toString(),  // Corrigé: la RPC retourne 'profileId' pas 'proProfileId'
        fullName: proData['fullName']?.toString(),
        avatarUrl: proData['avatarUrl']?.toString(),
        businessName: proData['businessName']?.toString(),
        profession: _professionFromString(proData['profession']?.toString()),
        budgetMin: (proData['budgetMin'] as num?)?.toInt(),
        budgetMax: (proData['budgetMax'] as num?)?.toInt(),
        currency: proData['currency']?.toString(),
        subscriptionTier:
            _tierFromString(proData['subscriptionTier']?.toString()),
        locationLabel: proData['locationLabel']?.toString(),
        coverImageUrl: proData['coverImageUrl']?.toString(),
        isFavorited: proData['isFavorited'] as bool?,
        isLive: proData['isLive'] as bool?,
        description: proData['description']?.toString(),
        instagramUrl: (proData['socials'] is Map)
            ? proData['socials']['instagramUrl']?.toString()
            : null,
        websiteUrl: (proData['socials'] is Map)
            ? proData['socials']['websiteUrl']?.toString()
            : null,
        canBeContactedByBride: proData['canBeContactedByBride'] as bool?,
        canContactBride: proData['canContactBride'] as bool?,
        portfolioImages: portfolioImages,
        fixedLocations: fixedLocations,
      );
    }

    // --- Assemblage de l'article final ---
    final List<String> coverImages =
        (data['coverImages'] as List?)?.map((url) => url.toString()).toList() ??
            [];

    return WedArticleStruct(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Untitled',
      coverImages: coverImages,
      contentBlocks: contentBlocks,
      professional: professional,
    );
  } catch (e) {
    debugPrint('Erreur critique dans getLatestWedArticle: $e');
    // En cas d'erreur, retourner null pour que l'UI puisse gérer l'état d'erreur
    return null;
  }
}
