/// My Wedding Repository Implementation
///
/// Implements MyWeddingRepository using SupabaseMyWeddingDatasource.
library;

import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../datasources/supabase_my_wedding_datasource.dart';

/// Implementation of MyWeddingRepository
class MyWeddingRepositoryImpl implements MyWeddingRepository {
  MyWeddingRepositoryImpl({
    SupabaseMyWeddingDatasource? datasource,
  }) : _datasource = datasource ?? SupabaseMyWeddingDatasource();

  final SupabaseMyWeddingDatasource _datasource;

  @override
  Future<RepositoryResult<WeddingOverview?>> getMyWedding() async {
    try {
      final wedding = await _datasource.getMyWedding();
      return RepositoryResult.success(wedding);
    } catch (e) {
      return RepositoryResult.failure('Failed to get wedding: $e');
    }
  }

  @override
  Future<RepositoryResult<String>> createWedding({
    required DateTime eventDate,
    required double lat,
    required double lng,
    String? venueName,
    String? venueAddress,
    String? countryCode,
  }) async {
    try {
      final weddingId = await _datasource.createWedding(
        eventDate: eventDate,
        lat: lat,
        lng: lng,
        venueName: venueName,
        venueAddress: venueAddress,
        countryCode: countryCode,
      );
      return RepositoryResult.success(weddingId);
    } catch (e) {
      return RepositoryResult.failure('Failed to create wedding: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> updateOnboardingData({
    required String weddingId,
    required OnboardingData data,
  }) async {
    try {
      await _datasource.updateOnboardingData(
        weddingId: weddingId,
        data: data,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to update onboarding data: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> completeOnboarding({
    required String weddingId,
  }) async {
    try {
      await _datasource.completeOnboarding(weddingId: weddingId);
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to complete onboarding: $e');
    }
  }

  @override
  Future<RepositoryResult<List<ContactedPro>>> getContactedPros() async {
    try {
      final pros = await _datasource.getContactedPros();
      return RepositoryResult.success(pros);
    } catch (e) {
      return RepositoryResult.failure('Failed to get contacted pros: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> inviteProToWedding({
    required String weddingId,
    required String proProfileId,
  }) async {
    try {
      await _datasource.inviteProToWedding(
        weddingId: weddingId,
        proProfileId: proProfileId,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to invite pro: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> excludeProFromWedding({
    required String weddingId,
    required String proProfileId,
    String? reason,
  }) async {
    try {
      await _datasource.excludeProFromWedding(
        weddingId: weddingId,
        proProfileId: proProfileId,
        reason: reason,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to exclude pro: $e');
    }
  }

  @override
  Future<RepositoryResult<List<WeddingTeamMember>>> getWeddingTeam({
    required String weddingId,
  }) async {
    try {
      final team = await _datasource.getWeddingTeam(weddingId: weddingId);
      return RepositoryResult.success(team);
    } catch (e) {
      return RepositoryResult.failure('Failed to get wedding team: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> savePostToAlbum({
    required String albumId,
    required String postId,
  }) async {
    try {
      await _datasource.savePostToAlbum(
        albumId: albumId,
        postId: postId,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to save post: $e');
    }
  }
}
