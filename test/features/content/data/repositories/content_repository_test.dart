/// Tests for ContentRepository.
///
/// Comprehensive tests covering:
/// - Article retrieval methods
/// - Replay retrieval methods
/// - Error handling
/// - Result wrapper behavior
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/content/domain/entities/wed_article.dart';
import 'package:lynewed_beta/features/content/domain/entities/wed_content_block.dart';
import 'package:lynewed_beta/features/content/domain/entities/replay.dart';
import 'package:lynewed_beta/features/content/domain/repositories/content_repository.dart';

void main() {
  group('ContentResult', () {
    group('success', () {
      test('should create successful result with data', () {
        const result = ContentResult<String>.success('test data');

        expect(result.data, 'test data');
        expect(result.error, isNull);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('should create successful result with null data', () {
        const result = ContentResult<String?>.success(null);

        expect(result.data, isNull);
        expect(result.error, isNull);
        expect(result.isSuccess, isTrue);
      });

      test('should create successful result with complex data', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Test',
          publishedAt: DateTime(2025, 1, 1),
          status: ArticleStatus.published,
          contentBlocks: const [],
        );
        final result = ContentResult<WedArticle>.success(article);

        expect(result.data, article);
        expect(result.isSuccess, isTrue);
      });

      test('should create successful result with list data', () {
        final articles = [
          WedArticle(
            id: 'article-1',
            title: 'Test 1',
            publishedAt: DateTime(2025, 1, 1),
            status: ArticleStatus.published,
            contentBlocks: const [],
          ),
          WedArticle(
            id: 'article-2',
            title: 'Test 2',
            publishedAt: DateTime(2025, 1, 2),
            status: ArticleStatus.published,
            contentBlocks: const [],
          ),
        ];
        final result = ContentResult<List<WedArticle>>.success(articles);

        expect(result.data, articles);
        expect(result.data?.length, 2);
        expect(result.isSuccess, isTrue);
      });
    });

    group('failure', () {
      test('should create failure result with error message', () {
        const result = ContentResult<String>.failure('Something went wrong');

        expect(result.data, isNull);
        expect(result.error, 'Something went wrong');
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
      });

      test('should create failure result with detailed error', () {
        const result = ContentResult<WedArticle>.failure(
          'Failed to fetch article: network error',
        );

        expect(result.data, isNull);
        expect(result.error, contains('Failed to fetch'));
        expect(result.error, contains('network error'));
        expect(result.isFailure, isTrue);
      });
    });
  });

  group('ContentRepository interface', () {
    late _MockContentRepository repository;

    setUp(() {
      repository = _MockContentRepository();
    });

    group('getLatestWedArticle', () {
      test('should return latest article when available', () async {
        final result = await repository.getLatestWedArticle();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data?.title, 'Latest Wedding');
      });

      test('should return null when no articles exist', () async {
        repository.setNoArticles(true);
        final result = await repository.getLatestWedArticle();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });

      test('should return failure on error', () async {
        repository.setError('Network error');
        final result = await repository.getLatestWedArticle();

        expect(result.isFailure, isTrue);
        expect(result.error, 'Network error');
      });
    });

    group('getAllWedArticles', () {
      test('should return list of articles', () async {
        final result = await repository.getAllWedArticles();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, 2);
      });

      test('should return empty list when no articles', () async {
        repository.setNoArticles(true);
        final result = await repository.getAllWedArticles();

        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
      });

      test('should return failure on error', () async {
        repository.setError('Database error');
        final result = await repository.getAllWedArticles();

        expect(result.isFailure, isTrue);
        expect(result.error, 'Database error');
      });
    });

    group('getWedArticleById', () {
      test('should return article when found', () async {
        final result = await repository.getWedArticleById(articleId: 'article-1');

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data?.id, 'article-1');
      });

      test('should return null when not found', () async {
        final result = await repository.getWedArticleById(articleId: 'nonexistent');

        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });

      test('should return failure on error', () async {
        repository.setError('Query error');
        final result = await repository.getWedArticleById(articleId: 'article-1');

        expect(result.isFailure, isTrue);
        expect(result.error, 'Query error');
      });
    });

    group('getReplays', () {
      test('should return list of replays', () async {
        final result = await repository.getReplays();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, 2);
      });

      test('should return empty list when no replays', () async {
        repository.setNoReplays(true);
        final result = await repository.getReplays();

        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
      });

      test('should return failure on error', () async {
        repository.setError('Fetch error');
        final result = await repository.getReplays();

        expect(result.isFailure, isTrue);
        expect(result.error, 'Fetch error');
      });

      test('should return replays with limit when specified', () async {
        final result = await repository.getReplays(limit: 1);

        expect(result.isSuccess, isTrue);
        expect(result.data!.length, 1);
      });
    });

    group('getReplayById', () {
      test('should return replay when found', () async {
        final result = await repository.getReplayById(replayId: 'replay-1');

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data?.id, 'replay-1');
      });

      test('should return null when not found', () async {
        final result = await repository.getReplayById(replayId: 'nonexistent');

        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });

      test('should return failure on error', () async {
        repository.setError('Replay error');
        final result = await repository.getReplayById(replayId: 'replay-1');

        expect(result.isFailure, isTrue);
        expect(result.error, 'Replay error');
      });
    });
  });
}

/// Mock implementation of ContentRepository for testing.
class _MockContentRepository implements ContentRepository {
  String? _error;
  bool _noArticles = false;
  bool _noReplays = false;

  void setError(String error) {
    _error = error;
  }

  void setNoArticles(bool value) {
    _noArticles = value;
  }

  void setNoReplays(bool value) {
    _noReplays = value;
  }

  final _testArticles = [
    WedArticle(
      id: 'article-1',
      title: 'Latest Wedding',
      publishedAt: DateTime(2025, 6, 15),
      status: ArticleStatus.published,
      contentBlocks: const [
        WedContentBlock(type: ContentBlockType.text, content: 'Content'),
      ],
    ),
    WedArticle(
      id: 'article-2',
      title: 'Second Wedding',
      publishedAt: DateTime(2025, 6, 10),
      status: ArticleStatus.published,
      contentBlocks: const [],
    ),
  ];

  final _testReplays = [
    Replay(
      id: 'replay-1',
      title: 'Wedding Replay 1',
      videoUrl: 'https://vimeo.com/123',
      videoType: VideoType.vimeo,
      createdAt: DateTime(2025, 6, 15),
    ),
    Replay(
      id: 'replay-2',
      title: 'Wedding Replay 2',
      videoUrl: 'https://youtube.com/abc',
      videoType: VideoType.youtube,
      createdAt: DateTime(2025, 6, 10),
    ),
  ];

  @override
  Future<ContentResult<WedArticle?>> getLatestWedArticle() async {
    if (_error != null) {
      return ContentResult.failure(_error!);
    }
    if (_noArticles) {
      return const ContentResult.success(null);
    }
    return ContentResult.success(_testArticles.first);
  }

  @override
  Future<ContentResult<List<WedArticle>>> getAllWedArticles() async {
    if (_error != null) {
      return ContentResult.failure(_error!);
    }
    if (_noArticles) {
      return const ContentResult.success([]);
    }
    return ContentResult.success(_testArticles);
  }

  @override
  Future<ContentResult<WedArticle?>> getWedArticleById({
    required String articleId,
  }) async {
    if (_error != null) {
      return ContentResult.failure(_error!);
    }
    final article = _testArticles.where((a) => a.id == articleId).firstOrNull;
    return ContentResult.success(article);
  }

  @override
  Future<ContentResult<List<Replay>>> getReplays({int? limit}) async {
    if (_error != null) {
      return ContentResult.failure(_error!);
    }
    if (_noReplays) {
      return const ContentResult.success([]);
    }
    if (limit != null) {
      return ContentResult.success(_testReplays.take(limit).toList());
    }
    return ContentResult.success(_testReplays);
  }

  @override
  Future<ContentResult<Replay?>> getReplayById({
    required String replayId,
  }) async {
    if (_error != null) {
      return ContentResult.failure(_error!);
    }
    final replay = _testReplays.where((r) => r.id == replayId).firstOrNull;
    return ContentResult.success(replay);
  }
}
