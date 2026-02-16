# S02 Production Deployment Checklist

## Pre-Deployment Verification

### 1. Local SQL Validation
- [ ] Migration file syntax valid: `supabase/migrations/20260129000004_create_generate_invite_code.sql`
- [ ] Function `regenerate_wedding_invite_code()` has retry loop (lines 70-84)
- [ ] Backfill script has advisory lock + exception handling (Story Etape 4)
- [ ] Validation queries include regex + expiration (Story Etape 5)

### 2. Documentation Complete
- [ ] Story S02 updated with "Corrections Post-Challenge" section
- [ ] DoD has 10 criteria (was 6, added 4)
- [ ] Risks table updated with 3 mitigations
- [ ] SQL verification document created (`S02-SQL-VERIFICATION.md`)
- [ ] Fixes summary created (`S02-FIXES-SUMMARY.md`)

---

## Deployment Steps (via Supabase MCP)

### Etape 1: Diagnostic Pre-Deployment

#### 1.1 Verifier trigger existant
```sql
SELECT tgname, tgenabled, tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgname = 'trg_generate_invite_code';
```
**Attendu**: 1 row avec `tgenabled = 'O'` OU 0 rows (si jamais applique)

#### 1.2 Verifier fonctions existantes
```sql
SELECT proname, prokind, prorettype::regtype
FROM pg_proc
WHERE proname IN (
  'generate_invite_code_value',
  'generate_secure_invite_code',
  'regenerate_wedding_invite_code'
);
```
**Attendu**: 3 rows OU moins si migration jamais appliquee

#### 1.3 Etat actuel des mariages
```sql
SELECT
  COUNT(*) AS total_weddings,
  COUNT(invite_code) AS with_code,
  COUNT(*) - COUNT(invite_code) AS without_code
FROM weddings;
```
**Attendu**: `without_code` = nombre de mariages a backfill (probablement 8)

---

### Etape 2: Re-appliquer Migration (si necessaire)

**Contexte**: Si les fonctions n'existent pas OU si la fonction `regenerate_wedding_invite_code` n'a pas le retry loop.

#### 2.1 Verifier version actuelle de la fonction
```sql
SELECT pg_get_functiondef('regenerate_wedding_invite_code'::regproc);
```
**Check**: Si output ne contient pas `LOOP` et `max_attempts` → re-appliquer migration

#### 2.2 Re-appliquer migration
```bash
# Via Supabase MCP
mcp__supabase__apply_migration:
  project_ref: "hekyovgnovhfhmkpfrna"
  sql: <contenu de supabase/migrations/20260129000004_create_generate_invite_code.sql>
```

**⚠️ ATTENTION**: Cette operation est IDEMPOTENTE (`CREATE OR REPLACE`), safe a re-executer.

---

### Etape 3: Backfill (si mariages sans code)

**Pre-condition**: `without_code > 0` (verifie a Etape 1.3)

#### 3.1 Executer backfill avec advisory lock
```sql
-- Copier-coller le DO block complet depuis Story Etape 4
-- (lignes 105-187 de S02-invite-codes-trigger-backfill.md)

DO $$
DECLARE
  w RECORD;
  success_count INTEGER := 0;
  error_count INTEGER := 0;
  total_count INTEGER;
  lock_acquired BOOLEAN;
  lock_key BIGINT := 8675309;
BEGIN
  SELECT pg_try_advisory_lock(lock_key) INTO lock_acquired;

  IF NOT lock_acquired THEN
    RAISE EXCEPTION 'Another backfill is already running. Wait for it to complete.';
  END IF;

  BEGIN
    SELECT COUNT(*) INTO total_count FROM weddings WHERE invite_code IS NULL;
    RAISE NOTICE 'Starting backfill for % weddings', total_count;

    FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
      BEGIN
        PERFORM regenerate_wedding_invite_code(w.id);
        success_count := success_count + 1;
        RAISE NOTICE 'Generated code for wedding %', w.id;
      EXCEPTION WHEN OTHERS THEN
        error_count := error_count + 1;
        RAISE WARNING 'Failed to generate code for wedding %: %', w.id, SQLERRM;
      END;
    END LOOP;

    RAISE NOTICE 'Backfill complete: % success, % errors', success_count, error_count;

    IF error_count > 0 THEN
      RAISE EXCEPTION 'Backfill completed with % errors', error_count;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    PERFORM pg_advisory_unlock(lock_key);
    RAISE;
  END;

  PERFORM pg_advisory_unlock(lock_key);
END $$;
```

**Attendu**:
- `NOTICE: Starting backfill for N weddings`
- `NOTICE: Generated code for wedding <uuid>` (N fois)
- `NOTICE: Backfill complete: N success, 0 errors`

**Si erreurs**:
- `WARNING: Failed to generate code for wedding <uuid>: <error>` → Investiguer
- `EXCEPTION: Backfill completed with X errors` → Rollback, investiguer, re-essayer

---

### Etape 4: Validation Post-Deployment

#### 4.1 Verifier aucun code NULL
```sql
SELECT COUNT(*) AS weddings_without_code
FROM weddings
WHERE invite_code IS NULL;
```
**Attendu**: `0`

#### 4.2 Verifier unicite
```sql
SELECT invite_code, COUNT(*) AS duplicates
FROM weddings
GROUP BY invite_code
HAVING COUNT(*) > 1;
```
**Attendu**: `0 rows`

#### 4.3 Verifier format codes
```sql
SELECT id, invite_code
FROM weddings
WHERE invite_code !~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$';
```
**Attendu**: `0 rows`

#### 4.4 Verifier expiration
```sql
SELECT id, invite_code, invite_code_expires_at
FROM weddings
WHERE invite_code_expires_at IS NULL
   OR invite_code_expires_at < NOW();
```
**Attendu**: `0 rows`

#### 4.5 Test trigger (insert + rollback)
```sql
BEGIN;
  INSERT INTO weddings (id, bride_id)
  VALUES (gen_random_uuid(), gen_random_uuid())
  RETURNING id, invite_code, invite_code_expires_at;
ROLLBACK;
```
**Attendu**:
- `invite_code` = 8 chars valides (ex: `ABC12345`)
- `invite_code_expires_at` = NOW() + ~30 jours

---

### Etape 5: Verification UI (Flutter)

#### 5.1 Tester My Wedding Page
1. Se connecter en tant que bride avec un mariage
2. Naviguer vers "My Wedding" page
3. Verifier que le banner affiche :
   - Le code d'invitation (8 chars)
   - Boutons "Copy", "Share", "QR Code"
   - **PAS** le texte "Invite code generating..."

#### 5.2 Test scenario nouveau mariage
1. Creer un nouveau mariage dans l'app
2. Verifier que le code est genere immediatement
3. Verifier que le banner s'affiche correctement

---

## Rollback Plan (si echec)

### Si backfill echoue avec errors > 0
```sql
-- Identifier les mariages sans code
SELECT id, bride_id, created_at
FROM weddings
WHERE invite_code IS NULL;

-- Tenter regeneration manuelle pour chaque mariage
SELECT regenerate_wedding_invite_code('<wedding-uuid>');
```

### Si trigger ne fonctionne pas
```sql
-- Verifier trigger actif
SELECT tgenabled FROM pg_trigger WHERE tgname = 'trg_generate_invite_code';

-- Si tgenabled = 'D' (disabled), activer
ALTER TABLE weddings ENABLE TRIGGER trg_generate_invite_code;
```

### Si fonction cassee
```sql
-- Re-appliquer migration complete
-- (voir Etape 2.2)
```

---

## Post-Deployment Monitoring

### Metriques a surveiller (J+1, J+7)

#### Nouveaux mariages
```sql
-- Mariages crees dans les dernieres 24h
SELECT COUNT(*) AS new_weddings
FROM weddings
WHERE created_at > NOW() - INTERVAL '24 hours';

-- Parmi eux, combien ont un code?
SELECT
  COUNT(*) AS new_weddings_with_code
FROM weddings
WHERE created_at > NOW() - INTERVAL '24 hours'
  AND invite_code IS NOT NULL;
```
**Attendu**: `new_weddings = new_weddings_with_code` (100% coverage)

#### Codes expires
```sql
-- Codes expires (a renouveler)
SELECT COUNT(*) AS expired_codes
FROM weddings
WHERE invite_code_expires_at < NOW();
```
**Attendu**: `0` (initialement), puis surveillance mensuelle

---

## Definition of Done (Verification Finale)

- [ ] Les 3 fonctions SQL existent en production
- [ ] Le trigger `trg_generate_invite_code` est actif (tgenabled = 'O')
- [ ] Fonction `regenerate_wedding_invite_code()` utilise un retry loop (max 10 tentatives)
- [ ] Backfill script avec exception handling, logging NOTICE/WARNING et advisory lock
- [ ] 0 mariages avec `invite_code IS NULL`
- [ ] 0 doublons de codes (`GROUP BY HAVING COUNT > 1` = 0 rows)
- [ ] 0 codes avec format invalide (regex)
- [ ] 0 codes avec `invite_code_expires_at IS NULL` ou expiration passee
- [ ] Test insert + rollback confirme la generation automatique
- [ ] L'UI My Wedding affiche le code (pas "Generating...")

---

## Sign-Off

| Role | Nom | Date | Signature |
|------|-----|------|-----------|
| DBA/DevOps | | | |
| Product Owner | | | |

**Deployment Status**: [ ] SUCCESS  [ ] PARTIAL  [ ] FAILED

**Notes**:
