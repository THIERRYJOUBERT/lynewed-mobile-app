/// Tests for VideoSession entity.
///
/// Comprehensive tests covering:
/// - Entity creation with required and optional fields
/// - JSON serialization/deserialization
/// - copyWith functionality
/// - Equality and hashCode
/// - Computed properties
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/video_call/domain/entities/video_session.dart';

void main() {
  group('VideoSessionStatus', () {
    test('should have all expected values', () {
      expect(VideoSessionStatus.values, contains(VideoSessionStatus.pending));
      expect(VideoSessionStatus.values, contains(VideoSessionStatus.ringing));
      expect(VideoSessionStatus.values, contains(VideoSessionStatus.connected));
      expect(VideoSessionStatus.values, contains(VideoSessionStatus.ended));
      expect(VideoSessionStatus.values, contains(VideoSessionStatus.missed));
      expect(VideoSessionStatus.values, contains(VideoSessionStatus.declined));
    });

    test('should have 6 values', () {
      expect(VideoSessionStatus.values.length, 6);
    });
  });

  group('VideoSession', () {
    final testDate = DateTime(2025, 6, 15, 10, 30);
    final testEndDate = DateTime(2025, 6, 15, 11, 0);

    group('creation', () {
      test('should create with all required fields', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
        );

        expect(session.id, 'session-1');
        expect(session.channelName, 'channel-abc');
        expect(session.token, 'token-xyz');
        expect(session.uid, 12345);
        expect(session.callerProfileId, 'caller-1');
        expect(session.receiverProfileId, 'receiver-1');
        expect(session.status, VideoSessionStatus.pending);
        expect(session.createdAt, testDate);
        expect(session.endedAt, isNull);
      });

      test('should create with optional endedAt', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.ended,
          createdAt: testDate,
          endedAt: testEndDate,
        );

        expect(session.endedAt, testEndDate);
      });

      test('should create with optional caller and receiver names', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
          callerName: 'John Doe',
          receiverName: 'Jane Doe',
          callerAvatarUrl: 'https://example.com/john.jpg',
          receiverAvatarUrl: 'https://example.com/jane.jpg',
        );

        expect(session.callerName, 'John Doe');
        expect(session.receiverName, 'Jane Doe');
        expect(session.callerAvatarUrl, 'https://example.com/john.jpg');
        expect(session.receiverAvatarUrl, 'https://example.com/jane.jpg');
      });
    });

    group('computed properties', () {
      test('isPending should return true when status is pending', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
        );

        expect(session.isPending, true);
        expect(session.isRinging, false);
        expect(session.isConnected, false);
        expect(session.isEnded, false);
      });

      test('isRinging should return true when status is ringing', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.ringing,
          createdAt: testDate,
        );

        expect(session.isRinging, true);
      });

      test('isConnected should return true when status is connected', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.connected,
          createdAt: testDate,
        );

        expect(session.isConnected, true);
      });

      test('isEnded should return true when status is ended, missed, or declined', () {
        final endedSession = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.ended,
          createdAt: testDate,
        );

        final missedSession = endedSession.copyWith(status: VideoSessionStatus.missed);
        final declinedSession = endedSession.copyWith(status: VideoSessionStatus.declined);

        expect(endedSession.isEnded, true);
        expect(missedSession.isEnded, true);
        expect(declinedSession.isEnded, true);
      });

      test('duration should return null when session not ended', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.connected,
          createdAt: testDate,
        );

        expect(session.duration, isNull);
      });

      test('duration should return correct duration when session ended', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.ended,
          createdAt: testDate,
          endedAt: testEndDate,
        );

        expect(session.duration, const Duration(minutes: 30));
      });
    });

    group('fromJson', () {
      test('should parse valid JSON with all fields', () {
        final json = {
          'id': 'session-1',
          'channel_name': 'channel-abc',
          'token': 'token-xyz',
          'uid': 12345,
          'caller_profile_id': 'caller-1',
          'receiver_profile_id': 'receiver-1',
          'status': 'connected',
          'created_at': '2025-06-15T10:30:00.000',
          'ended_at': '2025-06-15T11:00:00.000',
          'caller_name': 'John Doe',
          'receiver_name': 'Jane Doe',
          'caller_avatar_url': 'https://example.com/john.jpg',
          'receiver_avatar_url': 'https://example.com/jane.jpg',
        };

        final session = VideoSession.fromJson(json);

        expect(session.id, 'session-1');
        expect(session.channelName, 'channel-abc');
        expect(session.token, 'token-xyz');
        expect(session.uid, 12345);
        expect(session.callerProfileId, 'caller-1');
        expect(session.receiverProfileId, 'receiver-1');
        expect(session.status, VideoSessionStatus.connected);
        expect(session.createdAt, DateTime(2025, 6, 15, 10, 30));
        expect(session.endedAt, DateTime(2025, 6, 15, 11, 0));
        expect(session.callerName, 'John Doe');
        expect(session.receiverName, 'Jane Doe');
      });

      test('should parse JSON without optional fields', () {
        final json = {
          'id': 'session-1',
          'channel_name': 'channel-abc',
          'token': 'token-xyz',
          'uid': 12345,
          'caller_profile_id': 'caller-1',
          'receiver_profile_id': 'receiver-1',
          'status': 'pending',
          'created_at': '2025-06-15T10:30:00.000',
        };

        final session = VideoSession.fromJson(json);

        expect(session.endedAt, isNull);
        expect(session.callerName, isNull);
        expect(session.receiverName, isNull);
      });

      test('should parse all status values correctly', () {
        final statuses = ['pending', 'ringing', 'connected', 'ended', 'missed', 'declined'];
        final expected = [
          VideoSessionStatus.pending,
          VideoSessionStatus.ringing,
          VideoSessionStatus.connected,
          VideoSessionStatus.ended,
          VideoSessionStatus.missed,
          VideoSessionStatus.declined,
        ];

        for (var i = 0; i < statuses.length; i++) {
          final json = {
            'id': 'session-1',
            'channel_name': 'channel-abc',
            'token': 'token-xyz',
            'uid': 12345,
            'caller_profile_id': 'caller-1',
            'receiver_profile_id': 'receiver-1',
            'status': statuses[i],
            'created_at': '2025-06-15T10:30:00.000',
          };

          final session = VideoSession.fromJson(json);
          expect(session.status, expected[i]);
        }
      });

      test('should default to pending for unknown status', () {
        final json = {
          'id': 'session-1',
          'channel_name': 'channel-abc',
          'token': 'token-xyz',
          'uid': 12345,
          'caller_profile_id': 'caller-1',
          'receiver_profile_id': 'receiver-1',
          'status': 'unknown_status',
          'created_at': '2025-06-15T10:30:00.000',
        };

        final session = VideoSession.fromJson(json);
        expect(session.status, VideoSessionStatus.pending);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.connected,
          createdAt: testDate,
          endedAt: testEndDate,
        );

        final json = session.toJson();

        expect(json['channel_name'], 'channel-abc');
        expect(json['token'], 'token-xyz');
        expect(json['uid'], 12345);
        expect(json['caller_profile_id'], 'caller-1');
        expect(json['receiver_profile_id'], 'receiver-1');
        expect(json['status'], 'connected');
      });

      test('should not include null optional fields', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
        );

        final json = session.toJson();

        expect(json.containsKey('ended_at'), false);
      });
    });

    group('copyWith', () {
      test('should copy with new id', () {
        final original = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
        );

        final copied = original.copyWith(id: 'session-2');

        expect(copied.id, 'session-2');
        expect(copied.channelName, original.channelName);
      });

      test('should copy with new status', () {
        final original = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
        );

        final copied = original.copyWith(status: VideoSessionStatus.connected);

        expect(copied.status, VideoSessionStatus.connected);
      });

      test('should copy with new endedAt', () {
        final original = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
        );

        final copied = original.copyWith(endedAt: testEndDate);

        expect(copied.endedAt, testEndDate);
      });

      test('should preserve unchanged values', () {
        final original = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
          callerName: 'John',
        );

        final copied = original.copyWith(status: VideoSessionStatus.ended);

        expect(copied.id, original.id);
        expect(copied.channelName, original.channelName);
        expect(copied.token, original.token);
        expect(copied.uid, original.uid);
        expect(copied.callerProfileId, original.callerProfileId);
        expect(copied.receiverProfileId, original.receiverProfileId);
        expect(copied.createdAt, original.createdAt);
        expect(copied.callerName, original.callerName);
      });
    });

    group('equality', () {
      test('should be equal with same id', () {
        final session1 = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
        );

        final session2 = VideoSession(
          id: 'session-1',
          channelName: 'channel-different',
          token: 'token-different',
          uid: 99999,
          callerProfileId: 'caller-different',
          receiverProfileId: 'receiver-different',
          status: VideoSessionStatus.ended,
          createdAt: DateTime(2025, 1, 1),
        );

        expect(session1, equals(session2));
        expect(session1.hashCode, equals(session2.hashCode));
      });

      test('should not be equal with different id', () {
        final session1 = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
        );

        final session2 = VideoSession(
          id: 'session-2',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.pending,
          createdAt: testDate,
        );

        expect(session1, isNot(equals(session2)));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.connected,
          createdAt: testDate,
        );

        final str = session.toString();

        expect(str, contains('session-1'));
        expect(str, contains('channel-abc'));
        expect(str, contains('connected'));
      });
    });
  });
}
