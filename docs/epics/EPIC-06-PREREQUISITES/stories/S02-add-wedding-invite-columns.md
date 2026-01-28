# Story S02: Add Invitation Columns to Weddings Table

## Description
En tant que **systeme**, je veux **ajouter les colonnes invite_code et invite_code_expires_at a la table weddings**, afin de **permettre aux mariees de partager un code d'invitation securise avec leurs invites**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the weddings table exists When the migration add_wedding_invite_columns is applied Then weddings should have column invite_code of type VARCHAR(8) And invite_code should have a UNIQUE constraint And invite_code should allow NULL
- [ ] Given the weddings table exists When the migration add_wedding_invite_columns is applied Then weddings should have column invite_code_expires_at of type TIMESTAMP And invite_code_expires_at should allow NULL
- [ ] Given existing weddings in the database When the migration is applied Then all existing weddings should have invite_code = NULL And all existing weddings should have invite_code_expires_at = NULL And existing wedding data should remain unchanged
- [ ] Given a query to find a wedding by invite_code When the index is used Then the query should execute in less than 10ms

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128000002_add_wedding_invite_columns.sql`

### A Modifier
- `lib/features/weddings_hub_pro/data/models/wedding_model.dart` - Add invite_code fields (optional)
- `lib/features/my_wedding/data/models/my_wedding_model.dart` - Add invite_code fields (optional)

## Notes Techniques

**Migration SQL:**
```sql
-- Add invite_code column (8 characters for security - Decision D-15)
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

**Rollback SQL:**
```sql
DROP INDEX IF EXISTS idx_weddings_invite_code;
ALTER TABLE weddings DROP COLUMN IF EXISTS invite_code_expires_at;
ALTER TABLE weddings DROP COLUMN IF EXISTS invite_code;
```

**Choix techniques (Decision D-15):**
- Code 8 caracteres alphanumeriques = 32^8 = 1 trillion de combinaisons
- Expiration 30 jours par defaut (securite)
- Index partiel (WHERE NOT NULL) pour performance

## Definition of Done

- [ ] Migration SQL appliquee avec succes sur branche de dev Supabase
- [ ] Colonnes invite_code et invite_code_expires_at existent (verifie via MCP)
- [ ] Contrainte UNIQUE sur invite_code fonctionne
- [ ] Index idx_weddings_invite_code cree
- [ ] Weddings existants non affectes (colonnes NULL)
- [ ] Models Dart mis a jour (si necessaire pour cette story)
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible (ajout de colonnes nullable)

## Dependances

- S01: Add 'guest' to userRole enum (pour coherence du flow)

## Stories Dependantes

- S04: Create generate_secure_invite_code function (depend des colonnes)
