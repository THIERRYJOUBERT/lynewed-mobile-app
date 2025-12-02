/// Conversations notifier - Clean Architecture
/// 
/// Manages state for the Messages page using ChangeNotifier.
library;

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
    } catch (e) {
      _emit(ConversationsError('Error loading data: $e'));
    }
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
      // Remove from local list
      final updatedConversations = currentState.conversations
          .where((c) => c.roomId != roomId)
          .toList();
      
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
}
