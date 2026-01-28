# Story S05: Add Invitation Columns to wedding_guests Table

## Description
En tant que **systeme**, je veux **ajouter les colonnes user_id, invited_at, joined_at, et status a la table wedding_guests**, afin de **permettre le suivi complet du cycle de vie des invitations (pending -> invited -> joined/declined)**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the wedding_guests table exists When the migration add_guest_invitation_columns is applied Then wedding_guests should have column user_id of type UUID referencing profiles(id) And user_id should allow NULL (guest may not have account yet)
- [ ] Given the wedding_guests table exists When the migration add_guest_invitation_columns is applied Then wedding_guests should have columns invited_at and joined_at of type TIMESTAMP And wedding_guests should have column status of type VARCHAR(20) defaulting to 'pending'
- [ ] Given the status column exists When inserting a guest with status 'invalid_status' Then the insert should fail with constraint violation And only 'pending', 'invited', 'joined', 'declined' should be allowed
- [ ] Given a guest with status 'pending' When the bride sends an invitation Then status should change to 'invited' And invited_at should be set to current timestamp
- [ ] Given a guest with status 'invited' When the guest joins the wedding Then status should change to 'joined' And joined_at should be set And user_id should be linked to the guest's profile

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128000005_add_guest_invitation_columns.sql`

### A Modifier
- `lib/features/my_wedding/data/models/wedding_guest_model.dart` - Add new fields (optional for this story)

## Notes Techniques

**Migration SQL:**
```sql
-- Add user_id column (links to profiles when guest creates account)
ALTER TABLE wedding_guests
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES profiles(id);

-- Add invitation tracking columns
ALTER TABLE wedding_guests
  ADD COLUMN IF NOT EXISTS invited_at TIMESTAMP;

ALTER TABLE wedding_guests
  ADD COLUMN IF NOT EXISTS joined_at TIMESTAMP;

-- Add status column with constraint
ALTER TABLE wedding_guests
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'pending';

-- Add check constraint for valid status values
ALTER TABLE wedding_guests
  ADD CONSTRAINT chk_guest_status
  CHECK (status IN ('pending', 'invited', 'joined', 'declined'));

-- Create index for common queries (guests by wedding and status)
CREATE INDEX IF NOT EXISTS idx_wedding_guests_wedding_status
  ON wedding_guests(wedding_id, status);

-- Create index for finding guest by user_id
CREATE INDEX IF NOT EXISTS idx_wedding_guests_user_id
  ON wedding_guests(user_id)
  WHERE user_id IS NOT NULL;
```

**Rollback SQL:**
```sql
DROP INDEX IF EXISTS idx_wedding_guests_user_id;
DROP INDEX IF EXISTS idx_wedding_guests_wedding_status;
ALTER TABLE wedding_guests DROP CONSTRAINT IF EXISTS chk_guest_status;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS status;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS joined_at;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS invited_at;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS user_id;
```

**Cycle de vie Guest:**
```
pending -> invited -> joined
               \
                -> declined
```

**Status values:**
- `pending`: Guest ajoute a la liste, pas encore invite
- `invited`: Invitation envoyee (email/SMS)
- `joined`: Guest a rejoint via le code d'invitation
- `declined`: Guest a decline l'invitation

## Definition of Done

- [ ] Migration SQL appliquee avec succes
- [ ] Colonne user_id existe avec FK vers profiles
- [ ] Colonnes invited_at et joined_at existent
- [ ] Colonne status existe avec DEFAULT 'pending'
- [ ] Contrainte chk_guest_status fonctionne (test INSERT avec status invalide echoue)
- [ ] Index idx_wedding_guests_wedding_status cree
- [ ] Index idx_wedding_guests_user_id cree
- [ ] Guests existants ont status = 'pending' par defaut
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible (ajout de colonnes nullable + constraint)

## Dependances

- S01: Add 'guest' to userRole enum (pour coherence du flow guest)

## Stories Dependantes

- Aucune directement (sera utilisee par APP-03)
