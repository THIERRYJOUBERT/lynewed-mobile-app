# Story S18: Chat buyer/seller

## Description
En tant qu'acheteuse, je veux contacter le vendeur directement, afin de poser des questions sur l'article avant d'acheter.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a listing detail page When buyer clicks "Contact Seller" Then chat screen should open And buyer can send message
- [ ] Given an active conversation When seller sends a message Then buyer should see it instantly (Supabase Realtime)
- [ ] Given unread messages Then chat icon should show unread count And conversation should be marked unread in list
- [ ] Given a conversation When user opens it Then messages should load in chronological order And scroll to most recent
- [ ] Given the chat list When user has multiple conversations Then they should be grouped by listing And sorted by most recent message

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
