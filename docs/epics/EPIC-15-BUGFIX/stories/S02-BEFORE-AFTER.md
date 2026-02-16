# S02 Before/After Comparison

## 1. Function `regenerate_wedding_invite_code()`

### BEFORE (BROKEN) ❌
```sql
-- Function to regenerate code for existing wedding
CREATE OR REPLACE FUNCTION regenerate_wedding_invite_code(p_wedding_id UUID)
RETURNS VARCHAR(8) AS $$
DECLARE
  new_code VARCHAR(8);
BEGIN
  new_code := generate_invite_code_value();  -- ❌ 1 SEULE TENTATIVE

  UPDATE weddings
  SET invite_code = new_code,
      invite_code_expires_at = NOW() + INTERVAL '30 days'
  WHERE id = p_wedding_id;

  RETURN new_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Problemes**:
- ❌ Pas de retry loop
- ❌ Pas de verification unicite
- ❌ Si code existe deja → duplicate key constraint error → crash
- ❌ Pattern different du trigger (inconsistant)

---

### AFTER (FIXED) ✅
```sql
-- Function to regenerate code for existing wedding
CREATE OR REPLACE FUNCTION regenerate_wedding_invite_code(p_wedding_id UUID)
RETURNS VARCHAR(8) AS $$
DECLARE
  new_code VARCHAR(8);
  max_attempts INTEGER := 10;  -- ✅ RETRY LOOP
  attempt INTEGER := 0;
BEGIN
  LOOP  -- ✅ LOOP STRUCTURE
    new_code := generate_invite_code_value();
    attempt := attempt + 1;

    -- ✅ Check uniqueness before update
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM weddings
      WHERE invite_code = new_code
      AND id != p_wedding_id
    );

    -- ✅ Prevent infinite loop
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

**Ameliorations**:
- ✅ Retry loop avec max 10 tentatives
- ✅ Verification unicite AVANT UPDATE
- ✅ Exception claire si max tentatives depasse
- ✅ Pattern identique au trigger (consistance)

---

## 2. Backfill DO Block

### BEFORE (BROKEN) ❌
```sql
-- Backfill all weddings missing an invite code
DO $$ DECLARE w RECORD; BEGIN
  FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
    PERFORM regenerate_wedding_invite_code(w.id);  -- ❌ NO ERROR HANDLING
  END LOOP;
END $$;
```

**Problemes**:
- ❌ Si 1 mariage echoue → tout crash
- ❌ Pas de logging (impossible de savoir combien ont reussi/echoue)
- ❌ Pas de protection contre execution concurrente
- ❌ Appelle la fonction cassee (sans retry loop)

---

### AFTER (FIXED) ✅
```sql
-- Backfill all weddings missing an invite code
-- Idempotent, transactional, with exception handling and advisory lock
DO $$
DECLARE
  w RECORD;
  success_count INTEGER := 0;  -- ✅ TRACKING
  error_count INTEGER := 0;
  total_count INTEGER;
  lock_acquired BOOLEAN;
  lock_key BIGINT := 8675309;  -- ✅ ADVISORY LOCK
BEGIN
  -- ✅ Prevent concurrent execution
  SELECT pg_try_advisory_lock(lock_key) INTO lock_acquired;

  IF NOT lock_acquired THEN
    RAISE EXCEPTION 'Another backfill is already running. Wait for it to complete.';
  END IF;

  BEGIN
    -- ✅ Count weddings to process
    SELECT COUNT(*) INTO total_count FROM weddings WHERE invite_code IS NULL;
    RAISE NOTICE 'Starting backfill for % weddings', total_count;

    -- ✅ Process each wedding in a subtransaction
    FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
      BEGIN
        PERFORM regenerate_wedding_invite_code(w.id);
        success_count := success_count + 1;
        RAISE NOTICE 'Generated code for wedding %', w.id;  -- ✅ SUCCESS LOG
      EXCEPTION WHEN OTHERS THEN  -- ✅ EXCEPTION HANDLING
        error_count := error_count + 1;
        RAISE WARNING 'Failed to generate code for wedding %: %', w.id, SQLERRM;  -- ✅ ERROR LOG
        -- ✅ Continue processing other weddings
      END;
    END LOOP;

    RAISE NOTICE 'Backfill complete: % success, % errors', success_count, error_count;

    -- ✅ Fail if any errors occurred
    IF error_count > 0 THEN
      RAISE EXCEPTION 'Backfill completed with % errors', error_count;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    -- ✅ Release lock before re-raising exception
    PERFORM pg_advisory_unlock(lock_key);
    RAISE;
  END;

  -- ✅ Release advisory lock
  PERFORM pg_advisory_unlock(lock_key);
END $$;
```

**Ameliorations**:
- ✅ Advisory lock (empeche backfills concurrents)
- ✅ Exception handling avec subtransaction par mariage
- ✅ Logging NOTICE (succes) et WARNING (erreurs)
- ✅ Continue le traitement meme si 1 mariage echoue
- ✅ Compteurs (success/error) pour visibilite
- ✅ Raise exception finale si errors > 0 (alerter operateur)

---

## 3. Validation Post-Backfill

### BEFORE (INCOMPLETE) ❌
```sql
-- Verify no NULL codes remain
SELECT COUNT(*) AS weddings_without_code
FROM weddings
WHERE invite_code IS NULL;

-- Verify uniqueness
SELECT invite_code, COUNT(*) AS duplicates
FROM weddings
GROUP BY invite_code
HAVING COUNT(*) > 1;
```

**Problemes**:
- ❌ Pas de validation format (regex)
- ❌ Pas de validation expiration
- ❌ Codes invalides peuvent passer inapercus

---

### AFTER (COMPLETE) ✅
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

-- ✅ Verify code format (8 chars, valid charset)
SELECT id, invite_code
FROM weddings
WHERE invite_code !~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$';
-- Expected: 0 rows

-- ✅ Verify expiration dates are valid (not NULL, in the future)
SELECT id, invite_code, invite_code_expires_at
FROM weddings
WHERE invite_code_expires_at IS NULL
   OR invite_code_expires_at < NOW();
-- Expected: 0 rows (all codes should expire in the future)
```

**Ameliorations**:
- ✅ Validation format via regex PostgreSQL
- ✅ Validation expiration (NULL ou passee)
- ✅ Commentaires "Expected" pour chaque query
- ✅ Coverage complete (NULL, duplicates, format, expiration)

---

## 4. Definition of Done

### BEFORE (6 CRITERIA) ❌
```
- [ ] Les 3 fonctions SQL existent en production
- [ ] Le trigger `trg_generate_invite_code` est actif (tgenabled = 'O')
- [ ] 0 mariages avec `invite_code IS NULL`
- [ ] 0 doublons de codes (`GROUP BY HAVING COUNT > 1` = 0 rows)
- [ ] Test insert + rollback confirme la generation automatique
- [ ] L'UI My Wedding affiche le code (pas "Generating...")
```

**Problemes**:
- ❌ Pas de critere sur retry loop
- ❌ Pas de critere sur exception handling
- ❌ Pas de critere sur format codes
- ❌ Pas de critere sur expiration

---

### AFTER (10 CRITERIA) ✅
```
- [ ] Les 3 fonctions SQL existent en production
- [ ] Le trigger `trg_generate_invite_code` est actif (tgenabled = 'O')
- [ ] ✅ Fonction `regenerate_wedding_invite_code()` utilise un retry loop (max 10 tentatives)
- [ ] ✅ Backfill script avec exception handling, logging NOTICE/WARNING et advisory lock
- [ ] 0 mariages avec `invite_code IS NULL`
- [ ] 0 doublons de codes (`GROUP BY HAVING COUNT > 1` = 0 rows)
- [ ] ✅ 0 codes avec format invalide (regex `^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$`)
- [ ] ✅ 0 codes avec `invite_code_expires_at IS NULL` ou expiration passee
- [ ] Test insert + rollback confirme la generation automatique
- [ ] L'UI My Wedding affiche le code (pas "Generating...")
```

**Ameliorations**:
- ✅ +4 nouveaux criteres (retry loop, exception handling, format, expiration)
- ✅ Coverage complete des problemes identifies

---

## Summary Table

| Aspect | Before | After | Status |
|--------|--------|-------|--------|
| **Retry Loop** | ❌ 1 tentative | ✅ Max 10 tentatives | FIXED |
| **Uniqueness Check** | ❌ Apres UPDATE (crash) | ✅ Avant UPDATE (safe) | FIXED |
| **Exception Handling** | ❌ Crash si erreur | ✅ Continue + log | FIXED |
| **Logging** | ❌ Aucun | ✅ NOTICE/WARNING | FIXED |
| **Advisory Lock** | ❌ Aucun | ✅ pg_try_advisory_lock | FIXED |
| **Format Validation** | ❌ Aucun | ✅ Regex PostgreSQL | FIXED |
| **Expiration Validation** | ❌ Aucun | ✅ NULL + past check | FIXED |
| **DoD Criteria** | ❌ 6 criteres | ✅ 10 criteres | FIXED |

**Result**: ✅ ALL CRITICAL ISSUES FIXED
