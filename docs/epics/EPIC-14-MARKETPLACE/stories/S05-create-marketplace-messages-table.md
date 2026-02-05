# Story S05: Create marketplace_messages table

## Description
En tant que developpeur backend, je veux creer la table marketplace_messages dans Supabase, afin de permettre le chat Realtime entre acheteur et vendeur pour chaque annonce.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the marketplace_listings table exists When the migration create_marketplace_messages is applied Then table marketplace_messages should exist with columns listing_id, sender_id, receiver_id, content, is_read, created_at
- [ ] Given a message between user-A and user-B about listing-X When user-A queries Then they see the message When user-B queries Then they see the message When user-C queries Then they do not see the message (RLS)
- [ ] Given a buyer subscribed to messages for a listing When the seller sends a message Then the buyer should receive it in realtime (Supabase Realtime)
- [ ] Given messages between buyer and seller When buyer reads a message Then is_read should be updated to true
- [ ] Given a sender_id equal to receiver_id When inserting a message Then the insert should fail (constraint chk_different_users)
- [ ] Given a buyer initiating conversation about listing-X When the buyer sends first message Then receiver_id should be listing owner (seller)
- [ ] Given an existing conversation between buyer and seller When either party replies Then they can send to the other party

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260204100005_create_marketplace_messages.sql` - Migration principale
- `lib/features/marketplace/domain/entities/marketplace_message.dart` - Entity Dart
- `test/features/marketplace/domain/entities/marketplace_message_test.dart` - Tests entity

### A Modifier
- Aucun

## SQL Migration Complet

```sql
-- Migration: 20260204100005_create_marketplace_messages.sql

-- Create the marketplace_messages table
CREATE TABLE IF NOT EXISTS marketplace_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES marketplace_listings(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),

  -- Constraint: sender and receiver must be different
  CONSTRAINT chk_different_users CHECK (sender_id != receiver_id)
);

-- Create indexes
CREATE INDEX idx_marketplace_messages_listing ON marketplace_messages(listing_id, created_at DESC);
CREATE INDEX idx_marketplace_messages_sender ON marketplace_messages(sender_id, created_at DESC);
CREATE INDEX idx_marketplace_messages_receiver ON marketplace_messages(receiver_id, is_read, created_at DESC);
CREATE INDEX idx_marketplace_messages_conversation ON marketplace_messages(listing_id, sender_id, receiver_id, created_at DESC);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE marketplace_messages;

-- Enable RLS
ALTER TABLE marketplace_messages ENABLE ROW LEVEL SECURITY;

-- Grant basic access
GRANT SELECT, INSERT, UPDATE ON marketplace_messages TO authenticated;
```

## RLS Policies SQL

```sql
-- Policy 1: Message participants view
-- Users can see messages where they are sender OR receiver
CREATE POLICY "Message participants view"
ON marketplace_messages FOR SELECT
TO authenticated
USING (sender_id = auth.uid() OR receiver_id = auth.uid());

-- Policy 2: Send messages
-- Can send to listing seller OR reply to existing conversation
CREATE POLICY "Send messages"
ON marketplace_messages FOR INSERT
TO authenticated
WITH CHECK (
  sender_id = auth.uid()
  AND (
    -- Can initiate conversation with listing owner
    receiver_id IN (
      SELECT seller_id FROM marketplace_listings
      WHERE id = marketplace_messages.listing_id
    )
    OR
    -- Can reply to existing conversation (sender/receiver can swap)
    EXISTS (
      SELECT 1 FROM marketplace_messages existing
      WHERE existing.listing_id = marketplace_messages.listing_id
      AND (
        (existing.sender_id = auth.uid() AND existing.receiver_id = marketplace_messages.receiver_id)
        OR
        (existing.receiver_id = auth.uid() AND existing.sender_id = marketplace_messages.receiver_id)
      )
    )
  )
);

-- Policy 3: Mark as read
-- Receiver can update is_read to true
CREATE POLICY "Mark as read"
ON marketplace_messages FOR UPDATE
TO authenticated
USING (receiver_id = auth.uid())
WITH CHECK (receiver_id = auth.uid() AND is_read = true);
```

## Post-Migration Verification

```sql
-- 1. Verify table exists
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'marketplace_messages';

-- 2. Verify FK constraints
SELECT
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'marketplace_messages';

-- 3. Verify CHECK constraint (different users)
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = 'public'
  AND constraint_name LIKE '%marketplace_messages%';

-- 4. Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'marketplace_messages';

-- 5. Verify policies created
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'marketplace_messages';

-- 6. Verify indexes created
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'marketplace_messages';

-- 7. Verify Realtime publication
SELECT schemaname, tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND tablename = 'marketplace_messages';

-- 8. Test constraint: sender_id = receiver_id (should FAIL)
-- INSERT INTO marketplace_messages (listing_id, sender_id, receiver_id, content)
-- VALUES ('valid-listing-id', auth.uid(), auth.uid(), 'Test message');
-- Expected: ERROR: new row violates check constraint "chk_different_users"

-- 9. Test Realtime subscription (manual test in app)
-- In Flutter app:
-- final channel = supabase
--   .channel('marketplace-messages')
--   .on(RealtimeListenTypes.postgresChanges,
--       ChannelFilter(event: 'INSERT', schema: 'public', table: 'marketplace_messages'),
--       (payload, [ref]) => print('New message: $payload'))
--   .subscribe();
-- Expected: Receive new messages in real-time
```

## Realtime Verification

### Subscription Test (manual in app)

```dart
// In Flutter app - test Realtime subscription
import 'package:supabase_flutter/supabase_flutter.dart';

void testRealtimeMessages(String listingId) {
  final supabase = Supabase.instance.client;

  final channel = supabase
    .channel('marketplace-messages-$listingId')
    .on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'marketplace_messages',
        filter: 'listing_id=eq.$listingId',
      ),
      (payload, [ref]) {
        print('New message received: ${payload['new']}');
        // Expected: Payload contains new message data
      },
    )
    .subscribe();

  // To test: Send a message from another device/browser
  // and verify it appears in real-time
}
```

### is_read Logic

Question du challenger: "is_read peut-il revenir à false ?"

**Reponse**: Non. La policy RLS "Mark as read" enforce `WITH CHECK (is_read = true)`, ce qui signifie qu'on ne peut UPDATE que vers `true`. Une fois lu, un message reste lu.

Si besoin de "marquer comme non-lu" dans le futur, il faudrait :
1. Modifier la policy pour permettre `is_read = false`
2. Ajouter business logic cote app pour limiter les cas d'usage

Pour l'instant, **is_read est unidirectionnel** : false → true uniquement.

## Entity Dart

### Fichier: `lib/features/marketplace/domain/entities/marketplace_message.dart`

```dart
/// MarketplaceMessage entity - A chat message between buyer and seller
///
/// Immutable data class representing a message in marketplace conversation.
library;

import 'package:flutter/foundation.dart';

/// Represents a message in marketplace chat.
///
/// Contains sender/receiver, content, read status, and timestamps.
@immutable
class MarketplaceMessage {
  /// Creates a marketplace message.
  const MarketplaceMessage({
    required this.id,
    required this.listingId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Listing ID this conversation is about.
  final String listingId;

  /// Sender ID (who sent this message).
  final String senderId;

  /// Receiver ID (who receives this message).
  final String receiverId;

  /// Message content.
  final String content;

  /// Whether the receiver has read this message.
  final bool isRead;

  /// When the message was created.
  final DateTime createdAt;

  /// Whether this message is unread.
  bool get isUnread => !isRead;

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() => 'MarketplaceMessage(id: $id, senderId: $senderId, isRead: $isRead, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';

  /// Creates a copy with updated fields.
  MarketplaceMessage copyWith({
    String? id,
    String? listingId,
    String? senderId,
    String? receiverId,
    String? content,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return MarketplaceMessage(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### Fichier: `test/features/marketplace/domain/entities/marketplace_message_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_message.dart';

void main() {
  group('MarketplaceMessage', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create MarketplaceMessage with required fields', () {
        final now = DateTime.now();
        final message = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Hello, is this still available?',
          isRead: false,
          createdAt: now,
        );

        expect(message.id, 'message-123');
        expect(message.listingId, 'listing-456');
        expect(message.senderId, 'sender-789');
        expect(message.receiverId, 'receiver-012');
        expect(message.content, 'Hello, is this still available?');
        expect(message.isRead, isFalse);
        expect(message.createdAt, now);
      });

      test('should be immutable', () {
        final now = DateTime.now();
        final message = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Test',
          isRead: false,
          createdAt: now,
        );

        // Verify fields are final (compile-time check)
        // Cannot reassign: message.isRead = true; // Would not compile
        expect(message.isRead, isFalse);
      });
    });

    // ==============================================================
    // READ STATUS TESTS
    // ==============================================================

    group('read status', () {
      test('isUnread should be true when isRead is false', () {
        final now = DateTime.now();
        final message = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Test',
          isRead: false,
          createdAt: now,
        );

        expect(message.isUnread, isTrue);
      });

      test('isUnread should be false when isRead is true', () {
        final now = DateTime.now();
        final message = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Test',
          isRead: true,
          createdAt: now,
        );

        expect(message.isUnread, isFalse);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is the same', () {
        final now = DateTime.now();
        final message1 = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Test A',
          isRead: false,
          createdAt: now,
        );

        final message2 = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-999',
          senderId: 'sender-999',
          receiverId: 'receiver-999',
          content: 'Test B',
          isRead: true,
          createdAt: now.add(const Duration(days: 1)),
        );

        expect(message1, equals(message2));
        expect(message1.hashCode, equals(message2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime.now();
        final message1 = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Test',
          isRead: false,
          createdAt: now,
        );

        final message2 = MarketplaceMessage(
          id: 'message-999',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Test',
          isRead: false,
          createdAt: now,
        );

        expect(message1, isNot(equals(message2)));
        expect(message1.hashCode, isNot(equals(message2.hashCode)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated isRead', () {
        final now = DateTime.now();
        final message = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Test',
          isRead: false,
          createdAt: now,
        );

        final updated = message.copyWith(isRead: true);

        expect(updated.isRead, isTrue);
        expect(updated.id, message.id);
        expect(updated.content, message.content);
      });

      test('should preserve all fields when no parameter provided', () {
        final now = DateTime.now();
        final message = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Test',
          isRead: false,
          createdAt: now,
        );

        final copied = message.copyWith();

        expect(copied.id, message.id);
        expect(copied.isRead, message.isRead);
        expect(copied.content, message.content);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should provide readable string representation', () {
        final now = DateTime.now();
        final message = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: 'Hello, is this still available?',
          isRead: false,
          createdAt: now,
        );

        final str = message.toString();

        expect(str, contains('message-123'));
        expect(str, contains('sender-789'));
        expect(str, contains('false'));
        expect(str, contains('Hello'));
      });

      test('should truncate long content in toString', () {
        final now = DateTime.now();
        final longContent = 'A' * 100;
        final message = MarketplaceMessage(
          id: 'message-123',
          listingId: 'listing-456',
          senderId: 'sender-789',
          receiverId: 'receiver-012',
          content: longContent,
          isRead: false,
          createdAt: now,
        );

        final str = message.toString();

        // Should truncate to ~20 chars
        expect(str.length, lessThan(200));
        expect(str, contains('...'));
      });
    });
  });
}
```

## Tests Requis

### Tests base de donnees (via migration verification):
- Test 1: FK constraints enforced (invalid listing_id, sender_id, receiver_id should fail)
- Test 2: CHECK constraint sender_id != receiver_id enforced
- Test 3: RLS policy - participants view (sender and receiver can see)
- Test 4: RLS policy - non-participants cannot see
- Test 5: RLS policy - buyer can initiate conversation with listing seller
- Test 6: RLS policy - parties can reply to existing conversation
- Test 7: RLS policy - receiver can mark as read (is_read = true)
- Test 8: RLS policy - cannot mark as unread (is_read = false blocked)
- Test 9: Realtime subscription receives new messages

### Tests entity Dart:
- Test 1: Create message with required fields
- Test 2: Immutability verification
- Test 3: isUnread helper when isRead is false
- Test 4: isUnread helper when isRead is true
- Test 5: Equality based on id
- Test 6: CopyWith updates isRead
- Test 7: ToString contains key fields
- Test 8: ToString truncates long content

## Definition of Done
- [ ] Migration appliquee avec succes sur Supabase (MCP apply_migration)
- [ ] Post-migration verification complete (FK, CHECK, RLS, Realtime)
- [ ] Realtime publication active (ALTER PUBLICATION executed)
- [ ] 4 indexes crees
- [ ] 3 RLS policies actives
- [ ] Realtime tested manually in Flutter app (subscription receives messages)
- [ ] Entity Dart creee avec isUnread helper
- [ ] Tests entity Dart passes (8 test groups, ~15 tests)
- [ ] `flutter analyze --fatal-infos` passe (0 warnings)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances

### Requires (BLOQUANTS):
- S01: `marketplace_listings` table doit exister (FK listing_id)
- Database: `profiles` table doit exister (FK sender_id, receiver_id)

### Order:
- S01 (marketplace_listings) → **S05 (marketplace_messages)**

## Stories Dependantes (BLOQUEES si S05 incomplete)
- S18 (chat buyer/seller frontend) - utilise entity MarketplaceMessage + Realtime subscription
