// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

/// Fetches a specific WOTW article by ID.
/// IMPORTANT: Must return the same payload shape as getLatestWedArticle
/// (coverImages + contentBlocks + professional) so the renderer behaves identically.
Future<WedArticleStruct?> getWedArticleById(String articleId, String? lang) async {
  try {
    final client = SupaFlow.client;
    final locale = lang ?? 'en';

    final response = await client.rpc(
      'get_wed_article_by_id',
      params: {
        'p_article_id': articleId,
        'p_lang': locale,
      },
    );

    if (response == null || response is! Map<String, dynamic>) {
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
            columns: (blockJson['columns'] as num?)?.toInt(),
          ));
        }
      }
    }

    // --- Parsing du professionnel ---
    ProDetailsStruct? professional;
    if (data['professional'] is Map<String, dynamic>) {
      final proData = data['professional'] as Map<String, dynamic>;

      professional = ProDetailsStruct(
        proProfileId: proData['profileId']?.toString(),
        fullName: proData['fullName']?.toString(),
        avatarUrl: proData['avatarUrl']?.toString(),
        businessName: proData['businessName']?.toString(),
        profession: _professionFromString(proData['profession']?.toString()),
        locationLabel: proData['locationLabel']?.toString(),
        coverImageUrl: proData['coverImageUrl']?.toString(),
        instagramUrl: (proData['socials'] is Map)
            ? proData['socials']['instagramUrl']?.toString()
            : null,
        websiteUrl: (proData['socials'] is Map)
            ? proData['socials']['websiteUrl']?.toString()
            : null,
      );
    }

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
    return null;
  }
}

Profession _professionFromString(String? s) {
  return Profession.values.firstWhere(
    (e) => e.name.toUpperCase() == (s ?? '').toUpperCase(),
    orElse: () => Profession.PHOTOGRAPHER,
  );
}
