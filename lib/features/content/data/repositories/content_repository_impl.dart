/// ContentRepositoryImpl - Supabase implementation of ContentRepository.
///
/// Handles content CRUD operations using Supabase.
/// Works with the wed_articles and replays tables.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/wed_article.dart';
import '../../domain/entities/replay.dart';
import '../../domain/repositories/content_repository.dart';

/// Supabase implementation of ContentRepository.
class ContentRepositoryImpl implements ContentRepository {
  /// Creates the repository with a Supabase client.
  ContentRepositoryImpl({
    required SupabaseClient client,
  }) : _client = client;

  final SupabaseClient _client;

  /// Table name for wedding articles.
  static const _articlesTable = 'wed_articles';

  /// Table name for replays.
  static const _replaysTable = 'replays';

  @override
  Future<ContentResult<WedArticle?>> getLatestWedArticle() async {
    try {
      final response = await _client
          .from(_articlesTable)
          .select()
          .eq('status', ArticleStatus.published.name)
          .order('published_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return const ContentResult.success(null);
      }

      return ContentResult.success(
        WedArticle.fromJson(response),
      );
    } catch (e) {
      return ContentResult.failure('Failed to get latest article: $e');
    }
  }

  @override
  Future<ContentResult<List<WedArticle>>> getAllWedArticles() async {
    try {
      final response = await _client
          .from(_articlesTable)
          .select()
          .eq('status', ArticleStatus.published.name)
          .order('published_at', ascending: false);

      final articles = (response as List)
          .map((json) => WedArticle.fromJson(json as Map<String, dynamic>))
          .toList();

      return ContentResult.success(articles);
    } catch (e) {
      return ContentResult.failure('Failed to get articles: $e');
    }
  }

  @override
  Future<ContentResult<WedArticle?>> getWedArticleById({
    required String articleId,
  }) async {
    try {
      final response = await _client
          .from(_articlesTable)
          .select()
          .eq('id', articleId)
          .maybeSingle();

      if (response == null) {
        return const ContentResult.success(null);
      }

      return ContentResult.success(
        WedArticle.fromJson(response),
      );
    } catch (e) {
      return ContentResult.failure('Failed to get article: $e');
    }
  }

  @override
  Future<ContentResult<List<Replay>>> getReplays({int? limit}) async {
    try {
      var query = _client
          .from(_replaysTable)
          .select()
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final replays = (response as List)
          .map((json) => Replay.fromJson(json as Map<String, dynamic>))
          .toList();

      return ContentResult.success(replays);
    } catch (e) {
      return ContentResult.failure('Failed to get replays: $e');
    }
  }

  @override
  Future<ContentResult<Replay?>> getReplayById({
    required String replayId,
  }) async {
    try {
      final response = await _client
          .from(_replaysTable)
          .select()
          .eq('id', replayId)
          .maybeSingle();

      if (response == null) {
        return const ContentResult.success(null);
      }

      return ContentResult.success(
        Replay.fromJson(response),
      );
    } catch (e) {
      return ContentResult.failure('Failed to get replay: $e');
    }
  }
}
