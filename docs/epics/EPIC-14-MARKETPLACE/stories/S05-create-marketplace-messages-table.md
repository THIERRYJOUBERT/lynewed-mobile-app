# Story S05: Create marketplace_messages table

## Description
En tant que developpeur backend, je veux creer la table marketplace_messages dans Supabase, afin de permettre le chat Realtime entre acheteur et vendeur pour chaque annonce.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the marketplace_listings table exists When the migration create_marketplace_messages is applied Then table marketplace_messages should exist with columns listing_id, sender_id, receiver_id, content, is_read, created_at
- [ ] Given a message between user-A and user-B about listing-X When user-A queries Then they see the message When user-B queries Then they see the message When user-C queries Then they do not see the message (RLS)
- [ ] Given a buyer subscribed to messages for a listing When the seller sends a message Then the buyer should receive it in realtime (Supabase Realtime)
- [ ] Given messages between buyer and seller When buyer reads a message Then is_read should be updated to true
- [ ] Given a sender_id equal to receiver_id When inserting a message Then the insert should fail (constraint chk_different_users)

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128100005_create_marketplace_messages.sql` - Migration principale
- `supabase/migrations/20260128100005_create_marketplace_messages_rollback.sql` - Rollback migration

### A Modifier
- Aucun

## Notes Techniques

### Schema SQL
```sql
CREATE TABLE marketplace_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES marketplace_listings(id) NOT NULL,
  sender_id UUID REFERENCES profiles(id) NOT NULL,
  receiver_id UUID REFERENCES profiles(id) NOT NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

  CONSTRAINT chk_different_users CHECK (sender_id != receiver_id)
);
```

### Indexes
```sql
CREATE INDEX idx_marketplace_messages_listing ON marketplace_messages(listing_id, created_at DESC);
CREATE INDEX idx_marketplace_messages_sender ON marketplace_messages(sender_id, created_at DESC);
CREATE INDEX idx_marketplace_messages_receiver ON marketplace_messages(receiver_id, is_read, created_at DESC);
```

### Realtime
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE marketplace_messages;
```

### RLS Policies (3 policies)
1. Message participants view - sender_id OR receiver_id = auth.uid()
2. Send messages - Can send to listing seller OR reply to existing conversation
3. Mark as read - receiver can update is_read to true

## Definition of Done
- [ ] Migration appliquee avec succes
- [ ] Realtime active sur la table
- [ ] RLS policies testees
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S01 (marketplace_listings table)

## Stories Dependantes
- S18 (chat buyer/seller frontend)
