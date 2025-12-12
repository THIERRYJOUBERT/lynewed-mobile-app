// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';

/// Fetches all published wed_articles for WOTW history
/// Returns a list of simplified article summaries (id, title, coverImages, publishedAt)
Future<List<WedArticleSummaryStruct>> getAllWedArticles(String? lang) async {
  try {
    final client = SupaFlow.client;
    final locale = lang ?? 'en';

    // Fetch all published articles ordered by published_at desc
    final response = await client
        .from('wed_articles')
        .select('id, title, cover_images, published_at')
        .eq('is_published', true)
        .order('published_at', ascending: false);

    if (response is! List) {
      return [];
    }

    final List<WedArticleSummaryStruct> articles = [];

    for (final row in response) {
      if (row is Map<String, dynamic>) {
        // Parse title based on locale
        String title = 'Untitled';
        final titleData = row['title'];
        if (titleData is Map<String, dynamic>) {
          title = titleData[locale]?.toString() ?? 
                  titleData['en']?.toString() ?? 
                  'Untitled';
        } else if (titleData is String) {
          title = titleData;
        }

        // Parse cover images
        final List<String> coverImages = [];
        final coverData = row['cover_images'];
        if (coverData is List) {
          for (final img in coverData) {
            if (img is String) {
              coverImages.add(img);
            }
          }
        }

        // Parse published_at
        DateTime? publishedAt;
        final pubData = row['published_at'];
        if (pubData is String) {
          publishedAt = DateTime.tryParse(pubData);
        }

        articles.add(WedArticleSummaryStruct(
          id: row['id']?.toString() ?? '',
          title: title,
          coverImages: coverImages,
          publishedAt: publishedAt,
        ));
      }
    }

    return articles;
  } catch (e) {
    return [];
  }
}
