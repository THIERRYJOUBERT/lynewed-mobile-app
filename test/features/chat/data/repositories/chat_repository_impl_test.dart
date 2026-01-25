import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lynewed_beta/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:lynewed_beta/features/chat/domain/entities/entities.dart';
import 'package:lynewed_beta/features/chat/domain/repositories/chat_repository.dart';

// ==============================================================
// MOCKS
// ==============================================================

class MockChatRemoteDatasource extends Mock implements ChatRemoteDatasource {}

void main() {
  late MockChatRemoteDatasource mockDatasource;
  late ChatRepositoryImpl repository;

  setUpAll(() {
    // Register fallback values for any() matchers
    registerFallbackValue(MessageType.text);
  });

  setUp(() {
    mockDatasource = MockChatRemoteDatasource();
    repository = ChatRepositoryImpl(datasource: mockDatasource);
  });

  // ==============================================================
  // CHATRESULT TESTS (Test the wrapper class)
  // ==============================================================

  group('ChatResult', () {
    test('success should have data and no error', () {
      const result = ChatResult.success('test data');

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.data, 'test data');
      expect(result.error, isNull);
    });

    test('failure should have error and no data', () {
      const result = ChatResult<String>.failure('error message');

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.data, isNull);
      expect(result.error, 'error message');
    });

    test('success with void should work', () {
      const result = ChatResult<void>.success(null);

      expect(result.isSuccess, true);
      expect(result.error, isNull);
    });

    test('success with list should work', () {
      const result = ChatResult<List<String>>.success(['a', 'b', 'c']);

      expect(result.isSuccess, true);
      expect(result.data, ['a', 'b', 'c']);
    });
  });

  // ==============================================================
  // GETCONVERSATIONS TESTS
  // ==============================================================

  group('getConversations', () {
    test('should return success when datasource returns data', () async {
      // Arrange
      final testConversations = [
        Conversation(
          roomId: 'room-1',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 0,
        ),
        Conversation(
          roomId: 'room-2',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
        ),
      ];
      when(() => mockDatasource.getConversations())
          .thenAnswer((_) async => testConversations);

      // Act
      final result = await repository.getConversations();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.length, 2);
      expect(result.data?[0].roomId, 'room-1');
      expect(result.data?[1].unreadCount, 5);
      verify(() => mockDatasource.getConversations()).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.getConversations())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getConversations();

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to load conversations'));
    });

    test('should return empty list when datasource returns empty', () async {
      // Arrange
      when(() => mockDatasource.getConversations())
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getConversations();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isEmpty);
    });
  });

  // ==============================================================
  // GETMESSAGES TESTS
  // ==============================================================

  group('getMessages', () {
    test('should return success with messages', () async {
      // Arrange
      final testMessages = [
        ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: DateTime.now(),
          content: 'Hello',
        ),
        ChatMessage(
          id: 2,
          roomId: 'room-123',
          profileId: 'user-789',
          messageType: MessageType.text,
          createdAt: DateTime.now(),
          content: 'Hi there!',
        ),
      ];
      when(() => mockDatasource.getMessages(
            roomId: any(named: 'roomId'),
            limit: any(named: 'limit'),
            beforeId: any(named: 'beforeId'),
          )).thenAnswer((_) async => testMessages);

      // Act
      final result = await repository.getMessages(roomId: 'room-123');

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.length, 2);
      verify(() => mockDatasource.getMessages(
            roomId: 'room-123',
            limit: 50,
            beforeId: null,
          )).called(1);
    });

    test('should pass pagination parameters correctly', () async {
      // Arrange
      when(() => mockDatasource.getMessages(
            roomId: any(named: 'roomId'),
            limit: any(named: 'limit'),
            beforeId: any(named: 'beforeId'),
          )).thenAnswer((_) async => []);

      // Act
      await repository.getMessages(
        roomId: 'room-123',
        limit: 20,
        beforeId: 100,
      );

      // Assert
      verify(() => mockDatasource.getMessages(
            roomId: 'room-123',
            limit: 20,
            beforeId: 100,
          )).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.getMessages(
            roomId: any(named: 'roomId'),
            limit: any(named: 'limit'),
            beforeId: any(named: 'beforeId'),
          )).thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getMessages(roomId: 'room-123');

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to load messages'));
    });
  });

  // ==============================================================
  // SENDTEXTMESSAGE TESTS
  // ==============================================================

  group('sendTextMessage', () {
    test('should return success when message is sent', () async {
      // Arrange
      final sentMessage = ChatMessage(
        id: 1,
        roomId: 'room-123',
        profileId: 'user-456',
        messageType: MessageType.text,
        createdAt: DateTime.now(),
        content: 'Test message',
      );
      when(() => mockDatasource.sendMessage(
            roomId: any(named: 'roomId'),
            type: any(named: 'type'),
            content: any(named: 'content'),
            attachmentUrl: any(named: 'attachmentUrl'),
            attachmentName: any(named: 'attachmentName'),
            attachmentSize: any(named: 'attachmentSize'),
            attachmentMimeType: any(named: 'attachmentMimeType'),
          )).thenAnswer((_) async => sentMessage);

      // Act
      final result = await repository.sendTextMessage(
        roomId: 'room-123',
        content: 'Test message',
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.content, 'Test message');
      expect(result.data?.messageType, MessageType.text);
    });

    test('should return failure when send fails', () async {
      // Arrange
      when(() => mockDatasource.sendMessage(
            roomId: any(named: 'roomId'),
            type: any(named: 'type'),
            content: any(named: 'content'),
            attachmentUrl: any(named: 'attachmentUrl'),
            attachmentName: any(named: 'attachmentName'),
            attachmentSize: any(named: 'attachmentSize'),
            attachmentMimeType: any(named: 'attachmentMimeType'),
          )).thenThrow(Exception('Send failed'));

      // Act
      final result = await repository.sendTextMessage(
        roomId: 'room-123',
        content: 'Test message',
      );

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to send message'));
    });
  });

  // ==============================================================
  // SENDIMAGEMESSAGE TESTS
  // ==============================================================

  group('sendImageMessage', () {
    test('should return success when image is sent', () async {
      // Arrange
      final sentMessage = ChatMessage(
        id: 1,
        roomId: 'room-123',
        profileId: 'user-456',
        messageType: MessageType.image,
        createdAt: DateTime.now(),
        attachmentUrl: 'https://example.com/image.jpg',
      );
      when(() => mockDatasource.sendMessage(
            roomId: any(named: 'roomId'),
            type: any(named: 'type'),
            content: any(named: 'content'),
            attachmentUrl: any(named: 'attachmentUrl'),
            attachmentName: any(named: 'attachmentName'),
            attachmentSize: any(named: 'attachmentSize'),
            attachmentMimeType: any(named: 'attachmentMimeType'),
          )).thenAnswer((_) async => sentMessage);

      // Act
      final result = await repository.sendImageMessage(
        roomId: 'room-123',
        attachmentUrl: 'https://example.com/image.jpg',
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.messageType, MessageType.image);
      expect(result.data?.attachmentUrl, 'https://example.com/image.jpg');
    });
  });

  // ==============================================================
  // ARCHIVECONVERSATION TESTS
  // ==============================================================

  group('archiveConversation', () {
    test('should return success when archive succeeds', () async {
      // Arrange
      when(() => mockDatasource.archiveConversation('room-123'))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.archiveConversation('room-123');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.archiveConversation('room-123')).called(1);
    });

    test('should return failure when archive fails', () async {
      // Arrange
      when(() => mockDatasource.archiveConversation('room-123'))
          .thenThrow(Exception('Archive failed'));

      // Act
      final result = await repository.archiveConversation('room-123');

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to archive'));
    });
  });

  // ==============================================================
  // MARKROOMASREAD TESTS
  // ==============================================================

  group('markRoomAsRead', () {
    test('should return success when mark as read succeeds', () async {
      // Arrange
      when(() => mockDatasource.markRoomAsRead('room-123'))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.markRoomAsRead('room-123');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.markRoomAsRead('room-123')).called(1);
    });

    test('should return failure when mark as read fails', () async {
      // Arrange
      when(() => mockDatasource.markRoomAsRead('room-123'))
          .thenThrow(Exception('Mark failed'));

      // Act
      final result = await repository.markRoomAsRead('room-123');

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to mark room as read'));
    });
  });

  // ==============================================================
  // DELETEMESSAGE TESTS
  // ==============================================================

  group('deleteMessage', () {
    test('should return success when delete succeeds', () async {
      // Arrange
      when(() => mockDatasource.deleteMessage(123))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.deleteMessage(123);

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.deleteMessage(123)).called(1);
    });

    test('should return failure when delete fails', () async {
      // Arrange
      when(() => mockDatasource.deleteMessage(123))
          .thenThrow(Exception('Delete failed'));

      // Act
      final result = await repository.deleteMessage(123);

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to delete message'));
    });
  });

  // ==============================================================
  // GETPUBLICROOMS TESTS
  // ==============================================================

  group('getPublicChatRooms', () {
    test('should return success with public rooms', () async {
      // Arrange
      final publicRooms = [
        Conversation(
          roomId: 'public-1',
          roomType: RoomType.public,
          conversationStatus: ConversationStatus.active,
          unreadCount: 0,
          publicTitle: 'Brides Group',
        ),
      ];
      when(() => mockDatasource.getPublicChatRooms())
          .thenAnswer((_) async => publicRooms);

      // Act
      final result = await repository.getPublicChatRooms();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.length, 1);
      expect(result.data?[0].publicTitle, 'Brides Group');
    });

    test('should return failure when fetch fails', () async {
      // Arrange
      when(() => mockDatasource.getPublicChatRooms())
          .thenThrow(Exception('Fetch failed'));

      // Act
      final result = await repository.getPublicChatRooms();

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to load public rooms'));
    });
  });

  // ==============================================================
  // UPLOAD TESTS
  // ==============================================================

  group('uploadImage', () {
    test('should return success with path', () async {
      // Arrange
      when(() => mockDatasource.uploadImage(
            roomId: any(named: 'roomId'),
            filePath: any(named: 'filePath'),
            fileName: any(named: 'fileName'),
          )).thenAnswer((_) async => 'room-123/image.jpg');

      // Act
      final result = await repository.uploadImage(
        roomId: 'room-123',
        filePath: '/tmp/image.jpg',
        fileName: 'image.jpg',
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, 'room-123/image.jpg');
    });

    test('should return failure when upload fails', () async {
      // Arrange
      when(() => mockDatasource.uploadImage(
            roomId: any(named: 'roomId'),
            filePath: any(named: 'filePath'),
            fileName: any(named: 'fileName'),
          )).thenThrow(Exception('Upload failed'));

      // Act
      final result = await repository.uploadImage(
        roomId: 'room-123',
        filePath: '/tmp/image.jpg',
        fileName: 'image.jpg',
      );

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to upload image'));
    });
  });

  // ==============================================================
  // REALTIME TESTS
  // ==============================================================

  group('realtime subscriptions', () {
    test('subscribeToMessages should delegate to datasource', () {
      // Arrange
      when(() => mockDatasource.subscribeToMessages('room-123'))
          .thenAnswer((_) => const Stream.empty());

      // Act
      final stream = repository.subscribeToMessages('room-123');

      // Assert
      expect(stream, isA<Stream<ChatMessage>>());
      verify(() => mockDatasource.subscribeToMessages('room-123')).called(1);
    });

    test('subscribeToConversationUpdates should delegate to datasource', () {
      // Arrange
      when(() => mockDatasource.subscribeToConversationUpdates())
          .thenAnswer((_) => const Stream.empty());

      // Act
      final stream = repository.subscribeToConversationUpdates();

      // Assert
      expect(stream, isA<Stream<void>>());
      verify(() => mockDatasource.subscribeToConversationUpdates()).called(1);
    });

    test('disposeSubscriptions should delegate to datasource', () {
      // Arrange
      when(() => mockDatasource.disposeSubscriptions()).thenReturn(null);

      // Act
      repository.disposeSubscriptions();

      // Assert
      verify(() => mockDatasource.disposeSubscriptions()).called(1);
    });
  });
}
