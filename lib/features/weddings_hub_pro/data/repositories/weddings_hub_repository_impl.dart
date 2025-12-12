/// Weddings Hub Repository Implementation
///
/// Implements WeddingsHubRepository using SupabaseWeddingsHubDatasource.
library;

import '../../domain/entities/wedding_client.dart';
import '../../domain/repositories/weddings_hub_repository.dart';
import '../datasources/supabase_weddings_hub_datasource.dart';

/// Implementation of WeddingsHubRepository
class WeddingsHubRepositoryImpl implements WeddingsHubRepository {
  WeddingsHubRepositoryImpl({
    SupabaseWeddingsHubDatasource? datasource,
  }) : _datasource = datasource ?? SupabaseWeddingsHubDatasource();

  final SupabaseWeddingsHubDatasource _datasource;

  @override
  Future<WeddingsHubResult<List<WeddingClient>>> getMyWeddingsAsPro() async {
    try {
      final weddings = await _datasource.getMyWeddingsAsPro();
      return WeddingsHubResult.success(weddings);
    } catch (e) {
      return WeddingsHubResult.failure('Failed to get weddings: $e');
    }
  }

  @override
  Future<WeddingsHubResult<WeddingClient?>> getWeddingClient({
    required String weddingId,
  }) async {
    try {
      final wedding = await _datasource.getWeddingClient(weddingId: weddingId);
      return WeddingsHubResult.success(wedding);
    } catch (e) {
      return WeddingsHubResult.failure('Failed to get wedding: $e');
    }
  }

  @override
  Future<WeddingsHubResult<void>> leaveWedding({
    required String weddingId,
    required String reason,
  }) async {
    try {
      await _datasource.leaveWedding(weddingId: weddingId, reason: reason);
      return const WeddingsHubResult.success(null);
    } catch (e) {
      return WeddingsHubResult.failure('Failed to leave wedding: $e');
    }
  }

  @override
  Future<WeddingsHubResult<void>> toggleMuteWedding({
    required String weddingId,
    required bool isMuted,
  }) async {
    try {
      await _datasource.toggleMuteWedding(weddingId: weddingId, isMuted: isMuted);
      return const WeddingsHubResult.success(null);
    } catch (e) {
      return WeddingsHubResult.failure('Failed to toggle mute: $e');
    }
  }

  @override
  Future<WeddingsHubResult<String?>> getWeddingTeamChatId({
    required String weddingId,
  }) async {
    try {
      final chatId = await _datasource.getWeddingTeamChatId(weddingId: weddingId);
      return WeddingsHubResult.success(chatId);
    } catch (e) {
      return WeddingsHubResult.failure('Failed to get chat ID: $e');
    }
  }

  @override
  Future<WeddingsHubResult<TeamChatInfo?>> getWeddingTeamChatInfo({
    required String weddingId,
  }) async {
    try {
      final data = await _datasource.getWeddingTeamChatInfo(weddingId: weddingId);
      if (data == null) {
        return const WeddingsHubResult.success(null);
      }
      return WeddingsHubResult.success(TeamChatInfo.fromJson(data));
    } catch (e) {
      return WeddingsHubResult.failure('Failed to get chat info: $e');
    }
  }

  @override
  Future<WeddingsHubResult<void>> ensureProInWeddingTeamChat({
    required String weddingId,
  }) async {
    try {
      await _datasource.ensureProInWeddingTeamChat(weddingId: weddingId);
      return const WeddingsHubResult.success(null);
    } catch (e) {
      return WeddingsHubResult.failure('Failed to add pro to chat: $e');
    }
  }
}
