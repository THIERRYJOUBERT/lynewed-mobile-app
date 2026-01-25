/// ContentRepository interface.
///
/// Defines the contract for content data operations.
/// Implemented by ContentRepositoryImpl in the data layer.
library;

import '../entities/wed_article.dart';
import '../entities/replay.dart';

/// Result wrapper for repository operations.
class ContentResult<T> {
  /// Creates a successful result with data.
  const ContentResult.success(this.data) : error = null;

  /// Creates a failure result with error message.
  const ContentResult.failure(this.error) : data = null;

  /// The data returned on success.
  final T? data;

  /// The error message on failure.
  final String? error;

  /// Whether the operation was successful.
  bool get isSuccess => error == null;

  /// Whether the operation failed.
  bool get isFailure => error != null;
}

/// Content repository interface.
///
/// Provides methods for retrieving articles and replays.
abstract class ContentRepository {
  /// Gets the latest published wedding article.
  ///
  /// Returns null if no published articles exist.
  Future<ContentResult<WedArticle?>> getLatestWedArticle();

  /// Gets all published wedding articles.
  ///
  /// Returns an empty list if no articles exist.
  Future<ContentResult<List<WedArticle>>> getAllWedArticles();

  /// Gets a wedding article by its ID.
  ///
  /// Returns null if the article doesn't exist.
  Future<ContentResult<WedArticle?>> getWedArticleById({
    required String articleId,
  });

  /// Gets all replays.
  ///
  /// Optionally limits the number of results.
  Future<ContentResult<List<Replay>>> getReplays({int? limit});

  /// Gets a replay by its ID.
  ///
  /// Returns null if the replay doesn't exist.
  Future<ContentResult<Replay?>> getReplayById({
    required String replayId,
  });
}
