/// Chat room notifier - Clean Architecture
/// 
/// Manages state for a single chat room using ChangeNotifier.
/// Handles messages, realtime subscriptions, and media.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/contact_repository_impl.dart';
import 'chat_room_state.dart';

/// Notifier for managing a single chat room
class ChatRoomNotifier extends ChangeNotifier {
  ChatRoomNotifier({
    required String roomId,
    ChatRepository? chatRepository,
    ContactRepository? contactRepository,
    String? otherProfileId,
    String? otherFullName,
    String? otherAvatarUrl,
    UserRole? otherRole,
    bool isPublicRoom = false,
    String? publicRoomTitle,
    String? pendingRequestId,
    bool viewerIsReviewer = false,
  })  : _roomId = roomId,
        _chatRepository = chatRepository ?? ChatRepositoryImpl(),
        _contactRepository = contactRepository ?? ContactRepositoryImpl(),
        _otherProfileId = otherProfileId,
        _otherFullName = otherFullName,
        _otherAvatarUrl = otherAvatarUrl,
        _otherRole = otherRole,
        _isPublicRoom = isPublicRoom,
        _publicRoomTitle = publicRoomTitle,
        _pendingRequestId = pendingRequestId,
        _viewerIsReviewer = viewerIsReviewer;

  String _roomId; // Mutable to allow updating after accept
  final ChatRepository _chatRepository;
  final ContactRepository _contactRepository;

  // Initial context (passed from navigation) - mutable to allow loading from DB
  String? _otherProfileId;
  String? _otherFullName;
  String? _otherAvatarUrl;
  UserRole? _otherRole;
  final bool _isPublicRoom;
  final String? _publicRoomTitle;
  String? _pendingRequestId;
  final bool _viewerIsReviewer;

  ChatRoomState _state = const ChatRoomInitial();
  ChatRoomState get state => _state;

  StreamSubscription<ChatMessage>? _messagesSubscription;

  void _emit(ChatRoomState newState) {
    _state = newState;
    notifyListeners();
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Load initial messages and setup realtime
  Future<void> loadMessages() async {
    _emit(const ChatRoomLoading());

    try {
      // Special case: Pending contact request being reviewed by Bride
      // The room doesn't exist yet, so don't try to load messages or setup realtime
      if (_pendingRequestId != null && _viewerIsReviewer) {
        _emit(ChatRoomLoaded(
          messages: const [],
          roomId: _roomId, // This is actually the request ID, will be updated after accept
          otherProfileId: _otherProfileId,
          otherFullName: _otherFullName,
          otherAvatarUrl: _otherAvatarUrl,
          otherRole: _otherRole,
          isPublicRoom: _isPublicRoom,
          publicRoomTitle: _publicRoomTitle,
          hasMoreMessages: false,
          pendingRequestId: _pendingRequestId,
          viewerIsReviewer: _viewerIsReviewer,
        ));
        return;
      }

      // Load other participant info if not provided (fallback for edge cases)
      if (!_isPublicRoom && _roomId.isNotEmpty && _otherFullName == null) {
        await _loadOtherParticipantInfo();
      }

      final result = await _chatRepository.getMessages(roomId: _roomId);

      if (result.isFailure) {
        _emit(ChatRoomError(result.error ?? 'Failed to load messages'));
        return;
      }

      final messages = result.data ?? [];

      _emit(ChatRoomLoaded(
        messages: messages,
        roomId: _roomId,
        otherProfileId: _otherProfileId,
        otherFullName: _otherFullName,
        otherAvatarUrl: _otherAvatarUrl,
        otherRole: _otherRole,
        isPublicRoom: _isPublicRoom,
        publicRoomTitle: _publicRoomTitle,
        hasMoreMessages: messages.length >= 50,
        pendingRequestId: _pendingRequestId,
        viewerIsReviewer: _viewerIsReviewer,
      ));

      // Load author profiles for public rooms
      if (_isPublicRoom && messages.isNotEmpty) {
        await _loadAuthorsForMessages(messages);
      }

      // Mark room as read
      await _chatRepository.markRoomAsRead(_roomId);

      // Setup realtime subscription
      _setupRealtimeMessages();
    } catch (e) {
      _emit(ChatRoomError('Error loading messages: $e'));
    }
  }

  /// Setup realtime subscription for new messages
  void _setupRealtimeMessages() {
    _messagesSubscription?.cancel();

    _messagesSubscription = _chatRepository
        .subscribeToMessages(_roomId)
        .listen(_onNewMessage, onError: _onRealtimeError);
  }

  void _onNewMessage(ChatMessage message) {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return;

    // Check if message already exists (avoid duplicates)
    if (currentState.messages.any((m) => m.id == message.id)) return;

    // Add new message at the beginning (newest first)
    final updatedMessages = [message, ...currentState.messages];
    _emit(currentState.copyWith(messages: updatedMessages));

    // Load author profile for public rooms if not cached
    if (_isPublicRoom && !currentState.authors.containsKey(message.profileId)) {
      _loadAuthorsForMessages([message]);
    }

    // Mark as read since user is viewing
    _chatRepository.markRoomAsRead(_roomId);
  }

  void _onRealtimeError(Object error) {
    debugPrint('ChatRoom realtime error: $error');
    // Attempt to reconnect after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (_state is ChatRoomLoaded) {
        _setupRealtimeMessages();
      }
    });
  }

  /// Load other participant info from the room (fallback for edge cases)
  Future<void> _loadOtherParticipantInfo() async {
    try {
      final result = await _chatRepository.getOtherParticipantInfo(_roomId);
      if (result.isSuccess && result.data != null) {
        final info = result.data!;
        _otherProfileId = info['id'] as String?;
        _otherFullName = info['full_name'] as String?;
        _otherAvatarUrl = info['avatar_url'] as String?;
        final roleStr = info['role'] as String?;
        _otherRole = roleStr != null ? UserRole.fromString(roleStr) : null;
      }
    } catch (e) {
      // Silently fail - UI will show fallback "Conversation"
    }
  }

  /// Load author profiles for public room messages
  Future<void> _loadAuthorsForMessages(List<ChatMessage> messages) async {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return;

    // Get unique profile IDs that we don't have yet
    final existingAuthors = currentState.authors;
    final profileIds = <String>{};
    for (final msg in messages) {
      if (!existingAuthors.containsKey(msg.profileId)) {
        profileIds.add(msg.profileId);
      }
    }

    if (profileIds.isEmpty) return;

    try {
      final result = await _chatRepository.getProfilesInfo(profileIds.toList());
      if (result.isFailure || result.data == null) return;

      final newAuthors = Map<String, AuthorInfo>.from(existingAuthors);
      for (final profile in result.data!) {
        final id = profile['id'] as String?;
        if (id != null) {
          newAuthors[id] = AuthorInfo(
            profileId: id,
            fullName: profile['full_name'] as String? ?? 'User',
            avatarUrl: profile['avatar_url'] as String?,
          );
        }
      }

      // Update state with new authors
      final updatedState = _state;
      if (updatedState is ChatRoomLoaded) {
        _emit(updatedState.copyWith(authors: newAuthors));
      }
    } catch (e) {
      debugPrint('Error loading authors: $e');
    }
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  /// Load more (older) messages
  Future<void> loadMoreMessages() async {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMoreMessages) return;

    _emit(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await _chatRepository.getMessages(
        roomId: _roomId,
        beforeId: currentState.oldestMessageId,
      );

      if (result.isFailure) {
        _emit(currentState.copyWith(isLoadingMore: false));
        return;
      }

      final olderMessages = result.data ?? [];
      final updatedMessages = [...currentState.messages, ...olderMessages];

      _emit(currentState.copyWith(
        messages: updatedMessages,
        hasMoreMessages: olderMessages.length >= 50,
        isLoadingMore: false,
      ));
    } catch (e) {
      _emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  // ============================================================
  // SENDING MESSAGES
  // ============================================================

  /// Send a text message
  Future<bool> sendTextMessage(String content) async {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return false;
    if (content.trim().isEmpty) return false;

    _emit(currentState.copyWith(isSending: true));

    try {
      final result = await _chatRepository.sendTextMessage(
        roomId: _roomId,
        content: content.trim(),
      );

      if (result.isFailure) {
        _emit(currentState.copyWith(isSending: false));
        return false;
      }

      // Message will be added via realtime subscription
      _emit(currentState.copyWith(isSending: false));
      return true;
    } catch (e) {
      _emit(currentState.copyWith(isSending: false));
      return false;
    }
  }

  /// Send an image message
  /// Note: For multiple images, call this method sequentially.
  /// The isSending state is managed to avoid flickering.
  Future<bool> sendImageMessage({
    required String filePath,
    required String fileName,
  }) async {
    var currentState = _state;
    if (currentState is! ChatRoomLoaded) return false;

    // Only set isSending if not already sending
    if (!currentState.isSending) {
      _emit(currentState.copyWith(isSending: true));
      currentState = _state as ChatRoomLoaded;
    }

    try {
      // Upload image first
      final uploadResult = await _chatRepository.uploadImage(
        roomId: _roomId,
        filePath: filePath,
        fileName: fileName,
      );

      if (uploadResult.isFailure) {
        // Get fresh state before emitting
        final freshState = _state;
        if (freshState is ChatRoomLoaded) {
          _emit(freshState.copyWith(isSending: false));
        }
        return false;
      }

      // Send message with attachment URL
      final result = await _chatRepository.sendImageMessage(
        roomId: _roomId,
        attachmentUrl: uploadResult.data!,
      );

      // Don't set isSending to false here - let the caller manage it
      // This prevents flickering when sending multiple images
      return result.isSuccess;
    } catch (e) {
      // Get fresh state before emitting
      final freshState = _state;
      if (freshState is ChatRoomLoaded) {
        _emit(freshState.copyWith(isSending: false));
      }
      return false;
    }
  }

  /// Mark sending as complete (call after all images are sent)
  void markSendingComplete() {
    final currentState = _state;
    if (currentState is ChatRoomLoaded && currentState.isSending) {
      _emit(currentState.copyWith(isSending: false));
    }
  }

  /// Send an audio message
  Future<bool> sendAudioMessage({
    required String filePath,
    required String fileName,
  }) async {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return false;

    _emit(currentState.copyWith(isSending: true));

    try {
      // Upload audio first
      final uploadResult = await _chatRepository.uploadAudio(
        roomId: _roomId,
        filePath: filePath,
        fileName: fileName,
      );

      if (uploadResult.isFailure) {
        _emit(currentState.copyWith(isSending: false));
        return false;
      }

      // Send message with attachment URL
      final result = await _chatRepository.sendAudioMessage(
        roomId: _roomId,
        attachmentUrl: uploadResult.data!,
      );

      _emit(currentState.copyWith(isSending: false));
      return result.isSuccess;
    } catch (e) {
      _emit(currentState.copyWith(isSending: false));
      return false;
    }
  }

  // ============================================================
  // MESSAGE ACTIONS
  // ============================================================

  /// Delete own message
  Future<bool> deleteMessage(int messageId) async {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return false;

    try {
      final result = await _chatRepository.deleteMessage(messageId);

      if (result.isSuccess) {
        // Remove from local list
        final updatedMessages = currentState.messages
            .where((m) => m.id != messageId)
            .toList();
        _emit(currentState.copyWith(messages: updatedMessages));
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Report a message
  Future<bool> reportMessage({
    required int messageId,
    required ReportReason reason,
    String? details,
  }) async {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return false;

    try {
      final result = await _contactRepository.reportMessage(
        messageId: messageId,
        reason: reason,
        details: details,
      );

      if (result.isSuccess) {
        // Remove from local list (message is marked as deleted by trigger)
        final updatedMessages = currentState.messages
            .where((m) => m.id != messageId)
            .toList();
        _emit(currentState.copyWith(messages: updatedMessages));
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // CONTACT REQUEST ACTIONS
  // ============================================================

  /// Accept a pending contact request (Bride action)
  /// Returns the new room ID on success, null on failure
  Future<String?> acceptContactRequest() async {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return null;
    if (currentState.pendingRequestId == null) return null;

    try {
      final result = await _contactRepository.acceptContactRequest(
        currentState.pendingRequestId!,
      );

      if (result.isSuccess && result.data != null) {
        final newRoomId = result.data!;
        
        // Update internal state
        _pendingRequestId = null;
        _roomId = newRoomId;
        
        // Emit updated state with new roomId and cleared pending request
        _emit(currentState.copyWith(
          roomId: newRoomId,
          clearPendingRequestId: true,
          viewerIsReviewer: false,
        ));
        
        // Load messages from the new room (which includes the initial message)
        await _loadMessagesAfterAccept(newRoomId);
        
        return newRoomId;
      }

      return null;
    } catch (e) {
      debugPrint('ChatRoomNotifier.acceptContactRequest error: $e');
      return null;
    }
  }

  /// Load messages after accepting a contact request
  Future<void> _loadMessagesAfterAccept(String roomId) async {
    try {
      final result = await _chatRepository.getMessages(roomId: roomId);
      
      if (result.isSuccess) {
        final messages = result.data ?? [];
        final currentState = _state;
        
        if (currentState is ChatRoomLoaded) {
          _emit(currentState.copyWith(
            messages: messages,
            roomId: roomId,
            hasMoreMessages: messages.length >= 50,
          ));
        }
        
        // Mark room as read
        await _chatRepository.markRoomAsRead(roomId);
        
        // Setup realtime subscription for new messages
        _setupRealtimeMessages();
      }
    } catch (e) {
      debugPrint('ChatRoomNotifier._loadMessagesAfterAccept error: $e');
    }
  }

  /// Decline a pending contact request (Bride action)
  Future<bool> declineContactRequest() async {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return false;
    if (currentState.pendingRequestId == null) return false;

    try {
      final result = await _contactRepository.declineContactRequest(
        currentState.pendingRequestId!,
      );

      if (result.isSuccess) {
        // Clear pending request state
        _pendingRequestId = null;
        _emit(currentState.clearPendingRequest());
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // BLOCKING
  // ============================================================

  /// Block the other user in this conversation
  Future<bool> blockUser() async {
    final currentState = _state;
    if (currentState is! ChatRoomLoaded) return false;
    if (currentState.otherProfileId == null) return false;

    try {
      final result = await _contactRepository.blockUser(
        currentState.otherProfileId!,
      );
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // MEDIA
  // ============================================================

  /// Get signed URL for media attachment
  Future<String?> getSignedUrl(String path) async {
    try {
      final result = await _chatRepository.getSignedUrl(path);
      return result.isSuccess ? result.data : null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _chatRepository.disposeSubscriptions();
    super.dispose();
  }
}
