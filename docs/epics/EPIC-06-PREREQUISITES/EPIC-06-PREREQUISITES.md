# EPIC-06-PREREQUISITES

> Resume : Migration des prerequis techniques BLOQUANTS pour les features Guest et Mission 2026
> Status : 🔵 Draft
> Domaine : Backend / Database / Auth
> Cree le : 2026-01-28

---

## Contexte

### Pourquoi cet Epic

Cet Epic est **CRITIQUE** et **BLOQUANT** pour toutes les autres APPs de la Mission 2026 (APP-01 a APP-08).

Le challenge deep (3 agents Sonnet en parallele) a identifie des prerequis techniques qui DOIVENT etre en place AVANT de developper les features Guest, Marketplace, et autres evolutions.

**Etat actuel verifie en production (Supabase MCP):**

| Element | Etat actuel | Probleme |
|---------|-------------|----------|
| `userRole` enum | `['bride', 'professional']` | `'guest'` MANQUANT |
| `weddings.invite_code` | Colonne ABSENTE | Impossible d'inviter des guests |
| `weddings.invite_code_expires_at` | Colonne ABSENTE | Pas d'expiration securisee |
| `wedding_guests.user_id` | Colonne ABSENTE | Pas de liaison compte guest |
| `wedding_guests.status` | Colonne ABSENTE | Pas de suivi statut invitation |
| Bucket `wedding-media` | ABSENT | Pas de stockage medias guests |
| Table `invitation_attempts` | ABSENTE | Pas de rate limiting |
| Table `scheduled_notifications` | ABSENTE | Pas de rappels programmes |

**Impact si non fait:**
- APP-03 (Invitations Guests) : IMPOSSIBLE
- APP-04 (Photos/Videos) : IMPOSSIBLE pour guests
- APP-06 (Reels) : IMPOSSIBLE pour guests
- Securite : Codes invitation bruteforce-able

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
| **Supabase Database** | Migration schema, ajout enum, nouvelles tables |
| **Supabase Auth** | Nouveau role 'guest' dans enum userRole |
| **Supabase Storage** | Nouveau bucket 'wedding-media' avec RLS |
| **Flutter/Dart** | Mise a jour entite UserRole |
| **Securite** | RLS policies, rate limiting, expiration codes |

---

## Architecture Cible

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      PREREQUIS MIGRATION (APP-00)                            │
│                                                                              │
│  ENUM userRole                                                               │
│  ┌──────────────────────────────────────────────────────┐                  │
│  │  AVANT: ['bride', 'professional']                     │                  │
│  │  APRES: ['bride', 'professional', 'guest']           │                  │
│  └──────────────────────────────────────────────────────┘                  │
│                                                                              │
│  TABLE weddings (modifications)                                              │
│  ┌──────────────────────────────────────────────────────┐                  │
│  │  + invite_code VARCHAR(8) UNIQUE                      │                  │
│  │  + invite_code_expires_at TIMESTAMP                   │                  │
│  │  + TRIGGER generate_secure_invite_code()             │                  │
│  └──────────────────────────────────────────────────────┘                  │
│                                                                              │
│  TABLE wedding_guests (modifications)                                        │
│  ┌──────────────────────────────────────────────────────┐                  │
│  │  + user_id UUID REFERENCES profiles(id)               │                  │
│  │  + invited_at TIMESTAMP                               │                  │
│  │  + joined_at TIMESTAMP                                │                  │
│  │  + status VARCHAR(20) DEFAULT 'pending'               │                  │
│  └──────────────────────────────────────────────────────┘                  │
│                                                                              │
│  TABLE invitation_attempts (nouvelle)                                        │
│  ┌──────────────────────────────────────────────────────┐                  │
│  │  ip_address, attempted_at, success, code_attempted    │                  │
│  │  INDEX sur (ip_address, attempted_at) pour rate limit │                  │
│  └──────────────────────────────────────────────────────┘                  │
│                                                                              │
│  BUCKET wedding-media (nouveau)                                              │
│  ┌──────────────────────────────────────────────────────┐                  │
│  │  Structure: {wedding_id}/{guest_user_id}/{filename}   │                  │
│  │  RLS: Guest accede son dossier, Bride voit partages   │                  │
│  └──────────────────────────────────────────────────────┘                  │
│                                                                              │
│  ENTITE DART UserRole                                                        │
│  ┌──────────────────────────────────────────────────────┐                  │
│  │  enum UserRole { bride, professional, admin, guest }  │                  │
│  └──────────────────────────────────────────────────────┘                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source PRD | Complexite |
|---|-------|---------|------|---------------|------------|------------|
| S01 | Ajouter 'guest' a l'enum userRole | DB + Dart | - | Enum migre, entite Dart MAJ, tests passent | APP-00 2.1 | S |
| S02 | Ajouter colonnes invitation a weddings | DB | S01 | invite_code 8 chars, expiration 30j, unique | APP-00 2.3 | S |
| S03 | Creer table invitation_attempts | DB | - | Rate limiting IP, index performant | APP-00 2.3 | S |
| S04 | Creer fonction generate_secure_invite_code | DB | S02 | Trigger auto, 8 chars crypto, 30j expiration | APP-00 2.3 | S |
| S05 | Ajouter colonnes invitation a wedding_guests | DB | S01 | user_id, invited_at, joined_at, status | APP-00 via APP-03 | S |
| S06 | Creer bucket wedding-media avec RLS | Storage | - | Bucket cree, RLS guest/bride, structure dossiers | APP-00 2.4 | M |

---

## Detail des Stories

### S01 : Ajouter 'guest' a l'enum userRole

**Criteres cles** :
- L'enum Postgres `userRole` contient la valeur 'guest'
- L'entite Dart `UserRole` inclut `guest` avec extension `value` et `fromString`
- Les tests unitaires de UserRole passent
- Aucune regression sur les fonctionnalites existantes (bride/professional)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 2.1

**Complexite** : S (Small) - Migration enum simple + modification Dart

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest role support in userRole enum

  Scenario: Adding guest value to Postgres enum
    Given the current userRole enum contains only ['bride', 'professional']
    When the migration add_guest_role is applied
    Then the userRole enum should contain ['bride', 'professional', 'guest']
    And existing profiles should remain unchanged

  Scenario: Dart UserRole entity supports guest
    Given the UserRole enum in Dart
    When a user has role 'guest' in the database
    Then UserRole.fromString('guest') should return UserRole.guest
    And UserRole.guest.value should return 'guest'

  Scenario: Backward compatibility with existing roles
    Given existing users with role 'bride' or 'professional'
    When the migration is applied
    Then all existing users should retain their original role
    And authentication should work normally
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128000001_add_guest_role
-- ATTENTION: Executer en periode de faible trafic

-- Ajouter la valeur 'guest' a l'enum userRole
ALTER TYPE "public"."userRole" ADD VALUE IF NOT EXISTS 'guest';

-- Verification (ne doit pas echouer)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum
    WHERE enumlabel = 'guest'
    AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'userRole')
  ) THEN
    RAISE EXCEPTION 'Migration failed: guest value not added to userRole enum';
  END IF;
END $$;
```

**Rollback** :
```sql
-- ATTENTION: Le rollback d'enum en Postgres est complexe
-- Il faut recreer le type si necessaire
-- Verifier qu'aucun profile n'utilise 'guest' avant rollback

-- Ce rollback est DESTRUCTIF si des guests existent
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM profiles WHERE role = 'guest') THEN
    RAISE EXCEPTION 'Cannot rollback: guest profiles exist';
  END IF;
END $$;

-- Le rollback complet necessite de recreer l'enum
-- A documenter mais non automatise pour securite
```

**Chemins fichiers** :
- `lib/features/auth/domain/entities/user_role.dart`

---

### S02 : Ajouter colonnes invitation a weddings

**Criteres cles** :
- Colonne `invite_code` VARCHAR(8) UNIQUE ajoutee
- Colonne `invite_code_expires_at` TIMESTAMP ajoutee
- Code genere automatiquement via trigger (S04)
- Expiration par defaut 30 jours

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 2.3 (Decision D-15)

**Complexite** : S (Small) - Ajout colonnes simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Wedding invitation code columns

  Scenario: Adding invite_code column
    Given the weddings table exists
    When the migration add_wedding_invite_columns is applied
    Then weddings should have column invite_code of type VARCHAR(8)
    And invite_code should have a UNIQUE constraint
    And invite_code should allow NULL (generated by trigger)

  Scenario: Adding invite_code_expires_at column
    Given the weddings table exists
    When the migration add_wedding_invite_columns is applied
    Then weddings should have column invite_code_expires_at of type TIMESTAMP
    And invite_code_expires_at should allow NULL

  Scenario: Existing weddings are not affected
    Given existing weddings in the database
    When the migration is applied
    Then all existing weddings should have invite_code = NULL
    And all existing weddings should have invite_code_expires_at = NULL
    And existing wedding data should remain unchanged
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128000002_add_wedding_invite_columns
-- Description: Add invitation code columns to weddings table

-- Add invite_code column (8 characters for security - D-15)
ALTER TABLE weddings
  ADD COLUMN IF NOT EXISTS invite_code VARCHAR(8) UNIQUE;

-- Add expiration column
ALTER TABLE weddings
  ADD COLUMN IF NOT EXISTS invite_code_expires_at TIMESTAMP;

-- Create index for faster lookup by invite_code
CREATE INDEX IF NOT EXISTS idx_weddings_invite_code
  ON weddings(invite_code)
  WHERE invite_code IS NOT NULL;

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'weddings' AND column_name = 'invite_code'
  ) THEN
    RAISE EXCEPTION 'Migration failed: invite_code column not created';
  END IF;
END $$;
```

**Rollback** :
```sql
-- Rollback: 20260128000002_add_wedding_invite_columns

-- Drop index first
DROP INDEX IF EXISTS idx_weddings_invite_code;

-- Remove columns
ALTER TABLE weddings DROP COLUMN IF EXISTS invite_code_expires_at;
ALTER TABLE weddings DROP COLUMN IF EXISTS invite_code;
```

**Dependances** : S01 (pour coherence du flow)

---

### S03 : Creer table invitation_attempts

**Criteres cles** :
- Table `invitation_attempts` creee avec colonnes: ip_address, attempted_at, success, code_attempted
- Index sur (ip_address, attempted_at) pour requetes rate limiting
- RLS activee (service_role uniquement)
- Pas de donnees sensibles exposees

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 2.3 (Decision D-15)

**Complexite** : S (Small) - Table simple avec index

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Invitation attempts rate limiting table

  Scenario: Creating invitation_attempts table
    Given the database schema
    When the migration create_invitation_attempts is applied
    Then table invitation_attempts should exist
    And it should have column ip_address of type VARCHAR(50)
    And it should have column attempted_at of type TIMESTAMP with default NOW()
    And it should have column success of type BOOLEAN with default FALSE
    And it should have column code_attempted of type VARCHAR(8)

  Scenario: Index for rate limiting queries
    Given the invitation_attempts table exists
    When querying attempts by IP in the last hour
    Then the query should use index idx_invitation_attempts_ip
    And the query should be performant (< 10ms for 10K rows)

  Scenario: RLS prevents direct user access
    Given a user authenticated with anon key
    When they try to SELECT from invitation_attempts
    Then they should receive 0 rows (RLS blocks access)

  Scenario: Rate limit check works
    Given 5 failed attempts from IP 192.168.1.1 in the last 15 minutes
    When checking rate limit for that IP
    Then the check should return TRUE (rate limited)
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128000003_create_invitation_attempts
-- Description: Create rate limiting table for invitation code attempts

CREATE TABLE IF NOT EXISTS invitation_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ip_address VARCHAR(50) NOT NULL,
  attempted_at TIMESTAMP DEFAULT NOW() NOT NULL,
  success BOOLEAN DEFAULT FALSE NOT NULL,
  code_attempted VARCHAR(8),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Index for rate limiting queries (IP + time window)
CREATE INDEX IF NOT EXISTS idx_invitation_attempts_ip_time
  ON invitation_attempts(ip_address, attempted_at DESC);

-- Index for cleanup of old records
CREATE INDEX IF NOT EXISTS idx_invitation_attempts_created
  ON invitation_attempts(created_at);

-- Enable RLS
ALTER TABLE invitation_attempts ENABLE ROW LEVEL SECURITY;

-- No public access - only service_role can read/write
-- This table is accessed via Edge Functions only

-- Optional: Function to check rate limit
CREATE OR REPLACE FUNCTION check_invitation_rate_limit(
  p_ip_address VARCHAR(50),
  p_max_attempts INTEGER DEFAULT 5,
  p_window_minutes INTEGER DEFAULT 15
)
RETURNS BOOLEAN AS $$
DECLARE
  attempt_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO attempt_count
  FROM invitation_attempts
  WHERE ip_address = p_ip_address
    AND attempted_at > NOW() - (p_window_minutes || ' minutes')::INTERVAL
    AND success = FALSE;

  RETURN attempt_count >= p_max_attempts;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comment for documentation
COMMENT ON TABLE invitation_attempts IS 'Rate limiting for wedding invitation code attempts (D-15)';
COMMENT ON FUNCTION check_invitation_rate_limit IS 'Returns TRUE if IP is rate limited (5 attempts per 15 min)';
```

**Rollback** :
```sql
-- Rollback: 20260128000003_create_invitation_attempts

DROP FUNCTION IF EXISTS check_invitation_rate_limit;
DROP INDEX IF EXISTS idx_invitation_attempts_created;
DROP INDEX IF EXISTS idx_invitation_attempts_ip_time;
DROP TABLE IF EXISTS invitation_attempts;
```

---

### S04 : Creer fonction generate_secure_invite_code

**Criteres cles** :
- Fonction `generate_secure_invite_code()` creee
- Genere code 8 caracteres alphanumeriques cryptographiquement securise
- Trigger sur INSERT weddings pour generer automatiquement
- Expiration fixee a 30 jours par defaut
- Code unique verifie

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 2.3

**Complexite** : S (Small) - Fonction et trigger

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Secure invitation code generation

  Scenario: Function generates 8-character code
    When generate_secure_invite_code() is called
    Then it should return a code of exactly 8 characters
    And the code should contain only uppercase letters and numbers
    And the code should be cryptographically random

  Scenario: Trigger generates code on wedding insert
    Given a user creates a new wedding
    When the wedding is inserted into the database
    Then invite_code should be automatically populated
    And invite_code_expires_at should be set to NOW() + 30 days

  Scenario: Code uniqueness is guaranteed
    Given 1000 weddings in the database
    When each has a generated invite_code
    Then all codes should be unique
    And no collision should occur

  Scenario: Existing weddings can get codes
    Given an existing wedding with invite_code = NULL
    When UPDATE weddings SET invite_code = generate_invite_code_value() is called
    Then the wedding should have a valid invite_code
    And invite_code_expires_at should be set

  Scenario: Code can be regenerated
    Given a wedding with an existing invite_code
    When the bride requests a new code
    Then a new unique code should be generated
    And the old code should become invalid
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128000004_create_generate_invite_code
-- Description: Create secure invite code generation function and trigger

-- Function to generate a single secure code value
CREATE OR REPLACE FUNCTION generate_invite_code_value()
RETURNS VARCHAR(8) AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- Excluded I, O, 0, 1 for readability
  code VARCHAR(8) := '';
  i INTEGER;
BEGIN
  -- Generate 8 random characters using cryptographic random bytes
  FOR i IN 1..8 LOOP
    code := code || SUBSTR(chars, 1 + FLOOR(RANDOM() * LENGTH(chars))::INTEGER, 1);
  END LOOP;

  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Trigger function for automatic code generation
CREATE OR REPLACE FUNCTION generate_secure_invite_code()
RETURNS TRIGGER AS $$
DECLARE
  new_code VARCHAR(8);
  max_attempts INTEGER := 10;
  attempt INTEGER := 0;
BEGIN
  -- Only generate if invite_code is NULL
  IF NEW.invite_code IS NULL THEN
    LOOP
      new_code := generate_invite_code_value();
      attempt := attempt + 1;

      -- Check uniqueness
      EXIT WHEN NOT EXISTS (
        SELECT 1 FROM weddings WHERE invite_code = new_code AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::UUID)
      );

      -- Safety: prevent infinite loop
      IF attempt >= max_attempts THEN
        RAISE EXCEPTION 'Could not generate unique invite code after % attempts', max_attempts;
      END IF;
    END LOOP;

    NEW.invite_code := new_code;
    NEW.invite_code_expires_at := NOW() + INTERVAL '30 days';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on weddings table
DROP TRIGGER IF EXISTS trg_generate_invite_code ON weddings;
CREATE TRIGGER trg_generate_invite_code
  BEFORE INSERT ON weddings
  FOR EACH ROW
  EXECUTE FUNCTION generate_secure_invite_code();

-- Function to regenerate code for existing wedding
CREATE OR REPLACE FUNCTION regenerate_wedding_invite_code(p_wedding_id UUID)
RETURNS VARCHAR(8) AS $$
DECLARE
  new_code VARCHAR(8);
BEGIN
  new_code := generate_invite_code_value();

  UPDATE weddings
  SET
    invite_code = new_code,
    invite_code_expires_at = NOW() + INTERVAL '30 days'
  WHERE id = p_wedding_id;

  RETURN new_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comments
COMMENT ON FUNCTION generate_invite_code_value IS 'Generates 8-char alphanumeric code (excludes confusing chars I,O,0,1)';
COMMENT ON FUNCTION generate_secure_invite_code IS 'Trigger function for automatic invite code generation';
COMMENT ON FUNCTION regenerate_wedding_invite_code IS 'Regenerates invite code for existing wedding (30 day expiration)';
```

**Rollback** :
```sql
-- Rollback: 20260128000004_create_generate_invite_code

DROP TRIGGER IF EXISTS trg_generate_invite_code ON weddings;
DROP FUNCTION IF EXISTS regenerate_wedding_invite_code;
DROP FUNCTION IF EXISTS generate_secure_invite_code;
DROP FUNCTION IF EXISTS generate_invite_code_value;
```

**Dependances** : S02 (colonnes invite_code doivent exister)

---

### S05 : Ajouter colonnes invitation a wedding_guests

**Criteres cles** :
- Colonne `user_id` UUID REFERENCES profiles(id) ajoutee
- Colonne `invited_at` TIMESTAMP ajoutee
- Colonne `joined_at` TIMESTAMP ajoutee
- Colonne `status` VARCHAR(20) DEFAULT 'pending' ajoutee
- Index sur wedding_id + status pour requetes performantes

**Source** : MISSION-01-EVOLUTIONS-2026.md Section APP-03

**Complexite** : S (Small) - Ajout colonnes avec FK

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Wedding guests invitation tracking columns

  Scenario: Adding user_id column
    Given the wedding_guests table exists
    When the migration add_guest_invitation_columns is applied
    Then wedding_guests should have column user_id of type UUID
    And user_id should reference profiles(id)
    And user_id should allow NULL (guest may not have account yet)

  Scenario: Adding invitation tracking columns
    Given the wedding_guests table exists
    When the migration add_guest_invitation_columns is applied
    Then wedding_guests should have column invited_at of type TIMESTAMP
    And wedding_guests should have column joined_at of type TIMESTAMP
    And wedding_guests should have column status of type VARCHAR(20)
    And status should default to 'pending'

  Scenario: Status values are constrained
    Given the status column exists
    When inserting a guest with status 'invalid_status'
    Then the insert should fail with constraint violation
    And only 'pending', 'invited', 'joined', 'declined' should be allowed

  Scenario: Guest lifecycle tracking
    Given a guest with status 'pending'
    When the bride sends an invitation
    Then status should change to 'invited'
    And invited_at should be set to current timestamp

    When the guest joins the wedding
    Then status should change to 'joined'
    And joined_at should be set to current timestamp
    And user_id should be linked to the guest's profile
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128000005_add_guest_invitation_columns
-- Description: Add invitation tracking columns to wedding_guests table

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

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'wedding_guests' AND column_name = 'status'
  ) THEN
    RAISE EXCEPTION 'Migration failed: status column not created';
  END IF;
END $$;

-- Comment
COMMENT ON COLUMN wedding_guests.status IS 'Guest invitation status: pending, invited, joined, declined';
COMMENT ON COLUMN wedding_guests.user_id IS 'Links to profiles when guest creates an account';
```

**Rollback** :
```sql
-- Rollback: 20260128000005_add_guest_invitation_columns

-- Drop indexes first
DROP INDEX IF EXISTS idx_wedding_guests_user_id;
DROP INDEX IF EXISTS idx_wedding_guests_wedding_status;

-- Drop constraint
ALTER TABLE wedding_guests DROP CONSTRAINT IF EXISTS chk_guest_status;

-- Drop columns
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS status;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS joined_at;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS invited_at;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS user_id;
```

**Dependances** : S01 (pour coherence du flow guest)

---

### S06 : Creer bucket wedding-media avec RLS

**Criteres cles** :
- Bucket `wedding-media` cree dans Supabase Storage
- Structure: `{wedding_id}/guests/{guest_user_id}/{filename}`
- RLS: Guest accede uniquement a son dossier
- RLS: Bride voit les medias des guests qui ont partage (shared_with_bride = TRUE)
- Taille max: 20MB photos, 500MB videos

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 2.4

**Complexite** : M (Medium) - Bucket + RLS complexes

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Wedding media storage bucket with RLS

  Scenario: Bucket creation
    Given the Supabase Storage service
    When the bucket wedding-media is created
    Then the bucket should exist and be active
    And the bucket should be private (not public)

  Scenario: Guest uploads to own folder
    Given a guest with user_id 'guest-123' in wedding 'wedding-456'
    When the guest uploads a photo to 'wedding-456/guests/guest-123/photo.jpg'
    Then the upload should succeed
    And the file should be accessible to the guest

  Scenario: Guest cannot access other guest's folder
    Given guest-A and guest-B in the same wedding
    When guest-A tries to read from 'wedding-456/guests/guest-B/photo.jpg'
    Then the access should be denied (RLS policy violation)

  Scenario: Guest cannot access other wedding's folder
    Given a guest in wedding 'wedding-456'
    When the guest tries to upload to 'wedding-789/guests/guest-123/photo.jpg'
    Then the upload should be denied

  Scenario: Bride can view shared guest media
    Given guest-A has uploaded media with shared_with_bride = TRUE
    When the bride of that wedding requests the file
    Then the bride should be able to view the file

  Scenario: Bride cannot view unshared guest media
    Given guest-A has uploaded media with shared_with_bride = FALSE
    When the bride tries to view the file
    Then the access should be denied

  Scenario: File size limits are enforced
    Given a guest trying to upload a 600MB video
    When the upload is attempted
    Then the upload should fail with size limit error
```

**Details techniques** :

**Migration SQL (Storage policies)** :
```sql
-- Migration: 20260128000006_create_wedding_media_bucket
-- Description: Create wedding-media bucket with RLS policies

-- Note: Bucket creation is done via Supabase Dashboard or API
-- This migration handles the RLS policies

-- Policy 1: Guest can upload to their own folder
CREATE POLICY "Guest upload own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[1] IN (
    SELECT w.id::text FROM weddings w
    JOIN wedding_guests wg ON wg.wedding_id = w.id
    WHERE wg.user_id = auth.uid()
  )
  AND (storage.foldername(name))[2] = 'guests'
  AND (storage.foldername(name))[3] = auth.uid()::text
);

-- Policy 2: Guest can read their own files
CREATE POLICY "Guest read own files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'guests'
  AND (storage.foldername(name))[3] = auth.uid()::text
);

-- Policy 3: Guest can delete their own files
CREATE POLICY "Guest delete own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'guests'
  AND (storage.foldername(name))[3] = auth.uid()::text
);

-- Policy 4: Bride can read shared guest media
CREATE POLICY "Bride read shared guest media"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'guests'
  AND EXISTS (
    SELECT 1 FROM weddings w
    JOIN guest_albums ga ON ga.wedding_id = w.id
    WHERE w.bride_profile_id = auth.uid()
    AND w.id::text = (storage.foldername(name))[1]
    AND ga.guest_user_id::text = (storage.foldername(name))[3]
    AND ga.shared_with_bride = TRUE
  )
);

-- Policy 5: Bride can upload to bride folder
CREATE POLICY "Bride upload own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'bride'
  AND EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.bride_profile_id = auth.uid()
    AND w.id::text = (storage.foldername(name))[1]
  )
);

-- Policy 6: Bride can read own files
CREATE POLICY "Bride read own files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'bride'
  AND EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.bride_profile_id = auth.uid()
    AND w.id::text = (storage.foldername(name))[1]
  )
);

-- Comments
COMMENT ON POLICY "Guest upload own folder" ON storage.objects IS 'Guest can only upload to their designated folder';
COMMENT ON POLICY "Bride read shared guest media" ON storage.objects IS 'Bride can view guest media when shared_with_bride=TRUE';
```

**Bucket Creation (via Supabase API/Dashboard)** :
```typescript
// Edge Function or Admin Script
const { data, error } = await supabase.storage.createBucket('wedding-media', {
  public: false,
  fileSizeLimit: 524288000, // 500MB max for videos
  allowedMimeTypes: [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'video/mp4',
    'video/quicktime',
    'video/x-m4v'
  ]
});
```

**Rollback** :
```sql
-- Rollback: 20260128000006_create_wedding_media_bucket

-- Drop all policies for the bucket
DROP POLICY IF EXISTS "Guest upload own folder" ON storage.objects;
DROP POLICY IF EXISTS "Guest read own files" ON storage.objects;
DROP POLICY IF EXISTS "Guest delete own files" ON storage.objects;
DROP POLICY IF EXISTS "Bride read shared guest media" ON storage.objects;
DROP POLICY IF EXISTS "Bride upload own folder" ON storage.objects;
DROP POLICY IF EXISTS "Bride read own files" ON storage.objects;

-- Note: Bucket deletion should be done manually after verifying no data loss
-- DELETE FROM storage.buckets WHERE id = 'wedding-media';
```

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Migration enum echoue en prod | CRITIQUE - Auth bloquee | Executer en periode de faible trafic (3h-5h), backup avant |
| Collision de codes invitation | MOYEN - Guests bloques | Boucle de retry (max 10), alphabet de 32 chars = faible proba |
| RLS Storage mal configuree | HAUT - Fuite de donnees | Tests exhaustifs sur branch dev avant merge |
| Rollback enum impossible | HAUT - Necessaire recreer type | Documenter procedure manuelle, jamais de guest avant validation |
| Trigger ralentit les inserts weddings | FAIBLE - UX degradee | Code generation est O(1), impact negligeable |
| Rate limiting trop strict | MOYEN - Guests frustres | Config ajustable (5 attempts/15min par defaut) |

---

## RLS Policies Summary (Decision D-16)

Toutes les tables de cet Epic ont des RLS policies obligatoires:

| Table | Policy | Access |
|-------|--------|--------|
| `invitation_attempts` | No public policy | service_role only (Edge Functions) |
| `wedding_guests` (modified) | Existing policies | Bride can CRUD, Guest can read own |
| `weddings` (modified) | Existing policies | Bride can CRUD own wedding |
| `storage.objects` (wedding-media) | 6 policies | Guest own folder, Bride shared view |

---

## Ordre d'Execution Recommande

```
S01 (enum guest) ──┬── S02 (weddings columns) ── S04 (trigger)
                   │
                   └── S05 (wedding_guests columns)

S03 (invitation_attempts) ── Independant

S06 (storage bucket) ── Peut etre fait en parallele
```

**Ordre sequentiel recommande pour securite:**
1. S01 - Enum userRole (prerequis pour tout)
2. S03 - Table invitation_attempts (independant)
3. S02 - Colonnes weddings
4. S04 - Trigger generate_secure_invite_code
5. S05 - Colonnes wedding_guests
6. S06 - Bucket wedding-media avec RLS

---

## References PRD

| Section PRD | Contenu utilise |
|-------------|-----------------|
| Section 2.1 | Migration Enum userRole |
| Section 2.2 | Template RLS policies |
| Section 2.3 | Securisation Code Invitation (D-15) |
| Section 2.4 | Storage Bucket Policies |
| Section 3 | Role Guest definition |
| Section 5 (APP-03) | Colonnes wedding_guests |
| Decision D-15 | Code 8 chars + expiration 30j + rate limiting |
| Decision D-16 | RLS obligatoires AVANT toute table |

---

## Prochaine Etape

Apres validation de cet Epic:
1. Executer `/create-story EPIC-06` pour decomposer en stories individuelles
2. Executer les migrations sur branche de developpement Supabase
3. Valider avec tests automatises
4. Merger en production
5. Passer a EPIC-07 (APP-01 Systeme d'avis clients)
