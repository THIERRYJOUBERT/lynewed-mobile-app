import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lynewed_beta/features/chat/data/repositories/contact_repository_impl.dart';
import 'package:lynewed_beta/features/chat/domain/entities/entities.dart';

// ==============================================================
// MOCKS
// ==============================================================

class MockChatRemoteDatasource extends Mock implements ChatRemoteDatasource {}

void main() {
  late MockChatRemoteDatasource mockDatasource;
  late ContactRepositoryImpl repository;

  setUpAll(() {
    // Register fallback values for any() matchers
    registerFallbackValue(ContactRequestSource.fromProfile);
    registerFallbackValue(ReportReason.other);
  });

  setUp(() {
    mockDatasource = MockChatRemoteDatasource();
    repository = ContactRepositoryImpl(datasource: mockDatasource);
  });

  // ==============================================================
  // PREPARECONTACTCONTEXT TESTS
  // ==============================================================

  group('prepareContactContext', () {
    test('should return success when context is prepared', () async {
      // Arrange
      const testContext = ChatEntryContext(
        status: ChatEntryStatus.roomReady,
        roomId: 'room-123',
        otherProfileId: 'user-456',
        otherFullName: 'John Doe',
      );
      when(() => mockDatasource.prepareContactContext('user-456'))
          .thenAnswer((_) async => testContext);

      // Act
      final result = await repository.prepareContactContext('user-456');

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.status, ChatEntryStatus.roomReady);
      expect(result.data?.roomId, 'room-123');
      verify(() => mockDatasource.prepareContactContext('user-456')).called(1);
    });

    test('should return failure when context preparation fails', () async {
      // Arrange
      when(() => mockDatasource.prepareContactContext('user-456'))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.prepareContactContext('user-456');

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to prepare contact context'));
    });
  });

  // ==============================================================
  // CREATECONTACTREQUEST TESTS
  // ==============================================================

  group('createContactRequest', () {
    test('should return success with request ID', () async {
      // Arrange
      when(() => mockDatasource.createContactRequest(
            targetId: any(named: 'targetId'),
            source: any(named: 'source'),
            message: any(named: 'message'),
          )).thenAnswer((_) async => 'req-123');

      // Act
      final result = await repository.createContactRequest(
        targetId: 'user-456',
        source: ContactRequestSource.fromProfile,
        message: 'Hello, I would like to connect!',
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, 'req-123');
    });

    test('should return failure when creation fails', () async {
      // Arrange
      when(() => mockDatasource.createContactRequest(
            targetId: any(named: 'targetId'),
            source: any(named: 'source'),
            message: any(named: 'message'),
          )).thenThrow(Exception('Rate limit exceeded'));

      // Act
      final result = await repository.createContactRequest(
        targetId: 'user-456',
        source: ContactRequestSource.fromWishlist,
        message: 'Hello!',
      );

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to create contact request'));
    });
  });

  // ==============================================================
  // GETPENDINGCONTACTREQUESTS TESTS
  // ==============================================================

  group('getPendingContactRequests', () {
    test('should return success with requests list', () async {
      // Arrange
      final testRequests = [
        ContactRequest(
          id: 'req-1',
          proProfileId: 'pro-123',
          brideProfileId: 'bride-456',
          initiatorId: 'pro-123',
          source: ContactRequestSource.fromProfile,
          status: ConnectionRequestStatus.pending,
          createdAt: DateTime.now(),
          otherFullName: 'Pro User',
        ),
      ];
      when(() => mockDatasource.getPendingContactRequests())
          .thenAnswer((_) async => testRequests);

      // Act
      final result = await repository.getPendingContactRequests();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.length, 1);
      expect(result.data?[0].id, 'req-1');
    });

    test('should return failure when fetch fails', () async {
      // Arrange
      when(() => mockDatasource.getPendingContactRequests())
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getPendingContactRequests();

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to load contact requests'));
    });

    test('should return empty list when no pending requests', () async {
      // Arrange
      when(() => mockDatasource.getPendingContactRequests())
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getPendingContactRequests();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isEmpty);
    });
  });

  // ==============================================================
  // ACCEPTCONTACTREQUEST TESTS
  // ==============================================================

  group('acceptContactRequest', () {
    test('should return success with room ID', () async {
      // Arrange
      when(() => mockDatasource.acceptContactRequest('req-123'))
          .thenAnswer((_) async => 'room-456');

      // Act
      final result = await repository.acceptContactRequest('req-123');

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, 'room-456');
      verify(() => mockDatasource.acceptContactRequest('req-123')).called(1);
    });

    test('should return failure when accept fails', () async {
      // Arrange
      when(() => mockDatasource.acceptContactRequest('req-123'))
          .thenThrow(Exception('Request already processed'));

      // Act
      final result = await repository.acceptContactRequest('req-123');

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to accept contact request'));
    });
  });

  // ==============================================================
  // DECLINECONTACTREQUEST TESTS
  // ==============================================================

  group('declineContactRequest', () {
    test('should return success when decline succeeds', () async {
      // Arrange
      when(() => mockDatasource.declineContactRequest('req-123'))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.declineContactRequest('req-123');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.declineContactRequest('req-123')).called(1);
    });

    test('should return failure when decline fails', () async {
      // Arrange
      when(() => mockDatasource.declineContactRequest('req-123'))
          .thenThrow(Exception('Request not found'));

      // Act
      final result = await repository.declineContactRequest('req-123');

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to decline contact request'));
    });
  });

  // ==============================================================
  // BLOCKUSER TESTS
  // ==============================================================

  group('blockUser', () {
    test('should return success when block succeeds', () async {
      // Arrange
      when(() => mockDatasource.blockUser('user-456'))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.blockUser('user-456');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.blockUser('user-456')).called(1);
    });

    test('should return failure when block fails', () async {
      // Arrange
      when(() => mockDatasource.blockUser('user-456'))
          .thenThrow(Exception('Cannot block self'));

      // Act
      final result = await repository.blockUser('user-456');

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to block user'));
    });
  });

  // ==============================================================
  // UNBLOCKUSER TESTS
  // ==============================================================

  group('unblockUser', () {
    test('should return success when unblock succeeds', () async {
      // Arrange
      when(() => mockDatasource.unblockUser('user-456'))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.unblockUser('user-456');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.unblockUser('user-456')).called(1);
    });

    test('should return failure when unblock fails', () async {
      // Arrange
      when(() => mockDatasource.unblockUser('user-456'))
          .thenThrow(Exception('User not blocked'));

      // Act
      final result = await repository.unblockUser('user-456');

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to unblock user'));
    });
  });

  // ==============================================================
  // GETBLOCKEDUSERS TESTS
  // ==============================================================

  group('getBlockedUsers', () {
    test('should return success with blocked users list', () async {
      // Arrange
      final blockedUsers = [
        BlockedUser(
          blockedProfileId: 'user-blocked-1',
          createdAt: DateTime.now(),
          fullName: 'Blocked Person',
          role: UserRole.professional,
        ),
      ];
      when(() => mockDatasource.getBlockedUsers())
          .thenAnswer((_) async => blockedUsers);

      // Act
      final result = await repository.getBlockedUsers();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.length, 1);
      expect(result.data?[0].fullName, 'Blocked Person');
    });

    test('should return failure when fetch fails', () async {
      // Arrange
      when(() => mockDatasource.getBlockedUsers())
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getBlockedUsers();

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to load blocked users'));
    });
  });

  // ==============================================================
  // ISUSERBLOCKED TESTS
  // ==============================================================

  group('isUserBlocked', () {
    test('should return success with true when user is blocked', () async {
      // Arrange
      when(() => mockDatasource.isUserBlocked('user-456'))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.isUserBlocked('user-456');

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, true);
    });

    test('should return success with false when user is not blocked', () async {
      // Arrange
      when(() => mockDatasource.isUserBlocked('user-789'))
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.isUserBlocked('user-789');

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, false);
    });

    test('should return failure when check fails', () async {
      // Arrange
      when(() => mockDatasource.isUserBlocked('user-456'))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.isUserBlocked('user-456');

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to check block status'));
    });
  });

  // ==============================================================
  // REPORTMESSAGE TESTS
  // ==============================================================

  group('reportMessage', () {
    test('should return success when report succeeds', () async {
      // Arrange
      when(() => mockDatasource.reportMessage(
            messageId: any(named: 'messageId'),
            reason: any(named: 'reason'),
            details: any(named: 'details'),
          )).thenAnswer((_) async {});

      // Act
      final result = await repository.reportMessage(
        messageId: 123,
        reason: ReportReason.spam,
        details: 'Promotional content',
      );

      // Assert
      expect(result.isSuccess, true);
    });

    test('should return failure when report fails', () async {
      // Arrange
      when(() => mockDatasource.reportMessage(
            messageId: any(named: 'messageId'),
            reason: any(named: 'reason'),
            details: any(named: 'details'),
          )).thenThrow(Exception('Already reported'));

      // Act
      final result = await repository.reportMessage(
        messageId: 123,
        reason: ReportReason.harassment,
      );

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to report message'));
    });
  });

  // ==============================================================
  // REPORTUSER TESTS
  // ==============================================================

  group('reportUser', () {
    test('should return success when report succeeds', () async {
      // Arrange
      when(() => mockDatasource.reportUser(
            reportedProfileId: any(named: 'reportedProfileId'),
            reason: any(named: 'reason'),
            details: any(named: 'details'),
          )).thenAnswer((_) async {});

      // Act
      final result = await repository.reportUser(
        reportedProfileId: 'user-456',
        reason: ReportReason.inappropriateContent,
        details: 'Offensive profile picture',
      );

      // Assert
      expect(result.isSuccess, true);
    });

    test('should return failure when report fails', () async {
      // Arrange
      when(() => mockDatasource.reportUser(
            reportedProfileId: any(named: 'reportedProfileId'),
            reason: any(named: 'reason'),
            details: any(named: 'details'),
          )).thenThrow(Exception('Cannot report self'));

      // Act
      final result = await repository.reportUser(
        reportedProfileId: 'user-456',
        reason: ReportReason.other,
      );

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to report user'));
    });
  });

  // ==============================================================
  // REALTIME SUBSCRIPTION TESTS
  // ==============================================================

  group('subscribeToContactRequests', () {
    test('should delegate to datasource', () {
      // Arrange
      when(() => mockDatasource.subscribeToContactRequests())
          .thenAnswer((_) => const Stream.empty());

      // Act
      final stream = repository.subscribeToContactRequests();

      // Assert
      expect(stream, isA<Stream<ContactRequest>>());
      verify(() => mockDatasource.subscribeToContactRequests()).called(1);
    });
  });
}
