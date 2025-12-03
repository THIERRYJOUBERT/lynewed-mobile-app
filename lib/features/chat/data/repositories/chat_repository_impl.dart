/// Chat repository implementation - Clean Architecture
/// 
/// Implements ChatRepository using ChatRemoteDatasource.
library;

import '../../domain/entities/entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

/// Implementation of ChatRepository
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({ChatRemoteDatasource? datasource})
      : _datasource = datasource ?? ChatRemoteDatasource();

  final ChatRemoteDatasource _datasource;

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  @override
  Future<ChatResult<List<Conversation>>> getConversations() async {
    try {
      final conversations = await _datasource.getConversations();
      return ChatResult.success(conversations);
    } catch (e) {
      return ChatResult.failure('Failed to load conversations: $e');
    }
  }

  @override
  Future<ChatResult<List<Conversation>>> getPublicChatRooms() async {
    try {
      final rooms = await _datasource.getPublicChatRooms();
      return ChatResult.success(rooms);
    } catch (e) {
      return ChatResult.failure('Failed to load public rooms: $e');
    }
  }

  @override
  Future<ChatResult<void>> archiveConversation(String roomId) async {
    try {
      await _datasource.archiveConversation(roomId);
      return const ChatResult.success(null);
    } catch (e) {
      return ChatResult.failure('Failed to archive conversation: $e');
    }
  }

  @override
  Future<ChatResult<void>> unarchiveConversation(String roomId) async {
    try {
      await _datasource.unarchiveConversation(roomId);
      return const ChatResult.success(null);
    } catch (e) {
      return ChatResult.failure('Failed to unarchive conversation: $e');
    }
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  @override
  Future<ChatResult<List<ChatMessage>>> getMessages({
    required String roomId,
    int limit = 50,
    int? beforeId,
  }) async {
    try {
      final messages = await _datasource.getMessages(
        roomId: roomId,
        limit: limit,
        beforeId: beforeId,
      );
      return ChatResult.success(messages);
    } catch (e) {
      return ChatResult.failure('Failed to load messages: $e');
    }
  }

  @override
  Future<ChatResult<ChatMessage>> sendTextMessage({
    required String roomId,
    required String content,
  }) async {
    try {
      final message = await _datasource.sendMessage(
        roomId: roomId,
        type: MessageType.text,
        content: content,
      );
      return ChatResult.success(message);
    } catch (e) {
      return ChatResult.failure('Failed to send message: $e');
    }
  }

  @override
  Future<ChatResult<ChatMessage>> sendImageMessage({
    required String roomId,
    required String attachmentUrl,
  }) async {
    try {
      final message = await _datasource.sendMessage(
        roomId: roomId,
        type: MessageType.image,
        attachmentUrl: attachmentUrl,
      );
      return ChatResult.success(message);
    } catch (e) {
      return ChatResult.failure('Failed to send image: $e');
    }
  }

  @override
  Future<ChatResult<ChatMessage>> sendAudioMessage({
    required String roomId,
    required String attachmentUrl,
  }) async {
    try {
      final message = await _datasource.sendMessage(
        roomId: roomId,
        type: MessageType.audio,
        attachmentUrl: attachmentUrl,
      );
      return ChatResult.success(message);
    } catch (e) {
      return ChatResult.failure('Failed to send audio: $e');
    }
  }

  @override
  Future<ChatResult<void>> deleteMessage(int messageId) async {
    try {
      await _datasource.deleteMessage(messageId);
      return const ChatResult.success(null);
    } catch (e) {
      return ChatResult.failure('Failed to delete message: $e');
    }
  }

  @override
  Future<ChatResult<void>> markRoomAsRead(String roomId) async {
    try {
      await _datasource.markRoomAsRead(roomId);
      return const ChatResult.success(null);
    } catch (e) {
      return ChatResult.failure('Failed to mark room as read: $e');
    }
  }

  // ============================================================
  // REALTIME
  // ============================================================

  @override
  Stream<ChatMessage> subscribeToMessages(String roomId) {
    return _datasource.subscribeToMessages(roomId);
  }

  @override
  Stream<void> subscribeToConversationUpdates() {
    return _datasource.subscribeToConversationUpdates();
  }

  @override
  void disposeSubscriptions() {
    _datasource.disposeSubscriptions();
  }

  // ============================================================
  // MEDIA
  // ============================================================

  @override
  Future<ChatResult<String>> uploadImage({
    required String roomId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final path = await _datasource.uploadImage(
        roomId: roomId,
        filePath: filePath,
        fileName: fileName,
      );
      return ChatResult.success(path);
    } catch (e) {
      return ChatResult.failure('Failed to upload image: $e');
    }
  }

  @override
  Future<ChatResult<String>> uploadAudio({
    required String roomId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final path = await _datasource.uploadAudio(
        roomId: roomId,
        filePath: filePath,
        fileName: fileName,
      );
      return ChatResult.success(path);
    } catch (e) {
      return ChatResult.failure('Failed to upload audio: $e');
    }
  }

  @override
  Future<ChatResult<String>> getSignedUrl(String path) async {
    try {
      final url = await _datasource.getSignedUrl(path);
      return ChatResult.success(url);
    } catch (e) {
      return ChatResult.failure('Failed to get signed URL: $e');
    }
  }
}
