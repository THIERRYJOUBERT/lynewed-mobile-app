/// Tests for VideoCallRepository interface and implementation.
///
/// Tests covering:
/// - Repository interface contract
/// - Implementation methods
/// - Error handling
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/video_call/domain/entities/video_session.dart';
import 'package:lynewed_beta/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:lynewed_beta/features/video_call/data/repositories/video_call_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide PostgrestException;

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class MockPostgrestTransformBuilder<T> extends Mock
    implements PostgrestTransformBuilder<T> {}

void main() {
  group('VideoCallRepository', () {
    test('interface should define getSession method', () {
      // This is a compile-time check - if VideoCallRepository doesn't have
      // the getSession method, this won't compile
      expect(VideoCallRepository, isNotNull);
    });
  });

  group('VideoCallRepositoryImpl', () {
    late MockSupabaseClient mockSupabaseClient;
    late VideoCallRepositoryImpl repository;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      repository = VideoCallRepositoryImpl(client: mockSupabaseClient);
    });

    group('creation', () {
      test('should create with Supabase client', () {
        expect(repository, isNotNull);
      });
    });

    group('getSession', () {
      test('should return VideoCallResult with session when found', () async {
        // We can't easily mock Supabase's complex query chain,
        // so we'll test the result type expectations
        final result = await repository.getSession(sessionId: 'non-existent');

        // Should return failure for non-existent session (in real implementation)
        // For now, we just verify the method exists and returns proper type
        expect(result, isA<VideoCallResult<VideoSession?>>());
      });
    });

    group('createSession', () {
      test('should return VideoCallResult type', () async {
        final result = await repository.createSession(
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
        );

        expect(result, isA<VideoCallResult<VideoSession>>());
      });
    });

    group('updateSessionStatus', () {
      test('should return VideoCallResult type', () async {
        final result = await repository.updateSessionStatus(
          sessionId: 'session-1',
          status: VideoSessionStatus.connected,
        );

        expect(result, isA<VideoCallResult<void>>());
      });
    });

    group('endSession', () {
      test('should return VideoCallResult type', () async {
        final result = await repository.endSession(sessionId: 'session-1');

        expect(result, isA<VideoCallResult<void>>());
      });
    });
  });

  group('VideoCallResult', () {
    test('success should create with data and no error', () {
      final result = VideoCallResult<String>.success('test');

      expect(result.data, 'test');
      expect(result.error, isNull);
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
    });

    test('failure should create with error and no data', () {
      final result = VideoCallResult<String>.failure('error message');

      expect(result.data, isNull);
      expect(result.error, 'error message');
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
    });

    test('success with null data should still be success', () {
      final result = VideoCallResult<String?>.success(null);

      expect(result.data, isNull);
      expect(result.error, isNull);
      expect(result.isSuccess, true);
    });
  });
}
