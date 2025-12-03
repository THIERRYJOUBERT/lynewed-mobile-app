/// Conversations notifier - Clean Architecture
/// 
/// Manages state for the Messages page using ChangeNotifier.
/// Includes realtime subscriptions for new messages and contact requests.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/contact_repository_impl.dart';
import 'conversations_state.dart';

/// Notifier for managing conversations list
class ConversationsNotifier extends ChangeNotifier {
  ConversationsNotifier({
    ChatRepository? chatRepository,
    ContactRepository? contactRepository,
  })  : _chatRepository = chatRepository ?? ChatRepositoryImpl(),
        _contactRepository = contactRepository ?? ContactRepositoryImpl();

  final ChatRepository _chatRepository;
  final ContactRepository _contactRepository;

  StreamSubscription<void>? _messagesSubscription;
  StreamSubscription<ContactRequest>? _requestsSubscription;

  ConversationsState _state = const ConversationsInitial();
  ConversationsState get state => _state;

  void _emit(ConversationsState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Load all data (conversations, requests, blocked users)
  Future<void> loadAll() async {
    _emit(const ConversationsLoading());

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _chatRepository.getConversations(),
        _contactRepository.getPendingContactRequests(),
        _contactRepository.getBlockedUsers(),
      ]);

      final conversationsResult = results[0] as ChatResult<List<Conversation>>;
      final requestsResult = results[1] as ChatResult<List<ContactRequest>>;
      final blockedResult = results[2] as ChatResult<List<BlockedUser>>;

      if (conversationsResult.isFailure) {
        _emit(ConversationsError(conversationsResult.error ?? 'Failed to load conversations'));
        return;
      }

      _emit(ConversationsLoaded(
        conversations: conversationsResult.data ?? [],
        pendingRequests: requestsResult.data ?? [],
        blockedUsers: blockedResult.data ?? [],
      ));

      // Setup realtime subscriptions after initial load
      _setupRealtimeListeners();
    } catch (e) {
      _emit(ConversationsError('Error loading data: $e'));
    }
  }

  /// Setup realtime subscriptions for new messages and contact requests
  void _setupRealtimeListeners() {
    // Cancel existing subscriptions
    _messagesSubscription?.cancel();
    _requestsSubscription?.cancel();

    // 1. Listen for new messages (refresh conversations list)
    _messagesSubscription = _chatRepository
        .subscribeToConversationUpdates()
        .listen((_) {
          // Debounce: only refresh if not already refreshing
          final currentState = _state;
          if (currentState is ConversationsLoaded && !currentState.isRefreshing) {
            refresh();
          }
        }, onError: (error) {
          debugPrint('Conversations realtime error: $error');
        });

    // 2. Listen for new contact requests
    _requestsSubscription = _contactRepository
        .subscribeToContactRequests()
        .listen((request) {
          final currentState = _state;
          if (currentState is ConversationsLoaded) {
            // Check if request already exists
            if (!currentState.pendingRequests.any((r) => r.id == request.id)) {
              final updatedRequests = [request, ...currentState.pendingRequests];
              _emit(currentState.copyWith(pendingRequests: updatedRequests));
            }
          }
        }, onError: (error) {
          debugPrint('Contact requests realtime error: $error');
        });
  }

  /// Refresh conversations only (background refresh)
  Future<void> refresh() async {
    final currentState = _state;
    if (currentState is! ConversationsLoaded) {
      await loadAll();
      return;
    }

    _emit(currentState.copyWith(isRefreshing: true));

    try {
      final results = await Future.wait([
        _chatRepository.getConversations(),
        _contactRepository.getPendingContactRequests(),
      ]);

      final conversationsResult = results[0] as ChatResult<List<Conversation>>;
      final requestsResult = results[1] as ChatResult<List<ContactRequest>>;

      _emit(currentState.copyWith(
        conversations: conversationsResult.data ?? currentState.conversations,
        pendingRequests: requestsResult.data ?? currentState.pendingRequests,
        isRefreshing: false,
      ));
    } catch (e) {
      _emit(currentState.copyWith(isRefreshing: false));
    }
  }

  /// Archive a conversation
  Future<void> archiveConversation(String roomId) async {
    final currentState = _state;
    if (currentState is! ConversationsLoaded) return;

    final result = await _chatRepository.archiveConversation(roomId);
    
    if (result.isSuccess) {
      // Update conversation status locally instead of removing
      final updatedConversations = currentState.conversations.map((c) {
        if (c.roomId == roomId) {
          return c.copyWith(conversationStatus: ConversationStatus.archived);
        }
        return c;
      }).toList();
      
      _emit(currentState.copyWith(conversations: updatedConversations));
    }
  }

  /// Unarchive a conversation
  Future<void> unarchiveConversation(String roomId) async {
    final currentState = _state;
    if (currentState is! ConversationsLoaded) return;

    final result = await _chatRepository.unarchiveConversation(roomId);
    
    if (result.isSuccess) {
      // Update conversation status locally
      final updatedConversations = currentState.conversations.map((c) {
        if (c.roomId == roomId) {
          return c.copyWith(conversationStatus: ConversationStatus.active);
        }
        return c;
      }).toList();
      
      _emit(currentState.copyWith(conversations: updatedConversations));
    }
  }

  /// Accept a contact request
  Future<String?> acceptRequest(String requestId) async {
    final currentState = _state;
    if (currentState is! ConversationsLoaded) return null;

    final result = await _contactRepository.acceptContactRequest(requestId);
    
    if (result.isSuccess) {
      // Remove from pending requests
      final updatedRequests = currentState.pendingRequests
          .where((r) => r.id != requestId)
          .toList();
      
      _emit(currentState.copyWith(pendingRequests: updatedRequests));
      
      // Refresh to get new conversation
      await refresh();
      
      return result.data;
    }
    
    return null;
  }

  /// Decline a contact request
  Future<bool> declineRequest(String requestId) async {
    final currentState = _state;
    if (currentState is! ConversationsLoaded) return false;

    final result = await _contactRepository.declineContactRequest(requestId);
    
    if (result.isSuccess) {
      // Remove from pending requests
      final updatedRequests = currentState.pendingRequests
          .where((r) => r.id != requestId)
          .toList();
      
      _emit(currentState.copyWith(pendingRequests: updatedRequests));
      return true;
    }
    
    return false;
  }

  /// Unblock a user
  Future<bool> unblockUser(String profileId) async {
    final currentState = _state;
    if (currentState is! ConversationsLoaded) return false;

    final result = await _contactRepository.unblockUser(profileId);
    
    if (result.isSuccess) {
      // Remove from blocked list
      final updatedBlocked = currentState.blockedUsers
          .where((b) => b.blockedProfileId != profileId)
          .toList();
      
      _emit(currentState.copyWith(blockedUsers: updatedBlocked));
      return true;
    }
    
    return false;
  }

  /// Block a user from a conversation
  Future<bool> blockUser(String profileId) async {
    final currentState = _state;
    if (currentState is! ConversationsLoaded) return false;

    final result = await _contactRepository.blockUser(profileId);
    
    if (result.isSuccess) {
      // Update conversation status to blocked
      final updatedConversations = currentState.conversations.map((c) {
        if (c.otherProfileId == profileId) {
          return c.copyWith(conversationStatus: ConversationStatus.blocked);
        }
        return c;
      }).toList();
      
      // Refresh blocked users list
      final blockedResult = await _contactRepository.getBlockedUsers();
      
      _emit(currentState.copyWith(
        conversations: updatedConversations,
        blockedUsers: blockedResult.data ?? currentState.blockedUsers,
      ));
      return true;
    }
    
    return false;
  }

  /// Report a user
  /// Note: Reporting creates a support ticket but does NOT change conversation status
  /// The conversation remains visible with normal functionality
  Future<bool> reportUser({
    required String profileId,
    required ReportReason reason,
    String? details,
  }) async {
    final currentState = _state;
    if (currentState is! ConversationsLoaded) return false;

    final result = await _contactRepository.reportUser(
      reportedProfileId: profileId,
      reason: reason,
      details: details,
    );
    
    // Report just creates a ticket - conversation stays as-is
    // No local state change needed
    return result.isSuccess;
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _requestsSubscription?.cancel();
    _chatRepository.disposeSubscriptions();
    super.dispose();
  }
}
