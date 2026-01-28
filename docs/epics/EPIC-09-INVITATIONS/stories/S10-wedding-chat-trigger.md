# Story S10: Setup trigger chat room wedding_team par defaut

## Description
En tant que systeme, je veux creer automatiquement un chat room wedding_team quand un nouveau mariage est cree, afin que la mariee et ses invites aient un espace de discussion commun.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a bride creates a new wedding When the wedding is inserted into the database Then a new chat_room should be created automatically And the chat_room.type should be 'wedding_team' And the chat_room.name should be 'Groupe du mariage' And the chat_room.wedding_id should reference the new wedding And the chat_room.is_active should be TRUE
- [ ] Given a wedding is created with bride_profile_id When the chat_room is created Then the bride should be added to chat_room_participants And the bride should have joined_at timestamp set
- [ ] Given existing weddings created before this trigger When running a backfill migration Then each wedding without a wedding_team chat should get one created And all brides should be added as participants
- [ ] Given bride A creates wedding 1 And bride B creates wedding 2 When both weddings are created Then wedding 1 should have its own chat_room And wedding 2 should have its own separate chat_room And each chat_room should reference the correct wedding_id

## Fichiers Concernes

### A Creer
- Migration Supabase: `20260128_create_wedding_chat_trigger.sql`

### A Modifier
- Aucun fichier Flutter (migration backend uniquement)

## Notes Techniques

### Migration Complete

```sql
-- Migration: 20260128_create_wedding_chat_trigger
-- Description: Automatically create wedding_team chat room when wedding is created
-- Note: Depends on chat_rooms.wedding_id column (added by EPIC-06)

-- =============================================================================
-- 1. TRIGGER FUNCTION
-- =============================================================================
CREATE OR REPLACE FUNCTION create_default_wedding_chat()
RETURNS TRIGGER AS $$
DECLARE
  v_room_id UUID;
BEGIN
  -- Create the chat room
  INSERT INTO chat_rooms (
    type,
    name,
    is_active,
    wedding_id,
    created_at,
    updated_at
  )
  VALUES (
    'wedding_team',
    'Groupe du mariage',
    TRUE,
    NEW.id,
    NOW(),
    NOW()
  )
  RETURNING id INTO v_room_id;

  -- Add bride as first participant
  INSERT INTO chat_room_participants (
    room_id,
    user_id,
    joined_at
  )
  VALUES (
    v_room_id,
    NEW.bride_profile_id,
    NOW()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_default_wedding_chat IS
  'Creates wedding_team chat room and adds bride when wedding is created';

-- =============================================================================
-- 2. CREATE TRIGGER
-- =============================================================================
DROP TRIGGER IF EXISTS trg_wedding_default_chat ON weddings;

CREATE TRIGGER trg_wedding_default_chat
  AFTER INSERT ON weddings
  FOR EACH ROW
  EXECUTE FUNCTION create_default_wedding_chat();

COMMENT ON TRIGGER trg_wedding_default_chat ON weddings IS
  'Trigger to automatically create wedding_team chat room after wedding creation';

-- =============================================================================
-- 3. BACKFILL EXISTING WEDDINGS
-- =============================================================================
-- Creates chat rooms for weddings that were created before this trigger

DO $$
DECLARE
  r RECORD;
  v_room_id UUID;
  v_count INT := 0;
BEGIN
  RAISE NOTICE 'Starting backfill of wedding_team chat rooms...';

  FOR r IN
    SELECT w.id as wedding_id, w.bride_profile_id
    FROM weddings w
    WHERE NOT EXISTS (
      SELECT 1 FROM chat_rooms cr
      WHERE cr.wedding_id = w.id AND cr.type = 'wedding_team'
    )
  LOOP
    -- Create chat room
    INSERT INTO chat_rooms (type, name, is_active, wedding_id, created_at, updated_at)
    VALUES ('wedding_team', 'Groupe du mariage', TRUE, r.wedding_id, NOW(), NOW())
    RETURNING id INTO v_room_id;

    -- Add bride as participant
    INSERT INTO chat_room_participants (room_id, user_id, joined_at)
    VALUES (v_room_id, r.bride_profile_id, NOW())
    ON CONFLICT DO NOTHING;

    v_count := v_count + 1;
  END LOOP;

  RAISE NOTICE 'Backfill complete. Created % wedding_team chat rooms.', v_count;
END $$;

-- =============================================================================
-- 4. VERIFICATION QUERY (for testing)
-- =============================================================================
-- Run this query to verify the migration:
-- SELECT w.id as wedding_id, w.bride_profile_id, cr.id as chat_room_id, cr.type
-- FROM weddings w
-- LEFT JOIN chat_rooms cr ON cr.wedding_id = w.id AND cr.type = 'wedding_team';
```

### Verification Script

```sql
-- Verification: Every wedding should have exactly one wedding_team chat room
SELECT
  COUNT(*) as total_weddings,
  COUNT(cr.id) as weddings_with_chat,
  COUNT(*) - COUNT(cr.id) as weddings_without_chat
FROM weddings w
LEFT JOIN chat_rooms cr ON cr.wedding_id = w.id AND cr.type = 'wedding_team';

-- Should return: total_weddings = weddings_with_chat, weddings_without_chat = 0
```

### Test de la Migration

```sql
-- Test 1: Create a new wedding and verify chat room is created
INSERT INTO weddings (id, bride_profile_id, /* other required fields */)
VALUES (gen_random_uuid(), 'bride-uuid', /* ... */);

-- Verify chat room exists
SELECT * FROM chat_rooms WHERE wedding_id = 'new-wedding-uuid' AND type = 'wedding_team';

-- Test 2: Verify bride is a participant
SELECT * FROM chat_room_participants crp
JOIN chat_rooms cr ON cr.id = crp.room_id
WHERE cr.type = 'wedding_team' AND crp.user_id = 'bride-uuid';
```

### Rollback (si necessaire)

```sql
-- Rollback migration
DROP TRIGGER IF EXISTS trg_wedding_default_chat ON weddings;
DROP FUNCTION IF EXISTS create_default_wedding_chat;

-- Note: This does NOT delete the created chat rooms
-- To clean up chat rooms created by backfill:
-- DELETE FROM chat_rooms WHERE type = 'wedding_team' AND created_at >= 'migration-timestamp';
```

## Definition of Done

- [ ] Criteres valides
- [ ] Migration deployee sur Supabase
- [ ] Verification query retourne 0 weddings_without_chat
- [ ] Test creation nouveau wedding → chat room cree
- [ ] Test bride ajoutee comme participant
- [ ] Backfill des mariages existants reussi
- [ ] Documentation migration ajoutee

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible (trigger SQL simple, backfill sans impact)

## Dependances

- EPIC-06 complete (colonne chat_rooms.wedding_id)

## Stories Dependantes

- S04 (guest account creation - ajoute guest au chat)
- S11 (chat integration - utilise le chat cree)

## Notes Production

### Ordre d'execution

1. Verifier que EPIC-06 est deploy (colonne wedding_id existe)
2. Deployer cette migration
3. Verifier avec la query de verification
4. Tester avec un nouveau wedding

### Impact sur les donnees existantes

- Les 8 mariages existants recevront un chat room via backfill
- Les brides seront ajoutees comme participants
- Aucune donnee existante n'est modifiee ou supprimee
- Le backfill est idempotent (peut etre execute plusieurs fois sans risque)

### Monitoring

Apres deploiement, verifier dans les logs Supabase:
- Pas d'erreur lors du backfill
- Le nombre de chat rooms crees correspond au nombre de mariages sans chat
