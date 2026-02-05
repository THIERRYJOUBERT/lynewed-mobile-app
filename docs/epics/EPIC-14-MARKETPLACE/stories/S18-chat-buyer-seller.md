# Story S18: Chat buyer/seller

## Description
En tant qu'acheteuse, je veux contacter le vendeur directement, afin de poser des questions sur l'article avant d'acheter.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a listing detail page When buyer clicks "Contact Seller" Then chat screen should open And buyer can send message
- [ ] Given an active conversation When seller sends a message Then buyer should see it instantly (Supabase Realtime)
- [ ] Given unread messages Then chat icon should show unread count And conversation should be marked unread in list
- [ ] Given a conversation When user opens it Then messages should load in chronological order And scroll to most recent
- [ ] Given the chat list When user has multiple conversations Then they should be grouped by listing And sorted by most recent message

---

## Entity Definitions

### ChatMessageEntity

```dart
/// Represents a message in a marketplace conversation.
///
/// Immutable data class for chat messages between buyer and seller.
import 'package:flutter/foundation.dart';

@immutable
class ChatMessageEntity {
  const ChatMessageEntity({
    required this.id,
    required this.listingId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  /// Message ID (UUID).
  final String id;

  /// Listing this conversation is about.
  final String listingId;

  /// Sender ID (references profiles table).
  final String senderId;

  /// Receiver ID (references profiles table).
  final String receiverId;

  /// Message content (text).
  final String content;

  /// When the message was sent.
  final DateTime createdAt;

  /// Whether the message has been read by the receiver.
  final bool isRead;

  /// Creates a ChatMessageEntity from Supabase JSON row.
  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  /// Converts to JSON for database insert (excludes auto-generated fields).
  Map<String, dynamic> toJson() {
    return {
      'listing_id': listingId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_read': isRead,
    };
  }

  /// Creates a copy with updated fields.
  ChatMessageEntity copyWith({
    String? id,
    String? listingId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageEntity &&
        other.id == id &&
        other.listingId == listingId &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.isRead == isRead;
  }

  @override
  int get hashCode => Object.hash(
        id,
        listingId,
        senderId,
        receiverId,
        content,
        createdAt,
        isRead,
      );

  @override
  String toString() => 'ChatMessageEntity($id, from: $senderId)';
}
```

### ConversationEntity

```dart
/// Represents a conversation summary for the chat list.
///
/// Aggregates information about a conversation between buyer and seller.
import 'package:flutter/foundation.dart';

@immutable
class ConversationEntity {
  const ConversationEntity({
    required this.listingId,
    required this.listingTitle,
    this.listingCoverUrl,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// Listing ID this conversation is about.
  final String listingId;

  /// Title of the listing.
  final String listingTitle;

  /// Cover photo URL of the listing.
  final String? listingCoverUrl;

  /// Other user ID (buyer or seller).
  final String otherUserId;

  /// Other user's display name.
  final String otherUserName;

  /// Other user's avatar URL.
  final String? otherUserAvatarUrl;

  /// Last message content.
  final String? lastMessage;

  /// Time of last message.
  final DateTime? lastMessageTime;

  /// Number of unread messages.
  final int unreadCount;

  /// Whether there are unread messages.
  bool get hasUnread => unreadCount > 0;

  /// Creates a ConversationEntity from Supabase JSON row.
  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    return ConversationEntity(
      listingId: json['listing_id'] as String,
      listingTitle: json['listing_title'] as String,
      listingCoverUrl: json['listing_cover_url'] as String?,
      otherUserId: json['other_user_id'] as String,
      otherUserName: json['other_user_name'] as String,
      otherUserAvatarUrl: json['other_user_avatar_url'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationEntity &&
        other.listingId == listingId &&
        other.otherUserId == otherUserId &&
        other.listingTitle == listingTitle &&
        other.lastMessage == lastMessage &&
        other.lastMessageTime == lastMessageTime &&
        other.unreadCount == unreadCount;
  }

  @override
  int get hashCode => Object.hash(
        listingId,
        otherUserId,
        listingTitle,
        lastMessage,
        lastMessageTime,
        unreadCount,
      );

  @override
  String toString() => 'ConversationEntity($listingId with $otherUserId)';
}
```

---

## Repository Interface

```dart
/// Repository interface for marketplace chat operations.
///
/// Provides methods for sending and receiving messages between buyers and sellers.
abstract class ChatRepository {
  /// Sends a message in a conversation.
  ///
  /// Creates a new message from current user to receiver about a listing.
  /// Returns the created message.
  Future<ChatMessageEntity> sendMessage({
    required String listingId,
    required String receiverId,
    required String content,
  });

  /// Gets messages for a conversation.
  ///
  /// Returns messages ordered by creation date (oldest first).
  /// [limit] defaults to 100 messages.
  Future<List<ChatMessageEntity>> getMessages({
    required String listingId,
    required String otherUserId,
    int limit = 100,
  });

  /// Subscribes to new messages in a conversation.
  ///
  /// Returns a stream of new messages as they arrive (Realtime).
  /// Only emits messages involving the current user.
  Stream<ChatMessageEntity> subscribeToMessages({
    required String listingId,
    required String currentUserId,
  });

  /// Marks conversation as read.
  ///
  /// Marks all unread messages from the other user as read.
  Future<void> markConversationAsRead({
    required String listingId,
    required String otherUserId,
  });

  /// Gets all conversations for the current user.
  ///
  /// Returns conversations grouped by listing, sorted by most recent message.
  Future<List<ConversationEntity>> getConversations();

  /// Gets unread message count stream.
  ///
  /// Returns a stream of the total unread count across all conversations.
  Stream<int> getUnreadCountStream();

  /// Unsubscribes from all Realtime channels.
  ///
  /// Call this in dispose() to clean up.
  void unsubscribeAll();
}
```

---

## Files to Create

```
CREATE:
- lib/features/marketplace/domain/entities/chat_message_entity.dart
- lib/features/marketplace/domain/entities/conversation_entity.dart
- lib/features/marketplace/domain/repositories/chat_repository.dart
- lib/features/marketplace/data/repositories/supabase_chat_repository.dart
- lib/features/marketplace/presentation/pages/chat_page.dart
- lib/features/marketplace/presentation/pages/chat_list_page.dart
- lib/features/marketplace/presentation/widgets/chat_message_widget.dart
- lib/features/marketplace/presentation/widgets/chat_input_widget.dart
- lib/features/marketplace/presentation/widgets/conversation_tile.dart
- lib/features/marketplace/presentation/widgets/listing_preview_widget.dart
- test/features/marketplace/domain/entities/chat_message_entity_test.dart
- test/features/marketplace/domain/entities/conversation_entity_test.dart
- test/features/marketplace/data/repositories/supabase_chat_repository_test.dart
- test/features/marketplace/presentation/pages/chat_page_test.dart

MODIFY:
- lib/core/di/injection_container.dart → register ChatRepository
- lib/core/navigation/routes.dart → add chat routes
- lib/flutter_flow/nav/nav.dart → add FFRoute for chat pages
- lib/features/marketplace/presentation/pages/listing_detail_page.dart → "Contact Seller" navigation
```

---

## DI Registration

```dart
// In injection_container.dart

Future<void> _initMarketplace() async {
  sl.registerLazySingleton<MarketplaceRepository>(
    () => SupabaseMarketplaceRepository(SupaFlow.client),
  );

  // Add ChatRepository
  sl.registerLazySingleton<ChatRepository>(
    () => SupabaseChatRepository(SupaFlow.client),
  );
}
```

---

## Routes

```dart
// In routes.dart
static const String marketplaceChat = '/marketplace/chat';
static const String marketplaceChatList = '/marketplace/chats';

// In nav.dart
FFRoute(
  name: 'MarketplaceChat',
  path: '/marketplace/chat/:listingId/:otherUserId',
  builder: (context, params) => ChatPage(
    listingId: params.pathParameters['listingId']!,
    otherUserId: params.pathParameters['otherUserId']!,
  ),
),
FFRoute(
  name: 'MarketplaceChatList',
  path: '/marketplace/chats',
  builder: (context, params) => const ChatListPage(),
),
```

---

## Design System Usage

### Widgets
- **LynewedButton** (send button)
- **LynewedIconButton** (send icon button)
- **LynewedTextField** (message input)
- **LynewedColors** for message bubbles
- **LynewedTextStyles** for text

### Colors
```dart
// Message bubble colors
- isMe: LynewedColors.primary (sender)
- other: LynewedColors.gray200 (receiver)
- text isMe: Colors.white
- text other: LynewedColors.textPrimary
```

### Reference
- Copy **chat pattern** from existing `lib/features/chat/` feature (reuse similar logic)

---

## Screen States

### Chat List Page

**Loading**:
```dart
Center(
  child: CircularProgressIndicator(color: LynewedColors.primary),
)
```

**Empty**:
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.chat_bubble_outline,
        size: 64,
        color: LynewedColors.gray300,
      ),
      SizedBox(height: LynewedSpacing.lg),
      Text(
        'No conversations yet',
        style: LynewedTextStyles.titleSmall.copyWith(
          color: LynewedColors.textPrimary,
        ),
      ),
      SizedBox(height: LynewedSpacing.sm),
      Text(
        'Start a conversation by contacting a seller',
        style: LynewedTextStyles.bodySmall.copyWith(
          color: LynewedColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  ),
)
```

**Error**:
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.error_outline, size: 64, color: LynewedColors.error),
      SizedBox(height: LynewedSpacing.lg),
      Text('Failed to load conversations', style: LynewedTextStyles.titleSmall),
      SizedBox(height: LynewedSpacing.sm),
      LynewedButton(
        label: 'Retry',
        variant: ButtonVariant.secondary,
        onPressed: _loadConversations,
      ),
    ],
  ),
)
```

**Data**:
- ListView of ConversationTile widgets.

### Chat Page

**Loading**:
- Show skeleton messages while loading.

**Empty**:
- Show empty message list with "Send a message to start the conversation" hint.

**Data**:
- ListView.builder with messages (reverse: true for bottom-aligned).
- ChatInputWidget at bottom.

---

## Technical Specifications

### Supabase Realtime Subscription

```dart
class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  SupabaseChatRepository(this._supabase);

  @override
  Stream<ChatMessageEntity> subscribeToMessages({
    required String listingId,
    required String currentUserId,
  }) {
    final controller = StreamController<ChatMessageEntity>();

    _channel = _supabase.channel('marketplace-chat-$listingId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'marketplace_messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'listing_id',
          value: listingId,
        ),
        callback: (payload) {
          try {
            final message = ChatMessageEntity.fromJson(payload.newRecord);
            // Only emit if message involves current user
            if (message.senderId == currentUserId || message.receiverId == currentUserId) {
              controller.add(message);
            }
          } catch (e) {
            controller.addError(e);
          }
        },
      )
      .subscribe();

    return controller.stream;
  }

  @override
  void unsubscribeAll() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
```

### Chat Page

```dart
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.listingId,
    required this.otherUserId,
  });

  final String listingId;
  final String otherUserId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  List<ChatMessageEntity> _messages = [];
  StreamSubscription<ChatMessageEntity>? _realtimeSubscription;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToNewMessages();
    _markAsRead();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await ref.read(chatRepositoryProvider).getMessages(
        listingId: widget.listingId,
        otherUserId: widget.otherUserId,
      );
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _subscribeToNewMessages() {
    final currentUserId = SupaFlow.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    _realtimeSubscription = ref
        .read(chatRepositoryProvider)
        .subscribeToMessages(
          listingId: widget.listingId,
          currentUserId: currentUserId,
        )
        .listen((newMessage) {
      if (mounted) {
        setState(() => _messages.add(newMessage));
        _scrollToBottomIfNear();
        _markAsRead();
      }
    });
  }

  void _markAsRead() {
    ref.read(chatRepositoryProvider).markConversationAsRead(
      listingId: widget.listingId,
      otherUserId: widget.otherUserId,
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomIfNear() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      // Only auto-scroll if within 100px of bottom
      if (maxScroll - currentScroll < 100) {
        _scrollToBottom();
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
        listingId: widget.listingId,
        receiverId: widget.otherUserId,
        content: content,
      );
    } catch (e) {
      // Show error toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupaFlow.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),

            // Listing preview
            ListingPreviewWidget(listingId: widget.listingId),
            const Divider(height: 1, color: LynewedColors.gray200),

            // Messages list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(LynewedSpacing.md),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message.senderId == currentUserId;
                            return ChatMessageWidget(
                              message: message,
                              isMe: isMe,
                            );
                          },
                        ),
            ),

            // Input
            ChatInputWidget(
              controller: _messageController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, LynewedSpacing.md, LynewedSpacing.md, LynewedSpacing.md),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          SizedBox(width: LynewedSpacing.sm),
          Expanded(
            child: Text(
              'Chat',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _realtimeSubscription?.cancel();
    ref.read(chatRepositoryProvider).unsubscribeAll();
    super.dispose();
  }
}
```

### Message Bubble

```dart
class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  final ChatMessageEntity message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: LynewedSpacing.md,
          vertical: LynewedSpacing.sm / 2,
        ),
        padding: EdgeInsets.all(LynewedSpacing.sm + 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? LynewedColors.primary : LynewedColors.gray200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: isMe ? Colors.white : LynewedColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: LynewedTextStyles.labelSmall.copyWith(
                color: isMe ? Colors.white70 : LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')} • ${time.day}/${time.month}';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
```

### Chat Input

```dart
class ChatInputWidget extends StatelessWidget {
  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(LynewedSpacing.md),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          top: BorderSide(color: LynewedColors.gray200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: LynewedTextField(
              controller: controller,
              hintText: 'Type a message...',
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => onSend(),
            ),
          ),
          SizedBox(width: LynewedSpacing.sm),
          LynewedIconButton(
            icon: Icons.send,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
```

### Listing Preview Widget

```dart
class ListingPreviewWidget extends StatelessWidget {
  const ListingPreviewWidget({
    super.key,
    required this.listingId,
  });

  final String listingId;

  @override
  Widget build(BuildContext context) {
    // Fetch listing data (simplified)
    return FutureBuilder<ListingEntity?>(
      future: ref.read(marketplaceRepositoryProvider).getListingById(listingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final listing = snapshot.data!;
        return InkWell(
          onTap: () => context.pushNamed(
            AppRoutes.listingDetail,
            pathParameters: {'id': listingId},
          ),
          child: Container(
            padding: EdgeInsets.all(LynewedSpacing.md),
            child: Row(
              children: [
                // Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: listing.coverPhotoUrl ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: LynewedSpacing.md),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: LynewedTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        CurrencyService.format(listing.priceCents),
                        style: LynewedTextStyles.titleSmall.copyWith(
                          color: LynewedColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(Icons.chevron_right, color: LynewedColors.gray300),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### Conversation Grouping

Conversations are grouped by `(buyer_id, seller_id, listing_id)` tuple. Each unique combination represents one conversation.

### Mark as Read

```dart
@override
Future<void> markConversationAsRead({
  required String listingId,
  required String otherUserId,
}) async {
  final currentUserId = _supabase.auth.currentUser?.id;
  if (currentUserId == null) return;

  await _supabase
    .from('marketplace_messages')
    .update({'is_read': true})
    .eq('listing_id', listingId)
    .eq('receiver_id', currentUserId)
    .eq('sender_id', otherUserId)
    .eq('is_read', false);
}
```

Call this:
- In `initState()` of ChatPage
- When a new message arrives (if chat is open)

### Unread Count Stream

```dart
@override
Stream<int> getUnreadCountStream() {
  final currentUserId = _supabase.auth.currentUser?.id;
  if (currentUserId == null) return Stream.value(0);

  return _supabase
    .from('marketplace_messages')
    .stream(primaryKey: ['id'])
    .eq('receiver_id', currentUserId)
    .eq('is_read', false)
    .map((messages) => messages.length);
}
```

Display unread count badge on chat icon in navbar.

---

## Tests Requis

### Entity Tests
```dart
// test/features/marketplace/domain/entities/chat_message_entity_test.dart

- ChatMessageEntity.fromJson parses all fields correctly
- ChatMessageEntity.toJson excludes auto-generated fields
- ChatMessageEntity.copyWith preserves unchanged fields
- ChatMessageEntity equality (==, hashCode) works correctly

// test/features/marketplace/domain/entities/conversation_entity_test.dart

- ConversationEntity.fromJson parses all fields correctly
- ConversationEntity.hasUnread returns true when unreadCount > 0
- ConversationEntity equality (==, hashCode) works correctly
```

### Repository Tests
```dart
// test/features/marketplace/data/repositories/supabase_chat_repository_test.dart

- sendMessage inserts into database with correct fields
- sendMessage returns created message with ID
- getMessages returns messages ordered by created_at asc
- getMessages filters by listingId and otherUserId correctly
- markConversationAsRead updates is_read for receiver's messages
- subscribeToMessages emits new messages via Realtime
- subscribeToMessages only emits messages involving currentUser
- getUnreadCountStream returns correct count
- unsubscribeAll cleans up Realtime channel
```

### Widget Tests
```dart
// test/features/marketplace/presentation/pages/chat_page_test.dart

- ChatPage renders messages list when data available
- ChatPage shows loading indicator on initial load
- ChatPage shows empty state when no messages
- ChatPage scrolls to bottom on new message (if near bottom)
- ChatPage does not auto-scroll if user is scrolling up
- ChatPage sends message when send button tapped
- ChatPage marks conversation as read on open
- ChatMessage displays content, timestamp, and correct colors
- ChatInputWidget enables send button only when text is not empty
```

---

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/pages/chat_page.dart` - Conversation screen
- `lib/features/marketplace/presentation/pages/chat_list_page.dart` - List of conversations
- `lib/features/marketplace/presentation/widgets/chat_message_widget.dart` - Message bubble
- `lib/features/marketplace/presentation/widgets/chat_input_widget.dart` - Message input
- `lib/features/marketplace/presentation/widgets/conversation_tile.dart` - Conversation preview
- `lib/features/marketplace/data/datasources/chat_remote_datasource.dart` - API + Realtime
- `lib/features/marketplace/data/repositories/chat_repository_impl.dart` - Repository
- `lib/features/marketplace/domain/repositories/chat_repository.dart` - Interface
- `lib/features/marketplace/domain/entities/chat_message.dart` - Entity
- `lib/features/marketplace/domain/usecases/send_message.dart` - Use case
- `lib/features/marketplace/domain/usecases/get_messages.dart` - Use case
- `lib/features/marketplace/domain/usecases/mark_as_read.dart` - Use case

### A Modifier
- `lib/features/marketplace/presentation/pages/listing_detail_page.dart` - "Contact Seller" navigation

## Notes Techniques

### Realtime Subscription
```dart
class ChatRemoteDatasource {
  RealtimeChannel? _channel;

  Stream<ChatMessageEntity> subscribeToMessages(String listingId, String currentUserId) {
    final controller = StreamController<ChatMessageEntity>();

    _channel = supabase.channel('marketplace-chat-$listingId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'marketplace_messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'listing_id',
          value: listingId,
        ),
        callback: (payload) {
          final message = ChatMessageEntity.fromJson(payload.newRecord);
          // Only emit if message involves current user
          if (message.senderId == currentUserId || message.receiverId == currentUserId) {
            controller.add(message);
          }
        },
      )
      .subscribe();

    return controller.stream;
  }

  void unsubscribe() {
    _channel?.unsubscribe();
  }
}
```

### Chat Page
```dart
class ChatPage extends ConsumerStatefulWidget {
  final String listingId;
  final String otherUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat about ${listing.title}'),
      ),
      body: Column(
        children: [
          // Listing preview at top
          ListingPreviewWidget(listing: listing),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // Most recent at bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatMessageWidget(
                  message: message,
                  isMe: message.senderId == currentUserId,
                );
              },
            ),
          ),

          // Input
          ChatInputWidget(onSend: _sendMessage),
        ],
      ),
    );
  }

  void _sendMessage(String content) async {
    await ref.read(chatRepositoryProvider).sendMessage(
      listingId: widget.listingId,
      receiverId: widget.otherUserId,
      content: content,
    );
  }
}
```

### Message Widget
```dart
class ChatMessageWidget extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : null),
            ),
            Text(
              _formatTime(message.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isMe ? Colors.white70 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Mark as Read
```dart
Future<void> markConversationAsRead(String listingId, String currentUserId) async {
  await supabase
    .from('marketplace_messages')
    .update({'is_read': true})
    .eq('listing_id', listingId)
    .eq('receiver_id', currentUserId)
    .eq('is_read', false);
}
```

### Unread Count Badge
```dart
// Provider for unread count
final unreadCountProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value(0);

  return supabase
    .from('marketplace_messages')
    .stream(primaryKey: ['id'])
    .eq('receiver_id', userId)
    .eq('is_read', false)
    .map((messages) => messages.length);
});
```

## Definition of Done
- [ ] Chat page avec messages
- [ ] Realtime subscription fonctionne
- [ ] Message input avec envoi
- [ ] Liste conversations
- [ ] Unread count badge
- [ ] Mark as read on open
- [ ] Listing preview dans chat
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible (pattern Realtime existant dans app)

## Dependances
- S05 (marketplace_messages table)

## Stories Dependantes
- S23 (notifications - new message notification)
