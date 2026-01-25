/// Feed Repository Interface
///
/// Defines the contract for feed data operations.
/// Implemented by FeedRepositoryImpl in the data layer.
library;

import '../entities/feed_filter.dart';
import '../entities/feed_professional.dart';

/// Result wrapper for repository operations
class FeedRepositoryResult<T> {
  const FeedRepositoryResult.success(this.data) : error = null;
  const FeedRepositoryResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Feed Datasource interface for data access
abstract class FeedDatasource {
  /// Get feed professionals with optional filter, limit, and offset
  Future<List<Map<String, dynamic>>> getFeedProfessionals({
    required FeedFilter filter,
    int? limit,
    int? offset,
  });

  /// Get a single professional by ID
  Future<Map<String, dynamic>?> getProfessionalById(String profileId);

  /// Toggle favorite status for a professional
  Future<bool> toggleFavorite(String profileId);

  /// Get list of available professions for filtering
  Future<List<String>> getAvailableProfessions();
}

/// Feed Repository Interface
abstract class FeedRepository {
  /// Get list of professionals for the feed
  ///
  /// Uses [filter] to apply profession, location, and sort filters.
  /// Supports pagination with [limit] and [offset].
  Future<FeedRepositoryResult<List<FeedProfessional>>> getFeedProfessionals({
    required FeedFilter filter,
    int? limit,
    int? offset,
  });

  /// Get a single professional by their profile ID
  ///
  /// Returns null if the professional is not found.
  Future<FeedRepositoryResult<FeedProfessional?>> getProfessionalById(
    String profileId,
  );

  /// Toggle favorite status for a professional
  ///
  /// Returns true if now favorited, false if unfavorited.
  Future<FeedRepositoryResult<bool>> toggleFavorite(String profileId);

  /// Get list of available professions for filtering
  Future<FeedRepositoryResult<List<String>>> getAvailableProfessions();
}
