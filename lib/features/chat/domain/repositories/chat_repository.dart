/// Chat repository interface - Clean Architecture
/// 
/// Defines the contract for chat data operations.
library;

import '../entities/entities.dart';

/// Result wrapper for repository operations
class ChatResult<T> {
  const ChatResult.success(this.data) : error = null;
  const ChatResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Chat repository interface
abstract class ChatRepository {
  // ============================================================
  // CONVERSATIONS
  // ============================================================

  /// Get all conversations for current user
  Future<ChatResult<List<Conversation>>> getConversations();

  /// Get public chat rooms for brides
  Future<ChatResult<List<Conversation>>> getPublicChatRooms();

  /// Archive a conversation
  Future<ChatResult<void>> archiveConversation(String roomId);

  /// Unarchive a conversation
  Future<ChatResult<void>> unarchiveConversation(String roomId);

  /// Get other participant info for a private room
  /// Returns map with: id, full_name, avatar_url, role
  Future<ChatResult<Map<String, dynamic>?>> getOtherParticipantInfo(String roomId);

  /// Get profiles info for multiple profile IDs (for public rooms)
  /// Returns list of maps with: id, full_name, avatar_url
  Future<ChatResult<List<Map<String, dynamic>>>> getProfilesInfo(List<String> profileIds);

  // ============================================================
  // PARTICIPANTS
  // ============================================================

  /// Get all participants for a room with their profile info
  Future<ChatResult<List<ChatParticipant>>> getRoomParticipants(String roomId);

  // ============================================================
  // MESSAGES
  // ============================================================

  /// Get messages for a room with pagination
  Future<ChatResult<List<ChatMessage>>> getMessages({
    required String roomId,
    int limit = 50,
    int? beforeId,
  });

  /// Send a text message
  Future<ChatResult<ChatMessage>> sendTextMessage({
    required String roomId,
    required String content,
  });

  /// Send an image message
  Future<ChatResult<ChatMessage>> sendImageMessage({
    required String roomId,
    required String attachmentUrl,
  });

  /// Send an audio message
  Future<ChatResult<ChatMessage>> sendAudioMessage({
    required String roomId,
    required String attachmentUrl,
  });

  /// Send a document message (PDF)
  Future<ChatResult<ChatMessage>> sendDocumentMessage({
    required String roomId,
    required String attachmentUrl,
    required String attachmentName,
    required int attachmentSize,
    required String attachmentMimeType,
  });

  /// Delete own message (soft delete)
  Future<ChatResult<void>> deleteMessage(int messageId);

  /// Update last_read_at for current user in room
  Future<ChatResult<void>> markRoomAsRead(String roomId);

  // ============================================================
  // REALTIME
  // ============================================================

  /// Subscribe to new messages in a room
  Stream<ChatMessage> subscribeToMessages(String roomId);

  /// Subscribe to conversation updates (new messages in any room)
  Stream<void> subscribeToConversationUpdates();

  /// Dispose realtime subscriptions
  void disposeSubscriptions();

  // ============================================================
  // MEDIA
  // ============================================================

  /// Upload image to chat storage
  Future<ChatResult<String>> uploadImage({
    required String roomId,
    required String filePath,
    required String fileName,
  });

  /// Upload audio to chat storage
  Future<ChatResult<String>> uploadAudio({
    required String roomId,
    required String filePath,
    required String fileName,
  });

  /// Upload document (PDF) to chat storage
  Future<ChatResult<String>> uploadDocument({
    required String roomId,
    required String filePath,
    required String fileName,
  });

  /// Get signed URL for media
  Future<ChatResult<String>> getSignedUrl(String path);
}
