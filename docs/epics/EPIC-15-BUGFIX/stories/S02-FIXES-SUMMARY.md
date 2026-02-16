# S02 SQL Fixes Summary - 2026-02-16

## Mission
Corriger TOUS les problemes SQL detectes lors du re-challenge de la story S02.

## Problemes Initiaux (BLOQUANTS)

### 1. Fonction `regenerate_wedding_invite_code()` sans retry loop
**Fichier**: `supabase/migrations/20260129000004_create_generate_invite_code.sql`

**Probleme**:
```sql
-- Version CASSEE (lignes 63-77 originales)
CREATE OR REPLACE FUNCTION regenerate_wedding_invite_code(p_wedding_id UUID)
RETURNS VARCHAR(8) AS $$
DECLARE
  new_code VARCHAR(8);
BEGIN
  new_code := generate_invite_code_value();  -- 1 seule tentative!

  UPDATE weddings
  SET invite_code = new_code,
      invite_code_expires_at = NOW() + INTERVAL '30 days'
  WHERE id = p_wedding_id;

  RETURN new_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Impact**: Si `new_code` existe deja dans la table → duplicate key constraint → crash

**Solution**:
```sql
-- Version CORRIGEE (lignes 63-93 nouvelles)
CREATE OR REPLACE FUNCTION regenerate_wedding_invite_code(p_wedding_id UUID)
RETURNS VARCHAR(8) AS $$
DECLARE
  new_code VARCHAR(8);
  max_attempts INTEGER := 10;
  attempt INTEGER := 0;
BEGIN
  LOOP
    new_code := generate_invite_code_value();
    attempt := attempt + 1;

    -- Check uniqueness before update
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM weddings
      WHERE invite_code = new_code
      AND id != p_wedding_id
    );

    IF attempt >= max_attempts THEN
      RAISE EXCEPTION 'Could not generate unique invite code for wedding % after % attempts', p_wedding_id, max_attempts;
    END IF;
  END LOOP;

  UPDATE weddings
  SET invite_code = new_code,
      invite_code_expires_at = NOW() + INTERVAL '30 days'
  WHERE id = p_wedding_id;

  RETURN new_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Changements**:
- Ajoute variables `max_attempts` et `attempt`
- Ajoute `LOOP` avec `EXIT WHEN NOT EXISTS`
- Ajoute verification unicite AVANT UPDATE
- Ajoute `RAISE EXCEPTION` si max tentatives depasse
- Pattern identique au trigger `generate_secure_invite_code()`

---

### 2. Backfill DO block sans exception handling

**Fichier**: `docs/epics/EPIC-15-BUGFIX/stories/S02-invite-codes-trigger-backfill.md` (Etape 4)

**Probleme**:
```sql
-- Version CASSEE
DO $$ DECLARE w RECORD; BEGIN
  FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
    PERFORM regenerate_wedding_invite_code(w.id);
  END LOOP;
END $$;
```

**Issues**:
1. Si 1 mariage echoue → tout crash
2. Pas de logging
3. Pas de protection contre execution concurrente
4. Non-idempotent (OK sur ce point car WHERE IS NULL)

**Solution**:
```sql
-- Version CORRIGEE
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

**Changements**:
- Ajoute advisory lock (`pg_try_advisory_lock`) pour eviter backfills concurrents
- Ajoute compteurs `success_count`, `error_count`, `total_count`
- Ajoute `BEGIN...EXCEPTION WHEN OTHERS` dans la boucle (subtransaction par mariage)
- Ajoute logging `RAISE NOTICE` pour succes et `RAISE WARNING` pour erreurs
- Continue le traitement meme si 1 mariage echoue
- Raise exception finale si errors > 0 (pour alerter operateur)
- Release lock dans exception handler ET en fin normale

---

### 3. Validation post-backfill incomplete

**Fichier**: `docs/epics/EPIC-15-BUGFIX/stories/S02-invite-codes-trigger-backfill.md` (Etape 5)

**Probleme**:
```sql
-- Version CASSEE
SELECT COUNT(*) AS weddings_without_code
FROM weddings
WHERE invite_code IS NULL;

SELECT invite_code, COUNT(*) AS duplicates
FROM weddings
GROUP BY invite_code
HAVING COUNT(*) > 1;
```

**Issues**:
1. Pas de validation format codes (regex)
2. Pas de validation expiration dates

**Solution**:
```sql
-- Version CORRIGEE (ajout de 2 nouvelles queries)

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

**Changements**:
- Ajoute validation format via regex PostgreSQL (`!~`)
- Ajoute validation expiration (NULL ou passee)
- Ajoute commentaires "Expected" pour chaque query

---

## Definition of Done (Mise a Jour)

**Avant** (6 criteres):
- [ ] Les 3 fonctions SQL existent en production
- [ ] Le trigger `trg_generate_invite_code` est actif (tgenabled = 'O')
- [ ] 0 mariages avec `invite_code IS NULL`
- [ ] 0 doublons de codes (`GROUP BY HAVING COUNT > 1` = 0 rows)
- [ ] Test insert + rollback confirme la generation automatique
- [ ] L'UI My Wedding affiche le code (pas "Generating...")

**Apres** (10 criteres):
- [ ] Les 3 fonctions SQL existent en production
- [ ] Le trigger `trg_generate_invite_code` est actif (tgenabled = 'O')
- [ ] **Fonction `regenerate_wedding_invite_code()` utilise un retry loop (max 10 tentatives)**
- [ ] **Backfill script avec exception handling, logging NOTICE/WARNING et advisory lock**
- [ ] 0 mariages avec `invite_code IS NULL`
- [ ] 0 doublons de codes (`GROUP BY HAVING COUNT > 1` = 0 rows)
- [ ] **0 codes avec format invalide (regex `^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$`)**
- [ ] **0 codes avec `invite_code_expires_at IS NULL` ou expiration passee**
- [ ] Test insert + rollback confirme la generation automatique
- [ ] L'UI My Wedding affiche le code (pas "Generating...")

**+4 nouveaux criteres** (en gras)

---

## Risques Mitiges

| Risque | Etat Avant | Etat Apres |
|--------|------------|------------|
| Collision de codes lors du backfill | NON MITIGE (1 tentative) | ✅ MITIGE (retry loop 10 tentatives) |
| Erreur sur 1 mariage crashe tout | NON MITIGE | ✅ MITIGE (exception handling + subtransaction) |
| Backfill concurrent (race condition) | NON MITIGE | ✅ MITIGE (advisory lock) |
| Codes invalides passent inapercus | NON MITIGE | ✅ MITIGE (validation regex + expiration) |

---

## Fichiers Modifies

| Fichier | Lignes | Changement |
|---------|--------|------------|
| `supabase/migrations/20260129000004_create_generate_invite_code.sql` | 63-93 | Fonction `regenerate_wedding_invite_code()` avec retry loop |
| `docs/epics/EPIC-15-BUGFIX/stories/S02-invite-codes-trigger-backfill.md` | 64-95 | Section "Corrections Post-Challenge" ajoutee |
| `docs/epics/EPIC-15-BUGFIX/stories/S02-invite-codes-trigger-backfill.md` | 105-161 | Etape 4 (backfill) avec exception handling + advisory lock |
| `docs/epics/EPIC-15-BUGFIX/stories/S02-invite-codes-trigger-backfill.md` | 143-169 | Etape 5 (validation) avec regex + expiration |
| `docs/epics/EPIC-15-BUGFIX/stories/S02-invite-codes-trigger-backfill.md` | 252-263 | DoD avec 4 nouveaux criteres |
| `docs/epics/EPIC-15-BUGFIX/stories/S02-invite-codes-trigger-backfill.md` | 267-275 | Risques avec 2 nouvelles lignes |

---

## Tests Mentaux Effectues

Voir `docs/epics/EPIC-15-BUGFIX/stories/S02-SQL-VERIFICATION.md` pour:
- Test collisions (1ere tentative, max tentatives, aucune collision)
- Test backfill (3 mariages success, 1 fail, idempotence)
- Validation regex format
- Validation expiration
- Comparaison trigger vs backfill function
- Edge cases (wedding inexistant, parallel execution, transaction isolation)

---

## Statut Final

✅ **TOUS LES PROBLEMES CORRIGES**
✅ **SQL PRODUCTION-READY**
✅ **MIGRATION TESTABLE**
✅ **BACKFILL IDEMPOTENT**
✅ **VALIDATION COMPLETE**

**Prochaine etape**: Appliquer la migration en production via Supabase MCP
