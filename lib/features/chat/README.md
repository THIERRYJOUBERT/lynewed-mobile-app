# Chat Module

**Version:** 2.0.0  
**Created:** 2025-12-02  
**Updated:** 2025-12-02  
**Status:** ✅ Complete (Phase 6)

## Overview

Complete chat and contact system for LYNEWED app, refactored from FlutterFlow to Clean Architecture.

## Architecture

```
lib/features/chat/
├── domain/                          # Business logic layer
│   ├── entities/
│   │   ├── chat_enums.dart          # All enums
│   │   ├── chat_message.dart        # Message entity
│   │   ├── chat_room.dart           # Room entity
│   │   ├── conversation.dart        # Conversation list item
│   │   ├── contact_request.dart     # Contact request entity
│   │   ├── chat_entry_context.dart  # Contact context result
│   │   ├── blocked_user.dart        # Blocked user entity
│   │   └── entities.dart            # Barrel export
│   └── repositories/
│       ├── chat_repository.dart     # Chat operations interface
│       ├── contact_repository.dart  # Contact operations interface
│       └── repositories.dart        # Barrel export
├── data/
│   ├── datasources/
│   │   ├── chat_remote_datasource.dart  # Supabase operations
│   │   └── datasources.dart             # Barrel export
│   └── repositories/
│       ├── chat_repository_impl.dart    # Chat implementation
│       ├── contact_repository_impl.dart # Contact implementation
│       └── repositories.dart            # Barrel export
├── presentation/
│   ├── bloc/
│   │   ├── conversations_cubit.dart     # Messages page state
│   │   ├── conversations_state.dart     # Conversations state
│   │   ├── chat_room_notifier.dart      # Chat room state
│   │   ├── chat_room_state.dart         # Room state
│   │   └── bloc.dart                    # Barrel export
│   ├── pages/
│   │   ├── messages_page.dart           # Unified messages list
│   │   ├── chat_details_page.dart       # Chat conversation
│   │   └── pages.dart                   # Barrel export
│   ├── widgets/
│   │   ├── conversation_tile.dart       # Conversation list item
│   │   ├── contact_request_avatar.dart  # Request avatar
│   │   ├── blocked_user_tile.dart       # Blocked user item
│   │   ├── message_bubble.dart          # Chat message bubble
│   │   ├── message_composer.dart        # Text/media input
│   │   ├── message_list.dart            # Scrollable messages
│   │   ├── empty_state_widget.dart      # Empty states
│   │   └── widgets.dart                 # Barrel export
│   └── sheets/
│       ├── contact_request_sheet.dart       # Pro→Bride request
│       ├── contact_request_review_sheet.dart # Bride review
│       ├── conversation_actions_sheet.dart  # Archive/actions
│       ├── message_actions_sheet.dart       # Delete/report/block
│       ├── report_user_sheet.dart           # Report user
│       └── sheets.dart                      # Barrel export
├── chat.dart                        # Module barrel export
└── README.md                        # This file
```

## Contact Flow

### Bride → Pro (Direct)
1. Bride taps "Contact" on Pro profile
2. `prepareContactContext()` returns `roomReady`
3. Navigate directly to ChatDetails
4. Conversation is active immediately

### Pro → Bride (Request)
1. Pro taps "Contact" on Bride profile/wedding
2. `prepareContactContext()` returns `requiresRequest`
3. Show `ContactRequestSheet`
4. Pro writes message and submits
5. `createContactRequest()` creates pending request
6. Toast "Demande envoyée", Pro stays on page
7. Bride receives notification
8. Bride sees request in "Demandes" section
9. Bride accepts → Room created, conversation active
10. Bride declines → No room created

### Pro → Pro (Direct)
1. Pro taps "Contact" on another Pro (from alert, profile)
2. `prepareContactContext()` returns `roomReady`
3. Navigate directly to ChatDetails
4. Conversation is active immediately

## Subscription Requirements

| Action | Required Tier |
|--------|---------------|
| Bride → Pro | Active account |
| Pro → Bride | Premium+ |
| Pro → Pro | EarlyAccess+ |

## Contact Request Sources

| Source | Context |
|--------|---------|
| `fromWishlist` | Pro contacts Bride who favorited them |
| `fromWedding` | Pro contacts Bride from visible wedding |
| `fromAlert` | Pro responds to another Pro's alert |
| `fromProfile` | Contact from profile page |

## Backend RPCs

| RPC | Description |
|-----|-------------|
| `open_or_prepare_contact_context` | Prepare contact, check permissions |
| `create_contact_request` | Create Pro→Bride request |
| `accept_connection_request` | Bride accepts, creates room |
| `decline_connection_request` | Bride declines |
| `get_pending_contact_requests` | List pending requests for Bride |
| `get_rooms_with_unread_counts` | List conversations |

## Usage

```dart
import 'package:lynewed/features/chat/chat.dart';

// Prepare contact context
final contactRepo = ContactRepositoryImpl();
final result = await contactRepo.prepareContactContext(targetId);

if (result.isSuccess) {
  final context = result.data!;
  
  if (context.requiresContactRequest) {
    // Show sheet for Pro→Bride
    ContactRequestSheet.show(
      context: context,
      targetProfileId: targetId,
      targetName: 'Marie',
      source: ContactRequestSource.fromProfile,
    );
  } else if (context.canNavigateToChat) {
    // Navigate to chat
    Navigator.pushNamed(context, '/chatDetails', arguments: {
      'roomId': context.roomId,
      'otherProfileId': context.otherProfileId,
    });
  } else if (context.hasError) {
    // Show error
    showDialog(...);
  }
}
```

## Design System

All UI components use the unified Design System:

```dart
import '/core/design/design.dart';

// Colors
LynewedColors.primary
LynewedColors.textSecondary

// Typography
LynewedTextStyles.titleSmall
LynewedTextStyles.bodyMedium

// Components
LynewedComponentStyles.primaryButton()
LynewedComponentStyles.formInputDecoration()
LynewedComponentStyles.bottomSheetDecoration()
```

## Testing

```bash
# Run tests
flutter test lib/features/chat/test/

# Run specific test
flutter test lib/features/chat/test/domain/repositories/contact_repository_test.dart
```

## Migration from FlutterFlow

| FlutterFlow | Clean Architecture |
|-------------|-------------------|
| `ChatEntryContextStruct` | `ChatEntryContext` |
| `ConversationListItemStruct` | `Conversation` |
| `ContactRequestItemStruct` | `ContactRequest` |
| `openOrPrepareContactAction` | `ContactRepository.prepareContactContext()` |
| `sendTextMessageAction` | `ChatRepository.sendTextMessage()` |

## Phases

- [x] **Phase 1**: Backend - Logique Contact
- [x] **Phase 2**: Foundation Frontend
- [x] **Phase 3**: Messages Page Unifiée
- [x] **Phase 4**: Chat Details + Realtime
- [x] **Phase 5**: Modération
- [x] **Phase 6**: Tests & Cleanup

## Features

### Messaging
- ✅ Unified messages page (Brides & Pros)
- ✅ Real-time message updates
- ✅ Text, image, and audio messages
- ✅ Message pagination (infinite scroll)
- ✅ Unread count badges
- ✅ Archive conversations

### Contact System
- ✅ Bride → Pro: Direct chat
- ✅ Pro → Bride: Request sheet with message
- ✅ Pro → Pro: Direct chat
- ✅ Contact request review (Accept/Decline)
- ✅ Real-time request notifications

### Moderation
- ✅ Report messages (spam, harassment, inappropriate, other)
- ✅ Report users from profile sheets
- ✅ Block users from chat
- ✅ Blocked users list with unblock
- ✅ Support tickets creation

### Video Calls
- ✅ Agora integration preserved
- ✅ Video call button in chat header

## Moderation Flow

### Report Message
1. Long press on message → Actions sheet
2. Select "Signaler" → Report reasons
3. Choose reason + optional details
4. Submit → Message hidden + support ticket created

### Report User
1. From Pro profile (map sheet or full page)
2. Tap flag icon → Report sheet
3. Choose reason + optional details
4. Submit → Support ticket created

### Block User
1. Long press on message → Actions sheet
2. Select "Bloquer" → Confirmation dialog
3. Confirm → User blocked, navigate back
4. Blocked users visible in "Bloqués" tab
5. Unblock available from blocked list

## Supabase Tables

| Table | Purpose |
|-------|---------|
| `chat_rooms` | Conversation rooms |
| `chat_messages` | Messages |
| `connection_requests` | Pro→Bride requests |
| `user_blocks` | Blocked users |
| `support_tickets` | Reports & support |
| `reports` | Message reports |

## Realtime Subscriptions

```dart
// ConversationsNotifier (Messages page)
- subscribeToConversationUpdates() // New messages
- subscribeToContactRequests()     // New requests

// ChatRoomNotifier (Chat details)
- subscribeToMessages(roomId)      // Room messages
```

## Related Documentation

- `docs/audits/CHAT_CONTACT_FEATURE_AUDIT.md` - Complete audit
- `docs/App/DESIGN_SYSTEM.md` - UI guidelines
- `docs/archive/chat_backup_2025-12-02/` - FlutterFlow backup
- `.windsurf/CHAT_REFACTORING_PROMPT.md` - Refactoring plan
