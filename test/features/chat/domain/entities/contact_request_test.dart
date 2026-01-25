import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/contact_request.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_enums.dart';

void main() {
  group('ContactRequest', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create ContactRequest with required fields', () {
        final now = DateTime.now();
        final request = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: now,
        );

        expect(request.id, 'req-123');
        expect(request.proProfileId, 'pro-456');
        expect(request.brideProfileId, 'bride-789');
        expect(request.initiatorId, 'pro-456');
        expect(request.source, ContactRequestSource.fromProfile);
        expect(request.status, ConnectionRequestStatus.pending);
        expect(request.createdAt, now);
      });

      test('should create ContactRequest with all optional fields', () {
        final now = DateTime.now();
        final respondedAt = now.add(const Duration(hours: 1));
        final request = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromWishlist,
          status: ConnectionRequestStatus.accepted,
          createdAt: now,
          initialMessage: 'Hello, I would like to connect!',
          respondedAt: respondedAt,
          otherFullName: 'Jane Bride',
          otherAvatarUrl: 'https://example.com/avatar.jpg',
          otherRole: UserRole.bride,
        );

        expect(request.initialMessage, 'Hello, I would like to connect!');
        expect(request.respondedAt, respondedAt);
        expect(request.otherFullName, 'Jane Bride');
        expect(request.otherAvatarUrl, 'https://example.com/avatar.jpg');
        expect(request.otherRole, UserRole.bride);
      });
    });

    // ==============================================================
    // FROMMAP TESTS
    // ==============================================================

    group('fromMap', () {
      test('should parse snake_case data correctly', () {
        final map = {
          'id': 'req-123',
          'pro_profile_id': 'pro-456',
          'bride_profile_id': 'bride-789',
          'initiator_id': 'pro-456',
          'source': 'fromProfile',
          'initial_message': 'Hello!',
          'status': 'pending',
          'created_at': '2025-01-24T10:00:00Z',
          'responded_at': null,
          'other_full_name': 'John Pro',
          'other_avatar_url': 'https://example.com/pro.jpg',
          'other_role': 'professional',
        };

        final request = ContactRequest.fromMap(map);

        expect(request.id, 'req-123');
        expect(request.proProfileId, 'pro-456');
        expect(request.brideProfileId, 'bride-789');
        expect(request.initiatorId, 'pro-456');
        expect(request.source, ContactRequestSource.fromProfile);
        expect(request.initialMessage, 'Hello!');
        expect(request.status, ConnectionRequestStatus.pending);
        expect(request.createdAt.year, 2025);
        expect(request.respondedAt, isNull);
        expect(request.otherFullName, 'John Pro');
        expect(request.otherAvatarUrl, 'https://example.com/pro.jpg');
        expect(request.otherRole, UserRole.professional);
      });

      test('should parse camelCase RPC response correctly', () {
        final map = {
          'requestId': 'req-456',
          'proProfileId': 'pro-abc',
          'brideProfileId': 'bride-xyz',
          'initiatorId': 'pro-abc',
          'source': 'fromWedding',
          'initialMessage': 'Interested in your wedding!',
          'status': 'accepted',
          'createdAt': '2025-01-24T15:00:00Z',
          'respondedAt': '2025-01-24T16:00:00Z',
          'otherFullName': 'Bride User',
          'otherAvatarUrl': 'https://example.com/bride.jpg',
          'otherRole': 'bride',
        };

        final request = ContactRequest.fromMap(map);

        expect(request.id, 'req-456');
        expect(request.proProfileId, 'pro-abc');
        expect(request.brideProfileId, 'bride-xyz');
        expect(request.source, ContactRequestSource.fromWedding);
        expect(request.status, ConnectionRequestStatus.accepted);
        expect(request.respondedAt, isNotNull);
        expect(request.otherRole, UserRole.bride);
      });

      test('should handle null optional fields', () {
        final map = {
          'id': 'req-min',
          'pro_profile_id': 'pro-123',
          'bride_profile_id': 'bride-123',
          'initiator_id': 'pro-123',
          'source': 'fromAlert',
          'status': 'declined',
          'created_at': '2025-01-24T10:00:00Z',
        };

        final request = ContactRequest.fromMap(map);

        expect(request.initialMessage, isNull);
        expect(request.respondedAt, isNull);
        expect(request.otherFullName, isNull);
        expect(request.otherAvatarUrl, isNull);
        expect(request.otherRole, isNull);
      });

      test('should default to fromProfile for null source', () {
        final map = {
          'id': 'req-null-source',
          'pro_profile_id': 'pro-123',
          'bride_profile_id': 'bride-123',
          'initiator_id': 'pro-123',
          'source': null,
          'status': 'pending',
          'created_at': '2025-01-24T10:00:00Z',
        };

        final request = ContactRequest.fromMap(map);

        expect(request.source, ContactRequestSource.fromProfile);
      });

      test('should default to pending for null status', () {
        final map = {
          'id': 'req-null-status',
          'pro_profile_id': 'pro-123',
          'bride_profile_id': 'bride-123',
          'initiator_id': 'pro-123',
          'source': 'fromProfile',
          'status': null,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final request = ContactRequest.fromMap(map);

        expect(request.status, ConnectionRequestStatus.pending);
      });

      test('should handle DateTime object for createdAt', () {
        final dateTime = DateTime(2025, 1, 24, 12, 0, 0);
        final map = {
          'id': 'req-dt',
          'pro_profile_id': 'pro-123',
          'bride_profile_id': 'bride-123',
          'initiator_id': 'pro-123',
          'source': 'fromProfile',
          'status': 'pending',
          'created_at': dateTime,
        };

        final request = ContactRequest.fromMap(map);

        expect(request.createdAt, dateTime);
      });
    });

    // ==============================================================
    // DERIVED GETTERS TESTS
    // ==============================================================

    group('isPending', () {
      test('should return true for pending status', () {
        final request = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: DateTime.now(),
        );

        expect(request.isPending, true);
      });

      test('should return false for accepted status', () {
        final request = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.accepted,
          createdAt: DateTime.now(),
        );

        expect(request.isPending, false);
      });

      test('should return false for declined status', () {
        final request = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.declined,
          createdAt: DateTime.now(),
        );

        expect(request.isPending, false);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final now = DateTime.now();
        final original = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: now,
        );

        final copied = original.copyWith(status: ConnectionRequestStatus.accepted);

        expect(copied.id, 'req-123');
        expect(copied.proProfileId, 'pro-456');
        expect(copied.brideProfileId, 'bride-789');
        expect(copied.source, ContactRequestSource.fromProfile);
        expect(copied.status, ConnectionRequestStatus.accepted);
        expect(copied.createdAt, now);
      });

      test('should update multiple fields at once', () {
        final now = DateTime.now();
        final respondedAt = now.add(const Duration(hours: 1));
        final original = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: now,
        );

        final copied = original.copyWith(
          status: ConnectionRequestStatus.accepted,
          respondedAt: respondedAt,
        );

        expect(copied.status, ConnectionRequestStatus.accepted);
        expect(copied.respondedAt, respondedAt);
      });

      test('should not modify original', () {
        final original = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: DateTime.now(),
        );

        original.copyWith(status: ConnectionRequestStatus.accepted);

        expect(original.status, ConnectionRequestStatus.pending);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields are same', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final request1 = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: now,
        );
        final request2 = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: now,
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final request1 = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: now,
        );
        final request2 = ContactRequest(
          id: 'req-999',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: now,
        );

        expect(request1, isNot(equals(request2)));
      });

      test('should return identical for same instance', () {
        final request = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: DateTime.now(),
        );

        expect(request == request, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final request = ContactRequest(
          id: 'req-123',
          proProfileId: 'pro-456',
          brideProfileId: 'bride-789',
          initiatorId: 'pro-456',
          source: ContactRequestSource.fromWishlist,
          status: ConnectionRequestStatus.pending,
          createdAt: DateTime.now(),
        );

        final result = request.toString();

        expect(result, contains('req-123'));
        expect(result, contains('fromWishlist'));
        expect(result, contains('pending'));
      });
    });
  });
}
