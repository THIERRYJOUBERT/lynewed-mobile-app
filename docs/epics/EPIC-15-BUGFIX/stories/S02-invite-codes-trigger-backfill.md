# Story S02: Fix invite codes (trigger + backfill)

> **Epic** : EPIC-15-BUGFIX
> **Domaine** : DATA
> **Source** : BUG-01b
> **Status** : Done
> **Complexite** : S (Small)
> **Points** : 2
> **Dependances** : Aucune
> **Stories dependantes** : S05 (Edge Function send-wedding-invitation)

---

## Description

En tant que bride ayant cree un mariage, je veux que mon code d'invitation soit genere automatiquement a la creation du mariage, afin de pouvoir inviter mes guests sans attendre indefiniment un code qui n'arrive jamais.

**Probleme actuel** : Le trigger `trg_generate_invite_code` et/ou la fonction `generate_secure_invite_code()` ne sont pas actifs en production. Les mariages existants ont potentiellement `invite_code = NULL`, ce qui cause l'affichage permanent de "Invite code generating..." dans `my_wedding_page.dart:644-649`.

---

## Criteres d'Acceptance (Gherkin)

### AC-01 : Trigger present et actif en production

- [ ] Given the Supabase production database
  When I query `SELECT tgname, tgenabled FROM pg_trigger WHERE tgname = 'trg_generate_invite_code'`
  Then the trigger exists with `tgenabled = 'O'` (Origin-fired, i.e. active)

### AC-02 : Fonctions SQL presentes en production

- [ ] Given the Supabase production database
  When I query `SELECT proname FROM pg_proc WHERE proname IN ('generate_invite_code_value', 'generate_secure_invite_code', 'regenerate_wedding_invite_code')`
  Then all 3 functions are returned

### AC-03 : Backfill des mariages sans code

- [ ] Given there are weddings with `invite_code IS NULL` in production
  When I run the backfill script
  Then all weddings have a non-null `invite_code` (8 chars, alphanumeric, excluding I/O/0/1)
  And all weddings have a valid `invite_code_expires_at` set to 30 days from now

### AC-04 : Codes uniques et valides

- [ ] Given the backfill has been executed
  When I query `SELECT invite_code, COUNT(*) FROM weddings GROUP BY invite_code HAVING COUNT(*) > 1`
  Then zero rows are returned (all codes are unique)

### AC-05 : Nouveau mariage genere un code automatiquement

- [ ] Given the trigger is active in production
  When a new wedding is inserted with `invite_code = NULL`
  Then the trigger fires and sets `invite_code` to a valid 8-char code
  And `invite_code_expires_at` is set to 30 days from insertion

### AC-06 : UI affiche le code au lieu de "Generating..."

- [ ] Given a bride with a wedding that has a valid invite_code
  When she navigates to the My Wedding page
  Then the invite code banner displays the 8-char code with copy/share/QR actions
  And "Invite code generating..." is NOT displayed

---

## Corrections Post-Challenge (2026-02-16)

### Problemes Identifies

1. **Fonction `regenerate_wedding_invite_code()` sans retry loop** (BLOQUANT)
   - Version initiale generait code 1 seule fois
   - Si code existe deja → duplicate key constraint error
   - Fonction trigger `generate_secure_invite_code()` avait deja le retry loop correct

2. **Backfill DO loop sans exception handling** (BLOQUANT)
   - Si 1 mariage echoue → tout crash
   - Pas de transaction explicite
   - Pas de logging
   - Non-idempotent

3. **Validation post-backfill incomplete**
   - Manquait validation format codes (regex)
   - Manquait validation expiration dates

### Corrections Appliquees

| Probleme | Solution | Fichier |
|----------|----------|---------|
| Retry loop manquant | Ajoute LOOP avec max 10 tentatives + unicite check | Migration ligne 70-84 |
| Exception handling manquant | Ajoute BEGIN...EXCEPTION WHEN OTHERS + logging NOTICE/WARNING | Story Etape 4 |
| Race condition backfill concurrent | Ajoute advisory lock (`pg_try_advisory_lock`) | Story Etape 4 |
| Validation format | Ajoute regex `^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$` | Story Etape 5 |
| Validation expiration | Ajoute check `invite_code_expires_at IS NULL OR < NOW()` | Story Etape 5 |
| DoD incomplet | Ajoute 5 criteres (retry loop, exception handling, advisory lock, format, expiration) | DoD section |

---

## Diagnostic SQL (a executer via Supabase MCP)

### Etape 1 : Verifier le trigger

```sql
SELECT tgname, tgenabled, tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgname = 'trg_generate_invite_code';
```

**Si resultat vide** : le trigger n'existe pas -> re-appliquer la migration.

### Etape 2 : Verifier les fonctions

```sql
SELECT proname, prokind, prorettype::regtype
FROM pg_proc
WHERE proname IN (
  'generate_invite_code_value',
  'generate_secure_invite_code',
  'regenerate_wedding_invite_code'
);
```

**Si resultat incomplet** : fonctions manquantes -> re-appliquer la migration.

### Etape 3 : Etat des mariages

```sql
SELECT
  id,
  invite_code,
  invite_code_expires_at,
  created_at
FROM weddings
ORDER BY created_at DESC;
```

### Etape 4 : Backfill (si mariages avec code NULL)

```sql
-- Backfill all weddings missing an invite code
-- Idempotent, transactional, with exception handling and advisory lock
DO $$
DECLARE
  w RECORD;
  success_count INTEGER := 0;
  error_count INTEGER := 0;
  total_count INTEGER;
  lock_acquired BOOLEAN;
  lock_key BIGINT := 8675309; -- Unique lock ID for invite code backfill
BEGIN
  -- Acquire advisory lock to prevent concurrent backfill execution
  SELECT pg_try_advisory_lock(lock_key) INTO lock_acquired;

  IF NOT lock_acquired THEN
    RAISE EXCEPTION 'Another backfill is already running. Wait for it to complete.';
  END IF;

  BEGIN
    -- Count weddings to process
    SELECT COUNT(*) INTO total_count FROM weddings WHERE invite_code IS NULL;
    RAISE NOTICE 'Starting backfill for % weddings', total_count;

    -- Process each wedding in a subtransaction
    FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
      BEGIN
        PERFORM regenerate_wedding_invite_code(w.id);
        success_count := success_count + 1;
        RAISE NOTICE 'Generated code for wedding %', w.id;
      EXCEPTION WHEN OTHERS THEN
        error_count := error_count + 1;
        RAISE WARNING 'Failed to generate code for wedding %: %', w.id, SQLERRM;
        -- Continue processing other weddings
      END;
    END LOOP;

    RAISE NOTICE 'Backfill complete: % success, % errors', success_count, error_count;

    -- Fail if any errors occurred
    IF error_count > 0 THEN
      RAISE EXCEPTION 'Backfill completed with % errors', error_count;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    -- Release lock before re-raising exception
    PERFORM pg_advisory_unlock(lock_key);
    RAISE;
  END;

  -- Release advisory lock
  PERFORM pg_advisory_unlock(lock_key);
END $$;
```

### Etape 5 : Validation post-backfill

```sql
-- Verify no NULL codes remain
SELECT COUNT(*) AS weddings_without_code
FROM weddings
WHERE invite_code IS NULL;
-- Expected: 0

-- Verify uniqueness
SELECT invite_code, COUNT(*) AS duplicates
FROM weddings
GROUP BY invite_code
HAVING COUNT(*) > 1;
-- Expected: 0 rows

-- Verify code format (8 chars, valid charset)
SELECT id, invite_code
FROM weddings
WHERE invite_code !~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$';
-- Expected: 0 rows

-- Verify expiration dates are valid (not NULL, in the future)
SELECT id, invite_code, invite_code_expires_at
FROM weddings
WHERE invite_code_expires_at IS NULL
   OR invite_code_expires_at < NOW();
-- Expected: 0 rows (all codes should expire in the future)
```

### Etape 6 : Test trigger (insert + rollback)

```sql
-- Test: insert a dummy wedding and check the trigger fires
-- WARNING: use a transaction to avoid polluting prod data
BEGIN;
  INSERT INTO weddings (id, bride_id)
  VALUES (gen_random_uuid(), gen_random_uuid())
  RETURNING id, invite_code, invite_code_expires_at;
ROLLBACK;
```

---

## Migration de reference

Fichier : `supabase/migrations/20260129000004_create_generate_invite_code.sql`

Cette migration cree :
1. `generate_invite_code_value()` - Genere un code 8 chars (charset: `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`)
2. `generate_secure_invite_code()` - Trigger function avec retry (max 10 tentatives pour unicite)
3. `trg_generate_invite_code` - Trigger BEFORE INSERT sur `weddings`
4. `regenerate_wedding_invite_code(p_wedding_id)` - Fonction SECURITY DEFINER pour backfill/regeneration

**Action si absent** : Re-appliquer via `apply_migration` du MCP Supabase.

---

## Fichiers Concernes

### A Verifier (DB)

| Element | Verification |
|---------|-------------|
| Trigger `trg_generate_invite_code` | Existe et actif (pg_trigger) |
| Fonction `generate_invite_code_value` | Existe (pg_proc) |
| Fonction `generate_secure_invite_code` | Existe (pg_proc) |
| Fonction `regenerate_wedding_invite_code` | Existe (pg_proc) |
| Table `weddings.invite_code` | Colonne existe, pas de NULL apres backfill |

### A Verifier (Flutter - lecture seule)

| Fichier | Pourquoi |
|---------|----------|
| `lib/features/my_wedding/presentation/pages/my_wedding_page.dart:584-651` | Banner "Invite code generating..." (fallback UI quand code NULL) |
| `lib/features/my_wedding/domain/entities/wedding_overview.dart` | Champs `inviteCode` et `inviteCodeExpiresAt` |
| `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart` | Query SELECT `invite_code` |

### Aucune modification Flutter requise

L'UI existante (`my_wedding_page.dart:596`) affiche deja le code quand `hasCode == true` et le texte "Invite code generating..." quand `hasCode == false`. Le fix est purement DB : une fois le trigger actif et le backfill fait, l'UI fonctionne correctement.

---

## Plan d'Execution

| # | Action | Outil | Risque |
|---|--------|-------|--------|
| 1 | Diagnostic trigger (Etape 1) | Supabase MCP `execute_sql` | Aucun (SELECT) |
| 2 | Diagnostic fonctions (Etape 2) | Supabase MCP `execute_sql` | Aucun (SELECT) |
| 3 | Etat mariages (Etape 3) | Supabase MCP `execute_sql` | Aucun (SELECT) |
| 4 | Re-appliquer migration si absent | Supabase MCP `apply_migration` | MOYEN - tester avant |
| 5 | Backfill codes NULL (Etape 4) | Supabase MCP `execute_sql` | FAIBLE - UPDATE avec WHERE |
| 6 | Validation post-backfill (Etape 5) | Supabase MCP `execute_sql` | Aucun (SELECT) |
| 7 | Test trigger insert (Etape 6) | Supabase MCP `execute_sql` | Aucun (ROLLBACK) |

---

## Validation INVEST

| Critere | Evaluation |
|---------|-----------|
| **Independent** | Pas de dependance. Peut etre fait en premier. |
| **Negotiable** | Le backfill est non-negociable. La methode (migration vs SQL direct) est flexible. |
| **Valuable** | Debloque S05 (invitations email). Corrige l'UI "Generating..." pour les brides. |
| **Estimable** | 2 points. Diagnostics SQL + backfill. Pas de code Flutter a modifier. |
| **Small** | Pure intervention DB. Max 1h de travail. |
| **Testable** | Requetes SQL de verification + test trigger insert/rollback. |

---

## Definition of Done

- [ ] Les 3 fonctions SQL existent en production
- [ ] Le trigger `trg_generate_invite_code` est actif (tgenabled = 'O')
- [ ] Fonction `regenerate_wedding_invite_code()` utilise un retry loop (max 10 tentatives)
- [ ] Backfill script avec exception handling, logging NOTICE/WARNING et advisory lock
- [ ] 0 mariages avec `invite_code IS NULL`
- [ ] 0 doublons de codes (`GROUP BY HAVING COUNT > 1` = 0 rows)
- [ ] 0 codes avec format invalide (regex `^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$`)
- [ ] 0 codes avec `invite_code_expires_at IS NULL` ou expiration passee
- [ ] Test insert + rollback confirme la generation automatique
- [ ] L'UI My Wedding affiche le code (pas "Generating...")

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Migration deja appliquee mais trigger inactif | Faible | Diagnostiquer avec `tgenabled` puis `ALTER TABLE ... ENABLE TRIGGER` |
| Fonction `regenerate_wedding_invite_code` absente | Moyen | Re-appliquer migration complete |
| Collision de codes lors du backfill | Tres faible | ✅ MITIGE - Fonction avec retry loop (max 10 tentatives) + charset de 30^8 = 656M combinaisons pour 8 mariages |
| Erreur sur 1 mariage crashe tout le backfill | ELIMINE | ✅ MITIGE - Exception handling avec subtransaction par mariage + logging NOTICE/WARNING |
| Backfill concurrent (race condition) | ELIMINE | ✅ MITIGE - Advisory lock (`pg_try_advisory_lock`) empeche execution parallele |
| `invite_code_expires_at` expiration des codes backfilles | Faible | Le backfill met 30 jours a partir de NOW(). A renouveler si necessaire. |

---

## Estimation

**Points** : 2
**Complexite** : Small
**Risque** : Faible
**Temps estime** : 30-60 minutes
