# Chat Module - Phase 4: Chat Details + Realtime Specification

**Date:** 2025-12-02  
**Phase:** 4 of 6  
**Estimation:** 12-16 hours  
**Status:** 🚧 Pending

---

## 📋 Overview

Phase 4 implements the ChatDetails page with complete realtime functionality using ChangeNotifier for state management. This ensures:

1. **MessagesPage** receives live updates for new messages and contact requests
2. **ChatDetails** displays messages in real-time as they arrive
3. All state managed via ChangeNotifier (no external dependencies)

---

## 🎯 Objectives

- [ ] Create `ChatRoomNotifier` for ChatDetails state management
- [ ] Implement `MessageList` widget with pagination
- [ ] Implement `MessageBubble` widget for message display
- [ ] Implement `MessageComposer` widget for message input
- [ ] Create `chat_details_page.dart` main page
- [ ] Add Realtime subscriptions to MessagesPage
- [ ] Add Realtime subscriptions to ChatDetails
- [ ] Preserve Agora video call functionality
- [ ] Apply Design System 100%
- [ ] Test all realtime scenarios

---

## 🔄 Realtime Architecture

### MessagesPage Realtime (ConversationsNotifier)

```dart
class ConversationsNotifier extends ChangeNotifier {
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _requestsSubscription;
  
  void _setupRealtimeListeners() {
    // Listen to new messages across all rooms
    _messagesSubscription = _chatRepository
        .subscribeToConversationUpdates()
        .listen((message) {
          // Refresh conversations list
          refresh();
        });
    
    // Listen to new contact requests
    _requestsSubscription = _contactRepository
        .subscribeToContactRequests()
        .listen((request) {
          // Add to pending requests
          if (state is ConversationsLoaded) {
            final loaded = state as ConversationsLoaded;
            final updated = [...loaded.pendingRequests, request];
            _emit(loaded.copyWith(pendingRequests: updated));
          }
        });
  }
  
  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _requestsSubscription?.cancel();
    super.dispose();
  }
}
```

### ChatDetails Realtime (ChatRoomNotifier)

```dart
class ChatRoomNotifier extends ChangeNotifier {
  StreamSubscription? _messagesSubscription;
  
  void _setupRealtimeMessages(String roomId) {
    _messagesSubscription = _chatRepository
        .subscribeToMessages(roomId)
        .listen((message) {
          // Add new message to list
          if (state is ChatRoomLoaded) {
            final loaded = state as ChatRoomLoaded;
            final updated = [message, ...loaded.messages];
            _emit(loaded.copyWith(messages: updated));
          }
        });
  }
  
  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
```

---

## 📁 Files to Create

### State Management
- `presentation/bloc/chat_room_state.dart` - States for ChatDetails
- `presentation/bloc/chat_room_notifier.dart` - ChatRoomNotifier (ChangeNotifier)
- `presentation/bloc/bloc.dart` - Update barrel export

### Widgets
- `presentation/widgets/message_bubble.dart` - Single message display
- `presentation/widgets/message_list.dart` - Messages list with pagination
- `presentation/widgets/message_composer.dart` - Message input composer
- `presentation/widgets/widgets.dart` - Update barrel export

### Pages
- `presentation/pages/chat_details_page.dart` - Main ChatDetails page
- `presentation/pages/pages.dart` - Update barrel export

### Total: 9 new files

---

## 🔌 Datasource Methods Required

Already implemented in `ChatRemoteDatasource`:

```dart
// Already exists
Stream<ChatMessage> subscribeToMessages(String roomId)

// Need to add
Stream<List<Conversation>> subscribeToConversationUpdates()
Stream<ContactRequest> subscribeToContactRequests()
```

---

## 🎨 UI Components

### MessageBubble
- Display message content (text/image/audio)
- Show sender avatar and name
- Show timestamp
- Long-press actions (delete, report)
- Different styling for own vs other messages

### MessageList
- Infinite scroll pagination (load older messages)
- Realtime new messages appear at top
- Loading indicator while fetching
- Empty state
- Error handling

### MessageComposer
- Text input with character counter
- Image picker button
- Audio recorder button
- Send button
- Preview selected media
- Disable if room is archived/blocked

### ChatDetailsPage
- Header with other profile info
- Message list
- Message composer
- Video call button (Agora)
- Contact request mode (Accept/Decline buttons if pending)

---

## 🔄 Message Flow

### Sending a Message
```
User types → MessageComposer → Send button
  ↓
ChatRoomNotifier.sendMessage()
  ↓
ChatRemoteDatasource.sendMessage()
  ↓
Insert into chat_messages table
  ↓
Trigger: trg_outbox_chat_msg (notification)
  ↓
Realtime: subscribeToMessages() fires
  ↓
ChatRoomNotifier receives new message
  ↓
notifyListeners() → MessageList rebuilds
  ↓
Message appears in UI
```

### Receiving a Message
```
Other user sends message
  ↓
Insert into chat_messages table
  ↓
Realtime: subscribeToMessages() fires
  ↓
ChatRoomNotifier receives new message
  ↓
notifyListeners() → MessageList rebuilds
  ↓
Message appears in UI
```

### MessagesPage Update
```
New message in any room
  ↓
Realtime: subscribeToConversationUpdates() fires
  ↓
ConversationsNotifier.refresh()
  ↓
notifyListeners() → MessagesPage rebuilds
  ↓
Conversation list updated with new last message
```

---

## ⚠️ Error Handling

- Connection lost → Show error banner
- Message send failed → Show retry button
- Realtime subscription error → Auto-reconnect
- Invalid room → Show error page

---

## 🎬 Contact Request Mode

When opening ChatDetails with a pending contact request:

```dart
if (context.viewerIsReviewer) {
  // Show Accept/Decline buttons
  // Display initial_message from request
  // On Accept: acceptContactRequest() → room becomes active
  // On Decline: declineContactRequest() → close chat
}
```

---

## 🎥 Agora Video Integration

**Preserve existing functionality:**
- Video call button in ChatDetails header
- Existing `agora_engine_manager.dart`
- Existing `video_call_page_widget.dart`
- No changes to video logic

---

## ✅ Checklist

### Implementation
- [ ] ChatRoomNotifier with realtime
- [ ] ConversationsNotifier with realtime
- [ ] MessageBubble widget
- [ ] MessageList widget
- [ ] MessageComposer widget
- [ ] ChatDetailsPage
- [ ] Realtime subscriptions setup
- [ ] Error handling
- [ ] Contact request mode
- [ ] Design System applied

### Testing
- [ ] Send message → appears in UI
- [ ] Receive message → appears in UI
- [ ] New contact request → appears in MessagesPage
- [ ] Pagination works
- [ ] Error handling works
- [ ] Agora button works
- [ ] Accept/Decline buttons work
- [ ] Archive conversation works

### Code Quality
- [ ] No compilation errors
- [ ] No lint warnings
- [ ] Proper stream disposal
- [ ] Memory leak free
- [ ] Proper error messages

---

## 📊 Realtime Scenarios

| Scenario | Expected Behavior |
|----------|-------------------|
| Pro sends message to Bride | Message appears in Pro's ChatDetails + Bride's MessagesPage + Bride's ChatDetails |
| Bride sends message to Pro | Message appears in Bride's ChatDetails + Pro's MessagesPage + Pro's ChatDetails |
| Pro sends contact request | Request appears in Bride's MessagesPage immediately |
| Bride accepts request | Room becomes active + appears in both MessagesPage |
| Bride declines request | Request disappears + Pro notified |
| User blocks another | Conversation hidden + blocked list updated |
| Message deleted | Message removed from list |

---

## 🚀 Next Steps

After Phase 4:
- Phase 5: Moderation (report, block UI improvements)
- Phase 6: Tests & Cleanup

---

## 📝 Notes

- Use ChangeNotifier for all state management (no external dependencies)
- Each notifier manages its own subscriptions
- Proper disposal in dispose() method
- Test realtime with multiple devices/tabs
- Monitor performance with many messages
