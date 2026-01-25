/// VideoCallRepositoryImpl - Supabase implementation of VideoCallRepository.
///
/// Handles video session CRUD operations using Supabase.
/// Works with the video_sessions table.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/video_session.dart';
import '../../domain/repositories/video_call_repository.dart';

/// Supabase implementation of VideoCallRepository.
class VideoCallRepositoryImpl implements VideoCallRepository {
  /// Creates the repository with a Supabase client.
  VideoCallRepositoryImpl({
    required SupabaseClient client,
  }) : _client = client;

  final SupabaseClient _client;

  /// Table name for video sessions.
  static const _tableName = 'video_sessions';

  @override
  Future<VideoCallResult<VideoSession?>> getSession({
    required String sessionId,
  }) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', sessionId)
          .maybeSingle();

      if (response == null) {
        return const VideoCallResult.success(null);
      }

      return VideoCallResult.success(
        VideoSession.fromJson(response),
      );
    } catch (e) {
      return VideoCallResult.failure('Failed to get session: $e');
    }
  }

  @override
  Future<VideoCallResult<VideoSession>> createSession({
    required String callerProfileId,
    required String receiverProfileId,
  }) async {
    try {
      // In a real implementation, this would call an Edge Function
      // that generates Agora credentials and creates the session.
      // For now, return a failure as we can't create sessions client-side.
      return const VideoCallResult.failure(
        'Session creation requires server-side Agora token generation',
      );
    } catch (e) {
      return VideoCallResult.failure('Failed to create session: $e');
    }
  }

  @override
  Future<VideoCallResult<void>> updateSessionStatus({
    required String sessionId,
    required VideoSessionStatus status,
  }) async {
    try {
      await _client
          .from(_tableName)
          .update({'status': status.name})
          .eq('id', sessionId);

      return const VideoCallResult.success(null);
    } catch (e) {
      return VideoCallResult.failure('Failed to update session status: $e');
    }
  }

  @override
  Future<VideoCallResult<void>> endSession({
    required String sessionId,
  }) async {
    try {
      await _client.from(_tableName).update({
        'status': VideoSessionStatus.ended.name,
        'ended_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);

      return const VideoCallResult.success(null);
    } catch (e) {
      return VideoCallResult.failure('Failed to end session: $e');
    }
  }

  @override
  Future<VideoCallResult<VideoSession?>> getActiveSessionForUser({
    required String profileId,
  }) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .or('caller_profile_id.eq.$profileId,receiver_profile_id.eq.$profileId')
          .inFilter('status', ['pending', 'ringing', 'connected'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return const VideoCallResult.success(null);
      }

      return VideoCallResult.success(
        VideoSession.fromJson(response),
      );
    } catch (e) {
      return VideoCallResult.failure('Failed to get active session: $e');
    }
  }
}
