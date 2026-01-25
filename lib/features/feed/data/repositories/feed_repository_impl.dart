/// Feed Repository Implementation
///
/// Implements FeedRepository using a datasource.
library;

import '../../domain/entities/feed_filter.dart';
import '../../domain/entities/feed_professional.dart';
import '../../domain/repositories/feed_repository.dart';

/// Implementation of FeedRepository
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({
    FeedDatasource? datasource,
  }) : _datasource = datasource ?? _DefaultFeedDatasource();

  final FeedDatasource _datasource;

  @override
  Future<FeedRepositoryResult<List<FeedProfessional>>> getFeedProfessionals({
    required FeedFilter filter,
    int? limit,
    int? offset,
  }) async {
    try {
      final data = await _datasource.getFeedProfessionals(
        filter: filter,
        limit: limit,
        offset: offset,
      );
      final professionals =
          data.map((json) => FeedProfessional.fromJson(json)).toList();
      return FeedRepositoryResult.success(professionals);
    } catch (e) {
      return FeedRepositoryResult.failure('Failed to get feed: $e');
    }
  }

  @override
  Future<FeedRepositoryResult<FeedProfessional?>> getProfessionalById(
    String profileId,
  ) async {
    try {
      final data = await _datasource.getProfessionalById(profileId);
      if (data == null) {
        return const FeedRepositoryResult.success(null);
      }
      final professional = FeedProfessional.fromJson(data);
      return FeedRepositoryResult.success(professional);
    } catch (e) {
      return FeedRepositoryResult.failure('Failed to get professional: $e');
    }
  }

  @override
  Future<FeedRepositoryResult<bool>> toggleFavorite(String profileId) async {
    try {
      final isFavorited = await _datasource.toggleFavorite(profileId);
      return FeedRepositoryResult.success(isFavorited);
    } catch (e) {
      return FeedRepositoryResult.failure('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<FeedRepositoryResult<List<String>>> getAvailableProfessions() async {
    try {
      final professions = await _datasource.getAvailableProfessions();
      return FeedRepositoryResult.success(professions);
    } catch (e) {
      return FeedRepositoryResult.failure('Failed to get professions: $e');
    }
  }
}

/// Default datasource that returns empty data
/// This will be replaced by actual Supabase datasource
class _DefaultFeedDatasource implements FeedDatasource {
  @override
  Future<List<Map<String, dynamic>>> getFeedProfessionals({
    required FeedFilter filter,
    int? limit,
    int? offset,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>?> getProfessionalById(String profileId) async {
    return null;
  }

  @override
  Future<bool> toggleFavorite(String profileId) async {
    return false;
  }

  @override
  Future<List<String>> getAvailableProfessions() async {
    return [];
  }
}
