# Story S11: Integrer guest dans systeme chat existant

## Description
En tant que guest, je veux pouvoir utiliser le chat wedding_team avec le systeme de chat existant, afin de communiquer avec la mariee et les autres invites en temps reel.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the guest has joined the wedding And was added to chat_room_participants When the guest opens the Chat tab Then the wedding_team chat room should be displayed And all previous messages should be visible And participant avatars should show other guests and bride
- [ ] Given the guest is in the wedding_team chat When the guest types "Bonjour tout le monde !" and sends Then the message should appear in the chat immediately And other participants should receive the message in real-time
- [ ] Given the guest has the chat open When the bride sends a message "Bienvenue Pierre !" Then the message should appear in the guest's chat within 1 second And a notification sound should play (if enabled)
- [ ] Given the guest is in the wedding_team chat When the guest taps the image button and selects a photo Then the image should be uploaded And the image message should appear in the chat
- [ ] Given the guest opens the chat When ChatRemoteDatasource is used Then the same Supabase Realtime subscription should be used as for other users
- [ ] Given the wedding has Marie (Bride), Pierre (Guest), Sophie (Guest) When viewing the chat info Then all 3 participants should be listed And their avatars should be displayed
- [ ] Given the guest is on the Chat tab Then there should be no "New chat" button And only the wedding_team chat should be accessible
- [ ] Given the guest has unread messages in the chat When viewing the bottom navigation Then the Chat tab should show an unread badge

## Fichiers Concernes

### A Creer
- Migration Supabase: `20260128_guest_chat_rls_policies.sql`

### A Modifier
- `lib/features/guest/presentation/pages/guest_chat_page.dart`
- `lib/features/chat/data/datasources/chat_remote_datasource.dart` (verifier compatibilite guest)
- `lib/features/guest/presentation/widgets/guest_nav_bar.dart` (badge unread)

## Notes Techniques

### RLS Policies pour Guests

```sql
-- Migration: 20260128_guest_chat_rls_policies
-- Description: Add RLS policies for guests to access wedding_team chat

-- =============================================================================
-- 1. CHAT ROOMS ACCESS FOR GUESTS
-- =============================================================================

-- Drop existing policy if it exists (to avoid conflicts)
DROP POLICY IF EXISTS "Guest can access wedding_team chat" ON chat_rooms;

-- Allow guests to read their wedding_team chat room
CREATE POLICY "Guest can access wedding_team chat" ON chat_rooms
FOR SELECT USING (
  type = 'wedding_team' AND
  EXISTS (
    SELECT 1 FROM wedding_guests wg
    WHERE wg.wedding_id = chat_rooms.wedding_id
    AND wg.user_id = auth.uid()
    AND wg.status = 'joined'
  )
);

-- =============================================================================
-- 2. CHAT MESSAGES READ ACCESS FOR GUESTS
-- =============================================================================

DROP POLICY IF EXISTS "Guest can read wedding_team messages" ON chat_messages;

CREATE POLICY "Guest can read wedding_team messages" ON chat_messages
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM chat_rooms cr
    JOIN wedding_guests wg ON wg.wedding_id = cr.wedding_id
    WHERE cr.id = chat_messages.room_id
    AND cr.type = 'wedding_team'
    AND wg.user_id = auth.uid()
    AND wg.status = 'joined'
  )
);

-- =============================================================================
-- 3. CHAT MESSAGES WRITE ACCESS FOR GUESTS
-- =============================================================================

DROP POLICY IF EXISTS "Guest can send wedding_team messages" ON chat_messages;

CREATE POLICY "Guest can send wedding_team messages" ON chat_messages
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM chat_rooms cr
    JOIN wedding_guests wg ON wg.wedding_id = cr.wedding_id
    WHERE cr.id = chat_messages.room_id
    AND cr.type = 'wedding_team'
    AND wg.user_id = auth.uid()
    AND wg.status = 'joined'
  )
);

-- =============================================================================
-- 4. CHAT ROOM PARTICIPANTS ACCESS FOR GUESTS
-- =============================================================================

DROP POLICY IF EXISTS "Guest can read wedding_team participants" ON chat_room_participants;

CREATE POLICY "Guest can read wedding_team participants" ON chat_room_participants
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM chat_rooms cr
    JOIN wedding_guests wg ON wg.wedding_id = cr.wedding_id
    WHERE cr.id = chat_room_participants.room_id
    AND cr.type = 'wedding_team'
    AND wg.user_id = auth.uid()
    AND wg.status = 'joined'
  )
);

-- =============================================================================
-- 5. VERIFICATION QUERIES
-- =============================================================================
-- Test: Guest should be able to read wedding_team chat
-- SET LOCAL ROLE authenticated;
-- SET LOCAL request.jwt.claim.sub TO 'guest-user-id';
-- SELECT * FROM chat_rooms WHERE type = 'wedding_team';
-- SELECT * FROM chat_messages WHERE room_id IN (SELECT id FROM chat_rooms WHERE type = 'wedding_team');
```

### Guest Chat Page (wrapper around existing chat)

```dart
// lib/features/guest/presentation/pages/guest_chat_page.dart
class GuestChatPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guestInfo = ref.watch(guestWeddingInfoProvider);
    final chatRoom = ref.watch(weddingTeamChatRoomProvider(guestInfo.weddingId));

    return chatRoom.when(
      data: (room) {
        if (room == null) {
          return const Center(
            child: Text('Chat non disponible'),
          );
        }

        // Reuse existing ChatPage with restricted features
        return ChatRoomView(
          roomId: room.id,
          roomName: 'Groupe du mariage',
          showCreateButton: false, // Guests cannot create new chats
          showParticipantsList: true,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(
                weddingTeamChatRoomProvider(guestInfo.weddingId),
              ),
              child: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// Provider to get wedding_team chat room
final weddingTeamChatRoomProvider = FutureProvider.family<ChatRoom?, String>(
  (ref, weddingId) async {
    final datasource = ref.read(chatRemoteDatasourceProvider);
    return datasource.getWeddingTeamChatRoom(weddingId);
  },
);
```

### ChatRemoteDatasource Extension

```dart
// Dans chat_remote_datasource.dart - ajouter methode
/// Get the wedding_team chat room for a wedding
Future<ChatRoom?> getWeddingTeamChatRoom(String weddingId) async {
  final response = await _supabase
      .from('chat_rooms')
      .select()
      .eq('wedding_id', weddingId)
      .eq('type', 'wedding_team')
      .maybeSingle();

  if (response == null) return null;
  return ChatRoom.fromJson(response);
}
```

### Unread Badge on Nav Bar

```dart
// Dans guest_nav_bar.dart - ajouter badge
class GuestNavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadMessagesCountProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined),
          activeIcon: Icon(Icons.photo_library),
          label: 'Album',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(unreadCount.toString()),
            child: const Icon(Icons.chat_bubble_outline),
          ),
          activeIcon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(unreadCount.toString()),
            child: const Icon(Icons.chat_bubble),
          ),
          label: 'Chat',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

// Provider for unread messages count
final unreadMessagesCountProvider = StreamProvider<int>((ref) {
  final guestInfo = ref.watch(guestWeddingInfoProvider);
  final datasource = ref.read(chatRemoteDatasourceProvider);

  return datasource.getUnreadCountStream(guestInfo.weddingId);
});
```

### Realtime Subscription (verification)

Le ChatRemoteDatasource existant utilise deja Supabase Realtime pour les messages.
Verifier que la subscription fonctionne pour les guests:

```dart
// Verification que le guest peut recevoir les messages en temps reel
// Le code existant devrait fonctionner si les RLS policies sont correctes

// Dans chat_remote_datasource.dart
Stream<List<ChatMessage>> watchMessages(String roomId) {
  return _supabase
      .from('chat_messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', roomId)
      .order('created_at', ascending: true)
      .map((data) => data.map((e) => ChatMessage.fromJson(e)).toList());
}
```

## Definition of Done

- [ ] Criteres valides
- [ ] Migration RLS deployee sur Supabase
- [ ] Tests manuels (guest peut lire et envoyer messages)
- [ ] Tests Realtime (messages recu en temps reel)
- [ ] Tests unitaires (weddingTeamChatRoomProvider)
- [ ] Tests widget (GuestChatPage, badge unread)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Chat fonctionne identiquement au chat existant pour brides

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (RLS policies, Realtime)

## Dependances

- S04 (guest account creation - guest est ajoute au chat)
- S05 (guest navigation - tab Chat existe)
- S10 (trigger chat room - le chat room existe)
- Systeme chat existant fonctionnel

## Stories Dependantes

- Aucune (integration finale du chat pour guests)

## Notes sur le Chat Existant

### Architecture actuelle (a verifier)

```
lib/features/chat/
├── data/
│   ├── datasources/
│   │   └── chat_remote_datasource.dart
│   └── repositories/
│       └── chat_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── chat_room.dart
│   │   └── chat_message.dart
│   └── repositories/
│       └── chat_repository.dart
└── presentation/
    ├── pages/
    │   └── chat_page.dart
    └── widgets/
        ├── chat_room_view.dart
        └── message_bubble.dart
```

### Points d'integration

1. **GuestChatPage** : Wrapper simple autour de `ChatRoomView`
2. **No new chat** : Desactiver le bouton de creation de chat pour guests
3. **RLS** : Les policies permettent l'acces uniquement au wedding_team chat
4. **Realtime** : Utilise le meme systeme que les autres utilisateurs
